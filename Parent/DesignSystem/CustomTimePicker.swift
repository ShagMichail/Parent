//
//  CustomTimePicker.swift
//  Parent
//
//  Created by Michail Shagovitov on 26.12.2025.
//

import SwiftUI
import UIKit

struct CustomTimePicker: UIViewRepresentable {
    @Binding var time: Date
    
    let selectedColor: UIColor
    let unselectedColor: UIColor
    
    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        if let hour = components.hour {
            uiView.selectRow(hour, inComponent: 0, animated: true)
        }
        if let minute = components.minute {
            uiView.selectRow(minute, inComponent: 1, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: CustomTimePicker
        
        let hours = Array(0...23)
        let minutes = Array(stride(from: 0, to: 60, by: 1))

        init(parent: CustomTimePicker) {
            self.parent = parent
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 2
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return component == 0 ? hours.count : minutes.count
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = UILabel()
            label.textAlignment = .center
            
            let isSelected = pickerView.selectedRow(inComponent: component) == row
            
            label.textColor = isSelected ? parent.selectedColor : parent.unselectedColor
            label.font = UIFont(name: "Inter-Medium", size: 26)
            
            if component == 0 {
                label.text = "\(hours[row])"
            } else {
                label.text = "\(minutes[row])"
            }
            
            return label
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let calendar = Calendar.current
            
            let selectedHour = hours[pickerView.selectedRow(inComponent: 0)]
            let selectedMinute = minutes[pickerView.selectedRow(inComponent: 1)]
            
            if let newDate = calendar.date(bySettingHour: selectedHour, minute: selectedMinute, second: 0, of: Date()) {
                parent.time = newDate
            }
            
            pickerView.reloadAllComponents()
        }
        
        // Настраиваем высоту строк
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 40
        }
    }
}
