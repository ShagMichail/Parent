//
//  Scheduling.swift
//  Parent
//
//  Created by Михаил Шаговитов on 05.12.2025.
//

// Scheduling.swift

import Foundation
import DeviceActivity
import os.log

// Имена для наших фоновых задач, вынесены для общего доступа
let FREQUENT_CHECK_ACTIVITY_NAME = DeviceActivityName("frequentCheck")
let FORCE_CHECK_ACTIVITY_NAME = DeviceActivityName("force-check")

// Интервал для регулярных проверок (в секундах). 10 минут - хороший баланс.
let CHECK_INTERVAL: TimeInterval = 10 * 60

/// Планирует следующую регулярную фоновую проверку.
/// Эту функцию может вызывать и основное приложение, и расширение.
func scheduleNextDeviceActivityCheck() {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Scheduling")
    let center = DeviceActivityCenter()

    // Останавливаем все предыдущие плановые проверки, чтобы не было дублей
    center.stopMonitoring([FREQUENT_CHECK_ACTIVITY_NAME])
    
    // Расписание на 30 секунд, которое начнется ЧЕРЕЗ CHECK_INTERVAL.
    let now = Date()
    let nextCheckTime = now.addingTimeInterval(CHECK_INTERVAL)

    let schedule = DeviceActivitySchedule(
        intervalStart: Calendar.current.dateComponents([.hour, .minute, .second], from: nextCheckTime),
        intervalEnd: Calendar.current.dateComponents([.hour, .minute, .second], from: nextCheckTime.addingTimeInterval(30)),
        repeats: false // НЕ ПОВТОРЯТЬ
    )
    
    do {
        try center.startMonitoring(FREQUENT_CHECK_ACTIVITY_NAME, during: schedule)
        logger.info("✅ Следующая плановая фоновая проверка запланирована на ~\(nextCheckTime.formatted(date: .omitted, time: .shortened))")
    } catch {
        logger.error("🚨 Ошибка планирования плановой проверки: \(error)")
    }
}
