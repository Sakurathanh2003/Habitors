//
//  CreateViewModel.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import UIKit
import SwiftUI
import RxSwift

struct CreateViewModelInput: InputOutputViewModel {
    var selectRepeatDay = PublishSubject<Int>()
    var selectAddReminder = PublishSubject<()>()
    
    var saveReminder = PublishSubject<Time?>()
    var selectEditReminder = PublishSubject<Time>()
    
    var selectStartedDate = PublishSubject<Date?>()
    var selectFrequency = PublishSubject<Frequency?>()
}

struct CreateViewModelOutput: InputOutputViewModel {

}

struct CreateViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
}

final class CreateViewModel: BaseViewModel<CreateViewModelInput, CreateViewModelOutput, CreateViewModelRouting> {
    let habit: Habit?
    
    @Published var name: String = ""
    @Published var isTurnOnReminder: Bool = false
    
    // Date Start
    @Published var startedDate: Date = Date()
    
    @Published var frequency: Frequency = .init()

    
    // Goal
    @Published var goalUnit: GoalUnit = .count
    @Published var goalValue: Int = 1
    
    // Period
    @Published var isMorning: Bool = false
    @Published var isEvening: Bool = false
    
    // Repeat
    @Published var repeatDay = [Int]()
    
    @Published var isShowingCalendar: Bool = false
    @Published var isShowingChangeValueGoal: Bool = false
    @Published var isShowingFrequency: Bool = false

    @Published var times = [Time]()
    @Published var isShowingTimeDialog: Bool = false
    @Published var editTimeIndex: Int? = nil
    
    init(habit: Habit?) {
        self.habit = habit
        
        if let habit {
            self.goalUnit = habit.goalUnit
            self.goalValue = habit.goalValue
        }
        
        super.init()
        self.configInput()
    }
    
    private func configInput() {
        input.selectRepeatDay.subscribe(onNext: { [unowned self] stt in
            if let index = repeatDay.firstIndex(of: stt) {
                repeatDay.remove(at: index)
            } else {
                repeatDay.append(stt)
            }
        }).disposed(by: self.disposeBag)
        
        input.selectAddReminder.subscribe(onNext: { [unowned self] stt in
            withAnimation {
                self.isShowingTimeDialog = true
            }
        }).disposed(by: self.disposeBag)
        
        input.selectEditReminder.subscribe(onNext: { [unowned self] time in
            if let index = times.firstIndex(where: { $0.hour == time.hour && $0.minutes == time.minutes }) {
                self.editTimeIndex = index
                withAnimation {
                    self.isShowingTimeDialog = true
                }
            }
           
        }).disposed(by: self.disposeBag)
        
        input.saveReminder.subscribe(onNext: { [unowned self] time in
            withAnimation {
                self.isShowingTimeDialog = false
            }
            
            if let time {
                if let index = editTimeIndex {
                    self.times[index] = time
                } else if !times.contains(where: { $0.hour == time.hour && $0.minutes == time.minutes }) {
                    self.times.append(time)
                    self.times.sort(by: {
                        if $0.hour == $1.hour {
                            return $0.minutes < $1.minutes
                        }
                        
                        return $0.hour < $1.hour
                    })
                }
            }
        }).disposed(by: self.disposeBag)
        
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
    
    func didSelectedRepeatDay(_ index: Int) -> Bool {
        return repeatDay.contains(where: { $0 == index })
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
}
