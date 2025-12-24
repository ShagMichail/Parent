//
//  NotificationService.swift
//  ParentControlNSE
//
//  Created by Michail Shagovitov on 12.12.2025.
//

import UserNotifications
import ManagedSettings
import CloudKit
import DeviceActivity

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
        
        if let ckInfo = userInfo["ck"] as? [String: Any],
           let query = ckInfo["qry"] as? [String: Any],
           let subscriptionID = query["sid"] as? String {
            if subscriptionID.starts(with: "web-block-updates-") {
                
                print("🔔 [NSE] Получен пуш на обновление web блокировок! Запускаем синхронизацию...")
                
                // Запускаем асинхронную задачу
                Task {
                    await syncAndApplyWebBlocks()
                    
                    bestAttemptContent.title = "Блокировки обновлены"
                    bestAttemptContent.body = "Родитель изменил правила использования Web ресурсами."
                    
                    contentHandler(bestAttemptContent)
                }
                return
            }
            
            if subscriptionID.starts(with: "app-limits-updates-") {
                
                print("🔔 [NSE] Получен пуш на обновление лимитов! Запускаем синхронизацию...")
                
                // Запускаем асинхронную задачу
                Task {
                    await syncAndApplyAppLimits()
                    
                    bestAttemptContent.title = "Лимиты обновлены"
                    bestAttemptContent.body = "Родитель изменил правила использования приложений."
                    
                    contentHandler(bestAttemptContent)
                }
                return
            }
            
            if subscriptionID.starts(with: "app-block-updates-") {
                
                print("🔔 [NSE] Получен пуш на обновление Блокировок! Запускаем синхронизацию...")
                
                // Запускаем асинхронную задачу
                Task {
                    await fetchAndApplyAppBlocks()
                    
                    bestAttemptContent.title = "Блокировки обновлены"
                    bestAttemptContent.body = "Родитель изменил правила использования приложений."
                    
                    contentHandler(bestAttemptContent)
                }
                return
            }
        }
        
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
                store.shield.webDomainCategories = .all()
                //                store.shield.webDomains = .all() // Если нужно блокировать и веб
                bestAttemptContent.body = "Устройство заблокировано родителем"
                updateCloudKitStatus(recordName: recordIDString) { contentHandler(bestAttemptContent) }
                return
            }
            else if commandName == "unblock_all" {
                store.shield.applicationCategories = nil
                store.shield.webDomainCategories = nil
                bestAttemptContent.body = "Устройство разблокировано"
                // Обновляем статус на executed
                updateCloudKitStatus(recordName: recordIDString) { contentHandler(bestAttemptContent) }
                return
            }
            else if commandName == "request_location_update" {
                bestAttemptContent.body = "Обновление геолокации..."
                contentHandler(bestAttemptContent)
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
        
        modifyOp.savePolicy = .changedKeys
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
        let stringDays = daysStr.split(separator: ",")
        let rawDays = stringDays.compactMap { Int($0) }
        let daysOfWeek = rawDays.compactMap { FocusSchedule.Weekday(rawValue: $0) }
        
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
    
    private func syncAndApplyAppLimits() async {
        guard let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent"),
              let childID = defaults.string(forKey: "myChildRecordID") else {
            return
        }
        
        let center = DeviceActivityCenter()
        
        do {
            // --- ШАГ 1: ПОЛУЧАЕМ "ЧТО ДОЛЖНО БЫТЬ" (новые правила из CloudKit) ---
            let predicate = NSPredicate(format: "targetChildID == %@", childID)
            let query = CKQuery(recordType: "AppLimit", predicate: predicate)
            let (matchResults, _) = try await database.records(matching: query)
            let remoteLimits: [AppLimit] = try matchResults.compactMap {(recordID, result) in
                let record = try result.get()
                guard let tokenData = record["appTokenData"] as? Data,
                      let timeLimit = record["timeLimit"] as? TimeInterval,
                      let token = try? JSONDecoder().decode(ApplicationToken.self, from: tokenData)
                else { return nil }
                return AppLimit(token: token, time: timeLimit)
            }
        
            // Сохраняем свежие правила в UserDefaults для Monitor
            saveLimitsToUserDefaults(remoteLimits)
            
            // Группируем новые правила по времени
            let remoteGroupedLimits = Dictionary(grouping: remoteLimits, by: { $0.time })
            // Создаем множество ИМЕН активностей, которые должны быть
            let remoteActivityNames = Set(remoteGroupedLimits.keys.map { timeLimit in
                DeviceActivityName("limit_\(Int(timeLimit))")
            })

            // --- ШАГ 2: ПОЛУЧАЕМ "ЧТО ЕСТЬ СЕЙЧАС" (активные мониторы в системе) ---
            let currentActivities = center.activities
            // Фильтруем, чтобы получить только наши лимиты, игнорируя фокусы
            let currentLimitActivityNames = Set(currentActivities.filter { $0.rawValue.starts(with: "limit_") })
            
            // --- ШАГ 3: СРАВНИВАЕМ И СИНХРОНИЗИРУЕМ ---
            
            // A) Определяем, что нужно УДАЛИТЬ
            // (То, что есть в системе, но чего нет в новых правилах)
            let activitiesToDelete = currentLimitActivityNames.subtracting(remoteActivityNames)
            if !activitiesToDelete.isEmpty {
                center.stopMonitoring(Array(activitiesToDelete))
                print("🗑 [NSE] Удалено \(activitiesToDelete.count) устаревших мониторов лимитов.")
            }
            
            // B) Определяем, что нужно ДОБАВИТЬ
            // (То, что есть в новых правилах, но чего еще нет в системе)
            let activitiesToAdd = remoteActivityNames.subtracting(currentLimitActivityNames)
            for activityName in activitiesToAdd {
                // Извлекаем время из имени (например, из "limit_3600")
                let eventName = DeviceActivityEvent.Name("ThresholdReached")
                let timeString = activityName.rawValue.replacingOccurrences(of: "limit_", with: "")
                guard let timeLimit = TimeInterval(timeString),
                      let appsInGroup = remoteGroupedLimits[timeLimit] else { continue }
                
                let tokens = Set(appsInGroup.map { $0.token })
                let schedule = DeviceActivitySchedule(
                    intervalStart: DateComponents(hour: 0, minute: 0),
                    intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
                    repeats: true
                )
                let event = DeviceActivityEvent(applications: tokens, threshold: DateComponents(second: Int(timeLimit)))
                
                do {
                    try center.startMonitoring(activityName, during: schedule, events: [eventName: event])
                    print("✅ [NSE] Запущен новый мониторинг '\(activityName.rawValue)'")
                } catch {
                    print("❌ [NSE] Ошибка запуска нового мониторинга '\(activityName.rawValue)': \(error)")
                }
            }
            
            print("🔄 [NSE] Синхронизация лимитов завершена.")
            
        } catch {
            print("🛑 [NSE] Критическая ошибка при синхронизации лимитов: \(error).")
            // Здесь мы НЕ сбрасываем все, чтобы не затронуть фокусы
        }
    }
    
    private func saveLimitsToUserDefaults(_ limits: [AppLimit]) {
        guard let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") else { return }
        do {
            let data = try JSONEncoder().encode(limits)
            defaults.set(data, forKey: "app_limits_cache")
            print("✅ [NSE] Лимиты сохранены в UserDefaults для Monitor.")
        } catch {
            print("❌ [NSE] Ошибка сохранения лимитов в UserDefaults: \(error)")
        }
    }
    
    func fetchAndApplyAppBlocks() async {
        guard let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent"),
              let childID = defaults.string(forKey: "myChildRecordID") else {
            return
        }
        let store = ManagedSettingsStore()
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        let query = CKQuery(recordType: "AppBlock", predicate: predicate)

        do {
            let (matchResults, _) = try await database.records(matching: query)

            var appTokens: Set<ApplicationToken> = []

            for (_, result) in matchResults {
                let record = try result.get()
                if let tokenData = record["appTokenData"] as? Data,
                   let token = try? JSONDecoder().decode(ApplicationToken.self, from: tokenData) {
                    appTokens.insert(token)
                }
            }

            store.shield.applications = appTokens
            print("✅ Блокировки применены для \(appTokens.count) приложений.")

        } catch {
            print("ℹ️ Ошибка загрузки блокировок или блокировки не найдены: \(error). Снимаем ограничения.")
            store.shield.applications = nil
        }
    }
    
    private func syncAndApplyWebBlocks() async {
        // 1. Получаем ID ребенка из AppGroup
        guard let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent"),
              let childID = defaults.string(forKey: "myChildRecordID") else {
            print("❌ [NSE] WebBlocks: Не удалось получить ID ребенка из AppGroup.")
            return
        }
        
        // 2. Создаем запрос в CloudKit для записей типа `WebDomainBlock`
        let predicate = NSPredicate(format: "targetChildID == %@", childID)
        let query = CKQuery(recordType: "WebDomainBlock", predicate: predicate)
        
        do {
            // 3. Выполняем запрос
            let (matchResults, _) = try await database.records(matching: query)
            
            // 4. Извлекаем из каждой записи поле `domain` и собираем их в Set<String>
            let domainsToBlock: Set<String> = Set(try matchResults.compactMap {
                try $0.1.get()["domain"] as? String
            })
            
            let domains: Set<WebDomain> = Set(domainsToBlock.compactMap {
                WebDomain(domain: $0)
            })
            
            // 5. ✅ ПРИМЕНЯЕМ БЛОКИРОВКУ ПРАВИЛЬНЫМ СПОСОБОМ
            
            if domainsToBlock.isEmpty {
                // Если список пуст, отключаем фильтрацию
                store.webContent.blockedByFilter = WebContentSettings.FilterPolicy.none  // filterPolicy = .allowAll
                print("✅ [NSE] Все web-блокировки сняты.")
            } else {
                // Если есть домены для блокировки:
                // a) Включаем политику фильтрации (например, общую)
                //store.webContent.filterPolicy = .limitAdultContent
                // b) Устанавливаем наш конкретный список заблокированных сайтов
                store.webContent.blockedByFilter = .specific(domains) //blockedSites = domainsToBlock
                print("✅ [NSE] Web-блокировки применены для \(domainsToBlock.count) доменов.")
            }
            
        } catch {
            print("ℹ️ [NSE] Ошибка загрузки web-блокировок: \(error). Снимаем ограничения.")
            // В случае любой ошибки безопаснее всего снять ограничения
//            store.webContent.filterPolicy = .allowAll
        }
    }
}

struct AppLimit: Codable {
    let token: ApplicationToken
    var time: TimeInterval
}
