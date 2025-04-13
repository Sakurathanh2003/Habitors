//
//  HabitRecordViewModel.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 26/3/25.
//

import UIKit
import RxSwift
import SwiftUI
import HealthKit

struct HabitRecordViewModelInput: InputOutputViewModel {
    var addValue = PublishSubject<Double>()
    var didTapEditHabit = PublishSubject<()>()
    
    var startTimer = PublishSubject<()>()
    var stopTimer = PublishSubject<()>()
    var resetTimer = PublishSubject<()>()
    
    var didTapAddValue = PublishSubject<()>()
}

struct HabitRecordViewModelOutput: InputOutputViewModel {

}

struct HabitRecordViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var routeToEditHabit = PublishSubject<Habit>()
    var presentOption = PublishSubject<()>()
    var needToPermission = PublishSubject<String>()
    var showAlert = PublishSubject<String>()
}

final class HabitRecordViewModel: BaseViewModel<HabitRecordViewModelInput, HabitRecordViewModelOutput, HabitRecordViewModelRouting> {
    @Published var record: HabitRecord
    @Published var isCounting: Bool = false
    @Published var isShowingAddValue: Bool = false

    private var timer: Timer?
    
    var title: String {
        return record.habit?.name ?? "Record"
    }
    
    init(record: HabitRecord) {
        self.record = record
        super.init()
        configInput()
        configNotification()
    }
    
    private func configNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateRecordIfNeed(notification:)),
                                               name: .updateHabitItem, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissIfNeed(notification:)),
                                               name: .didDeleteRecord, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateRecordIfNeed(notification:)),
                                               name: .didUpdateRecord, object: nil)
    }
    
    @objc func updateRecordIfNeed(notification: Notification) {
        if let updatedRecord = notification.object as? HabitRecord, updatedRecord.id == record.id && updatedRecord.value != record.value {
            self.record = updatedRecord
            self.objectWillChange.send()
        }
        
        if let updatedHabit = notification.object as? Habit {
            if let record = updatedHabit.records.first(where: { $0.id == record.id }) {
                self.objectWillChange.send()
            }
        }
    }
    
    @objc func dismissIfNeed(notification: Notification) {
        if let deletedRecords = notification.object as? [HabitRecord] {
            if deletedRecords.contains(where: { $0.id == record.id }) {
                self.routing.stop.onNext(())
            }
        }
    }
    
    private func configInput() {
        input.addValue.subscribe(onNext: { [weak self] value in
            guard let self else {
                return
            }
            
            let newValue = currentValue + value
            
            if record.date.isFutureDay {
                self.routing.showAlert.onNext("Vui lòng đợi đúng ngày nhé 😄")
                return
            }
            
            if let maximumAllowedValue = unit.maximumAllowedValue, value > maximumAllowedValue {
                self.routing.showAlert.onNext("Bạn chỉ có thể thêm giá trị không quá \(maximumAllowedValue.text)")
                return
            }
            
            if newValue < 0 && value < 0 {
                return
            }
            
            if let unit = record.habit?.goalUnit, unit.useAppleHealth {
                Task {
                    let canAccess = await HealthManager.shared.canAccess(of: unit)
                    
                    if canAccess {
                        HealthManager.shared.saveData(for: unit, value: value, date: self.recordDate) { [weak self] isSuccess, error in
                            self?.setValue(newValue)
                        }
                    } else {
                        self.routing.needToPermission.onNext(self.record.habit?.goalUnit.permissionMessage ?? "")
                    }
                }
            } else {
                self.setValue(newValue)
            }
        }).disposed(by: self.disposeBag)
        
        input.didTapEditHabit.subscribe(onNext: { [weak self] in
            guard let self else { return }
            
            if let habit = record.habit {
                self.routing.routeToEditHabit.onNext(habit)
            }
        }).disposed(by: self.disposeBag)
        
        input.startTimer.subscribe(onNext: { [weak self] in
            guard let self else { return }
            
            if record.date.isFutureDay {
                self.routing.showAlert.onNext("Vui lòng đợi đúng ngày nhé 😄")
                return
            }
            
            startTimer()
        }).disposed(by: self.disposeBag)
        
        input.stopTimer.subscribe(onNext: { [weak self] in
            guard let self else { return }
            
            stopTimer()
        }).disposed(by: self.disposeBag)
        
        input.resetTimer.subscribe(onNext: { [weak self] in
            guard let self else { return }
            
            stopTimer()
            setValue(0)
        }).disposed(by: self.disposeBag)
        
        input.didTapAddValue.subscribe(onNext: { [weak self] in
            guard let self else { return }
            
            if record.date.isFutureDay {
                self.routing.showAlert.onNext("Vui lòng đợi đúng ngày nhé 😄")
                return
            }
            
            if let unit = record.habit?.goalUnit, unit.useAppleHealth {
                Task {
                    let canAccess = await HealthManager.shared.canAccess(of: unit)
                
                    if canAccess {
                        self.isShowingAddValue = true
                    } else {
                        self.routing.needToPermission.onNext(self.record.habit?.goalUnit.permissionMessage ?? "")
                    }
                }
            } else {
                self.isShowingAddValue = true
            }
        }).disposed(by: self.disposeBag)
    }
    
    private func stopTimer() {
        self.isCounting = false
        timer?.invalidate()
    }
    
    private func startTimer() {
        self.isCounting = true
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self]_ in
            guard let self else {
                return
            }
            
            if currentValue == goalValue {
                stopTimer()
            } else {
                self.setValue(self.currentValue + 1)
            }
        })
    }
    
    private func setValue(_ value: Double) {
        record.value = value
        HabitRecordDAO.shared.updateObject(item: record)
        objectWillChange.send()
    }
}

// MARK: - Get
extension HabitRecordViewModel {
    var unit: GoalUnit {
        return record.habit?.goalUnit ?? .count
    }
    
    var goalValue: Double {
        let value = record.habit?.goalValue ?? 1
        return unit.convertToBaseUnit(from: value)
    }
    
    var currentValue: Double {
        return max(record.value ?? 0, 0)
    }
    
    var progress: CGFloat {
        return min(CGFloat(currentValue) / CGFloat(goalValue), 1)
    }
    
    var timeString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]

        let formattedTime = formatter.string(from: TimeInterval(currentValue)) ?? "00:00"
        return formattedTime
    }
    
    var isTimeUnit: Bool {
        return unit == .secs || unit == .min || unit == .hours
    }
    
    var recordDate: Date {
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.hour, .minute], from: Date())
        var recordComponents = calendar.dateComponents([.year, .month, .day], from: record.date)
        
        recordComponents.hour = nowComponents.hour
        recordComponents.minute = nowComponents.minute
        
        return calendar.date(from: recordComponents) ?? record.date
    }
}
