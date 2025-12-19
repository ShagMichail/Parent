//
//  NotificationService.swift
//  ParentControlNSE
//
//  Created by Michail Shagovitov on 12.12.2025.
//

import UserNotifications
import ManagedSettings
import CloudKit
import FamilyControls // На всякий случай

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    let store = ManagedSettingsStore()
    
    let database = CKContainer(identifier: "iCloud.com.laborato.Parent").publicCloudDatabase
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else { return }
        let userInfo = request.content.userInfo
        
        // 1. Разбираем структуру CloudKit
        guard let ckInfo = userInfo["ck"] as? [String: Any],
              let query = ckInfo["qry"] as? [String: Any],
              let recordIDString = query["rid"] as? String else {
            contentHandler(bestAttemptContent)
            return
        }
        
        let apsFields = query["af"] as? [String: Any]
        
        // --- ВЕТКА 1: КОМАНДЫ (Блокировка / Разблокировка / Локация) ---
        if let fields = apsFields, let commandName = fields["commandName"] as? String {
            
            print("NSE: Получена команда: \(commandName)")
            
            if commandName == "block_all" {
                store.shield.applicationCategories = .all()
//                store.shield.webDomains = .all() // Если нужно блокировать и веб
                bestAttemptContent.body = "Устройство заблокировано родителем"
                // Обновляем статус на executed
                updateCloudKitStatus(recordName: recordIDString) { contentHandler(bestAttemptContent) }
                return
            }
            else if commandName == "unblock_all" {
                store.shield.applicationCategories = nil
                store.shield.webDomains = nil
                bestAttemptContent.body = "Устройство разблокировано"
                // Обновляем статус на executed
                updateCloudKitStatus(recordName: recordIDString) { contentHandler(bestAttemptContent) }
                return
            }
            else if commandName == "request_location_update" {
                // ВАЖНО: Мы НЕ запускаем LocationManager здесь.
                // Мы просто меняем текст пуша, чтобы ребенок не пугался (или делаем его пустым).
                // Саму локацию обработает AppDelegate.
                bestAttemptContent.body = "Обновление геолокации..."
                // Статус не обновляем здесь, это сделает AppDelegate после отправки координат
                contentHandler(bestAttemptContent)
                return
            }
            else if commandName == "block_app_token" || commandName == "unblock_app_token" {
                
                // 1. Извлекаем payload
                guard let payloadData = fields["payload"] as? Data,
                      let payload = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(payloadData) as? [String: Any],
                      let token = payload["token"] as? ApplicationToken else {
                    // Если нет токена, ничего не делаем
                    updateCloudKitStatus(recordName: recordIDString) { contentHandler(bestAttemptContent) }
                    return
                }
                
                // 2. Применяем правило
                if commandName == "block_app_token" {
                    if store.shield.applications == nil { store.shield.applications = [token] }
                    else { store.shield.applications?.insert(token) }
                    bestAttemptContent.body = "Приложение заблокировано"
                    print("✅ NSE: Приложение \(token) заблокировано по токену.")
                    
                } else { // unblock_app_token
                    store.shield.applications?.remove(token)
                    bestAttemptContent.body = "Приложение разблокировано"
                    print("✅ NSE: Приложение \(token) разблокировано по токену.")
                }
                
                // 3. Отправляем отчет об успехе
                updateCloudKitStatus(recordName: recordIDString) { contentHandler(bestAttemptContent) }
                return
            }
        }
        
        // --- ВЕТКА 2: РАСПИСАНИЯ ---
        if let fields = apsFields, let _ = fields["startTimeString"] {
            // Это расписание (создание или обновление)
            if let newSchedule = createSchedule(from: fields, recordID: recordIDString) {
                updateSchedulesCache(with: newSchedule)
                bestAttemptContent.title = "Расписание обновлено"
                bestAttemptContent.body = "Настройки времени изменены родителем."
            }
        } else {
            // Это удаление расписания (полей нет, но пуш пришел)
            removeScheduleFromCache(withID: recordIDString)
            bestAttemptContent.title = "Расписание удалено"
            bestAttemptContent.body = "Ограничение времени снято."
        }
        
        contentHandler(bestAttemptContent)
    }
    
    // Функция обновления статуса в CloudKit из Расширения    
    private func updateCloudKitStatus(recordName: String, completion: @escaping () -> Void) {
        let recordID = CKRecord.ID(recordName: recordName)
        
        // 1. Создаем "пустую" запись, зная только ID
        let record = CKRecord(recordType: "Command", recordID: recordID)
        
        // 2. Меняем только то поле, которое нужно
        record["status"] = "executed"
        
        // 3. Используем операцию модификации
        let modifyOp = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        
        // ВАЖНО: .changedKeys обновляет только те поля, которые мы задали (status),
        // не затирая остальные данные на сервере.
        modifyOp.savePolicy = .changedKeys
        
        // Настройка качества обслуживания (UserInteractive - высший приоритет)
        modifyOp.qualityOfService = .userInteractive
        
        modifyOp.modifyRecordsResultBlock = { result in
            switch result {
            case .success:
                print("✅ NSE: Статус обновлен (Fast Mode)")
            case .failure(let error):
                print("❌ NSE: Ошибка обновления: \(error.localizedDescription)")
            }
            completion()
        }
        
        self.database.add(modifyOp)
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func createSchedule(from fields: [String: Any], recordID: String) -> FocusSchedule? {
        // 1. Читаем все поля, включая нашу новую строку
        guard let startTimeStr = fields["startTimeString"] as? String,
              let endTimeStr = fields["endTimeString"] as? String,
              let daysStr = fields["daysOfWeekString"] as? String,
              let isEnabledInt = fields["isEnabled"] as? Int,
              let scheduleUUID = UUID(uuidString: recordID) else {
            print("NSE Error: Не удалось распарсить обязательные поля из push.")
            return nil
        }
        
        // 2. Преобразуем строки времени в Date
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let startTime = formatter.date(from: startTimeStr),
              let endTime = formatter.date(from: endTimeStr) else {
            print("NSE Error: Не удалось преобразовать строки времени в Date.")
            return nil
        }
        
        // --- ✅ НОВЫЙ КОД ДЛЯ ПАРСИНГА ДНЕЙ НЕДЕЛИ ---
        // 1. Разделяем строку по запятой: "2,6" -> ["2", "6"]
        let stringDays = daysStr.split(separator: ",")
        // 2. Преобразуем в массив чисел: ["2", "6"] -> [2, 6]
        let rawDays = stringDays.compactMap { Int($0) }
        // 3. Преобразуем в массив Weekday: [2, 6] -> [.monday, .friday]
        let daysOfWeek = rawDays.compactMap { FocusSchedule.Weekday(rawValue: $0) }
        
        // 4. Преобразуем Int в Bool
        let isEnabled = isEnabledInt == 1
        
        // 5. Собираем и возвращаем готовый объект
        let newSchedule = FocusSchedule(
            id: scheduleUUID,
            startTime: startTime,
            endTime: endTime,
            daysOfWeek: daysOfWeek,
            isEnabled: isEnabled,
            recordID: recordID
        )
        
        return newSchedule
    }
    // Вставьте этот код в ваш класс NotificationService.swift
    
    /// Обновляет или добавляет расписание в кэш в AppGroup UserDefaults.
    /// - Parameter newSchedule: Расписание, которое нужно сохранить.
    private func updateSchedulesCache(with newSchedule: FocusSchedule) {
        // 1. Получаем доступ к общему хранилищу UserDefaults
        guard let groupDefaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") else {
            print("NSE Error: Не удалось получить доступ к AppGroup UserDefaults.")
            return
        }
        
        // 2. Читаем существующий массив расписаний из кэша
        var currentSchedules: [FocusSchedule] = []
        if let data = groupDefaults.data(forKey: "cached_focus_schedules"),
           let loaded = try? JSONDecoder().decode([FocusSchedule].self, from: data) {
            currentSchedules = loaded
        }
        
        // 3. Ищем расписание с таким же ID и либо обновляем его, либо добавляем новое
        if let index = currentSchedules.firstIndex(where: { $0.id == newSchedule.id }) {
            // Расписание уже существует -> обновляем его
            currentSchedules[index] = newSchedule
            print("NSE: Расписание с ID \(newSchedule.id) обновлено в кэше.")
        } else {
            // Новое расписание -> добавляем в массив
            currentSchedules.append(newSchedule)
            print("NSE: Новое расписание с ID \(newSchedule.id) добавлено в кэш.")
        }
        
        // 4. Сохраняем обновленный массив обратно в UserDefaults
        do {
            let dataToSave = try JSONEncoder().encode(currentSchedules)
            groupDefaults.set(dataToSave, forKey: "cached_focus_schedules")
        } catch {
            print("NSE Error: Не удалось закодировать и сохранить массив расписаний: \(error)")
        }
    }


    /// Удаляет расписание из кэша в AppGroup UserDefaults по его ID.
    /// - Parameter recordIDString: Строковое представление ID записи, которая была удалена.
    private func removeScheduleFromCache(withID recordIDString: String) {
        // 1. Получаем доступ к общему хранилищу UserDefaults
        guard let groupDefaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") else {
            print("NSE Error: Не удалось получить доступ к AppGroup UserDefaults.")
            return
        }

        // 2. Читаем существующий массив расписаний
        guard let data = groupDefaults.data(forKey: "cached_focus_schedules"),
              var currentSchedules = try? JSONDecoder().decode([FocusSchedule].self, from: data) else {
            // Если кэша нет или он пуст, то и удалять нечего.
            print("NSE: Кэш пуст, удаление не требуется.")
            return
        }

        // 3. Находим ID расписания, которое нужно удалить.
        // Ваша модель FocusSchedule использует `id` типа `UUID`, а из пуша приходит `recordID` типа `String`.
        // Поэтому мы сравниваем `id.uuidString` с `recordIDString`.
        let initialCount = currentSchedules.count
        currentSchedules.removeAll { $0.id.uuidString == recordIDString }

        // 4. Если что-то было удалено, сохраняем обновленный (уменьшенный) массив
        if currentSchedules.count < initialCount {
            print("NSE: Расписание с ID \(recordIDString) удалено из кэша.")
            do {
                let dataToSave = try JSONEncoder().encode(currentSchedules)
                groupDefaults.set(dataToSave, forKey: "cached_focus_schedules")
            } catch {
                print("NSE Error: Не удалось сохранить кэш после удаления: \(error)")
            }
        } else {
            print("NSE Warning: Расписание с ID \(recordIDString) для удаления не найдено в кэше.")
        }
    }
}
