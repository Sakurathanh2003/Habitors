//
//  CreateViewModel.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import UIKit
import SwiftUI
import RxSwift
import HealthKit
import SVProgressHUD

struct CreateViewModelInput: InputOutputViewModel {
    var selectAddReminder = PublishSubject<()>()
    
    var selectStartedDate = PublishSubject<Date?>()
    var selectFrequency = PublishSubject<Frequency?>()
    var selectIcon = PublishSubject<String?>()
    
    var save = PublishSubject<()>()
    
    var wantToDelete = PublishSubject<()>()
    var delete = PublishSubject<()>()
    
    var didSelectGoalView = PublishSubject<()>()
}

struct CreateViewModelOutput: InputOutputViewModel {

}

struct CreateViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var showAlert = PublishSubject<String>()
    var didCreate = PublishSubject<()>()
    
    var needPermisson = PublishSubject<String>()
}

final class CreateViewModel: BaseViewModel<CreateViewModelInput, CreateViewModelOutput, CreateViewModelRouting> {
    let habit: Habit?
    
    @Published var name: String = ""
    @Published var icon: String?

    // Date Start
    @Published var startedDate: Date = Date()
    @Published var frequency: Frequency = .init()

    // Goal
    @Published var goalUnit: GoalUnit = .count
    @Published var goalValue: Double = 1
    
    @Published var isShowingChangeValueGoal: Bool = false
    @Published var isShowingSelectGoalView: Bool = false
    
    @Published var isShowingCalendar: Bool = false
    @Published var isShowingFrequency: Bool = false
    @Published var isShowingIcon: Bool = false
    @Published var isShowingDeleteDialog: Bool = false
    
    init(habit: Habit?) {
        self.habit = habit
        
        if let habit {
            self.name = habit.name
            self.icon = habit.icon
            self.goalUnit = habit.goalUnit
            self.goalValue = habit.goalValue
            self.startedDate = habit.startedDate
            self.frequency = habit.frequency
        }
        
        super.init()
        self.configInput()
    }
    
    private func configInput() {
        input.selectStartedDate.subscribe(onNext: { [unowned self] date in
            withAnimation {
                self.isShowingCalendar = false
            }
            
            if let date {
                self.startedDate = date
            }
        }).disposed(by: self.disposeBag)
        
        input.selectFrequency.subscribe(onNext: { [unowned self] frequency in
            if let frequency {
                self.frequency = frequency
            }
            
            self.isShowingFrequency = false
        }).disposed(by: self.disposeBag)
        
        input.selectIcon.subscribe(onNext: { [unowned self] iconName in
            if let iconName {
                self.icon = iconName
            }
            
            self.isShowingIcon = false
        }).disposed(by: self.disposeBag)
        
        input.save.subscribe(onNext: { [unowned self] _ in
            self.validateData { [weak self] canSet in
                guard let self, canSet else {
                    return
                }
                
                if habit != nil {
                    if isExits {
                        updateHabit()
                    } else {
                        addHabit()
                    }
                } else {
                    addHabit()
                }
            }
        }).disposed(by: self.disposeBag)
        
        input.wantToDelete.subscribe(onNext: { [unowned self] _ in
            withAnimation {
                self.isShowingDeleteDialog = true
            }
        }).disposed(by: self.disposeBag)
        
        input.delete.subscribe(onNext: { [unowned self] _ in
            guard let habit else {
                return
            }
            
            HabitDAO.shared.deleteObject(item: habit)
            self.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.didSelectGoalView.subscribe(onNext: { [unowned self] _ in
            withAnimation {
                if isTemplate || isExits {
                    isShowingChangeValueGoal = true
                } else {
                    isShowingSelectGoalView = true
                }
            }
        }).disposed(by: self.disposeBag)
    }
    
    // MARK: - Add Habit
    private func addHabit() {
        let habit = Habit(id: habit?.id ?? UUID().uuidString,
                          name: self.name,
                          icon: icon!,
                          goalUnit: self.goalUnit,
                          goalValue: self.goalValue,
                          isTemplate: habit?.isTemplate ?? false,
                          startedDate: self.startedDate.startOfDay,
                          frequency: self.frequency,
                          records: [])
    
        HabitDAO.shared.addObject(item: habit)
        self.routing.didCreate.onNext(())
    }
    
    // MARK: - Update habit
    private func updateHabit() {
        guard let habit else {
            return
        }
        
        habit.name = name
        habit.icon = icon ?? ""
        habit.goalValue = goalValue
        habit.goalUnit = goalUnit
        habit.startedDate = startedDate
        habit.frequency = frequency
        HabitDAO.shared.updateObject(item: habit)
        self.routing.stop.onNext(())
    }
    
    // MARK: - Validate
    func validateData(completion: @escaping (Bool) -> Void) {
        if icon == nil {
            completion(false)
            self.routing.showAlert.onNext("Vui lòng chọn icon cho habit!")
            return
        }
        
        if name.isEmpty {
            completion(false)
            self.routing.showAlert.onNext("Vui lòng nhập tên!")
            return
        }
    
        if let maxValue = goalUnit.maxValue, goalValue > maxValue {
            completion(false)
            self.routing.showAlert.onNext("Vui lòng nhập giá trị nhỏ hơn \(maxValue.text)")
            return
        }
        
        if goalValue <= 0 {
            completion(false)
            self.routing.showAlert.onNext("Vui lòng nhập giá trị lớn hơn 0")
            return
        }
        
        self.checkHealthPermissionIfNeed { [weak self] error  in
            guard let self else {
                return
            }
            
            if let error {
                completion(false)
                self.routing.showAlert.onNext(error)
            } else {
                completion(true)
            }
        }
    }
    
    private func checkHealthPermissionIfNeed(completion: @escaping (String?) -> Void) {
        if let appleService = goalUnit.healthService {
            SVProgressHUD.show()
            appleService.requestAuthorization { [weak self] canRead, canWrite in
                SVProgressHUD.dismiss()
                guard let self else {
                    return
                }
                
                var message: String?
                
                if !canRead {
                    message = goalUnit.permissionReadMessage
                } else if !canWrite {
                    message = goalUnit.permissionReadMessage
                }
                
                DispatchQueue.main.async {
                    completion(message)
                }
            }
        } else {
            completion(nil)
        }
    }
}

// MARK: - Get
extension CreateViewModel {
    var habitStartDateString: String {
        if startedDate.isToday {
            return "Today"
        }
      
        return startedDate.format("dd MMMM yyyy")
    }
    
    var title: String {
        if let habit {
            return habit.name
        }
        
        return "Custom"
    }
    
    var goalSectionTitle: String {
        return "Goal (\(goalUnit.rawValue))"
    }
    
    var canChangeName: Bool {
        if let habit {
            return !habit.isTemplate
        }
        
        return true
    }
    
    var canDelete: Bool {
        isExits
    }
    
    var isTemplate: Bool {
        return habit?.isTemplate ?? false
    }
    
    var isExits: Bool {
        return HabitDAO.shared.getHabit(id: self.habit?.id ?? "") != nil
    }
}
