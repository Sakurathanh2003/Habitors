//
//  ChooseTemplateHabitViewModel.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import UIKit
import RxSwift

struct ChooseTemplateHabitViewModelInput: InputOutputViewModel {
    var selectCustom = PublishSubject<()>()
    var selectTemplate = PublishSubject<Habit>()
}

struct ChooseTemplateHabitViewModelOutput: InputOutputViewModel {

}

struct ChooseTemplateHabitViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var routeToCreate = PublishSubject<Habit?>()
    var showAlert = PublishSubject<String>()
}

final class ChooseTemplateHabitViewModel: BaseViewModel<ChooseTemplateHabitViewModelInput, ChooseTemplateHabitViewModelOutput, ChooseTemplateHabitViewModelRouting> {
    let habitCategories: [HabitCategory] = [
        HabitCategory(id: "appleHealth", name: "Apple Health", icon: "<3", description: "Health habits are linked witth Apple Health App", items: [
            .init(id: "Walk", name: "Walk", icon: "🚶🏻‍♀️‍➡️", goalUnit: .steps, goalValue: 1000, isTemplate: true),
            .init(id: "Exercise", name: "Exercise", icon: "🏃🏻", goalUnit: .exerciseTime, goalValue: 2, isTemplate: true),
            .init(id: "Stand", name: "Stand", icon: "🧍🏻", goalUnit: .standHour, goalValue: 12, isTemplate: true),
            .init(id: "DrinkWater", name: "Drink Water", icon: "💧", goalUnit: .water, goalValue: 2000, isTemplate: true)
        ]),
        HabitCategory(id: "mind", name: "Mind", icon: "", description: "", items: [
            .init(id: "Meditate", name: "Meditate", icon: "🧘🏻‍♂️", goalUnit: .min, goalValue: 30, isTemplate: true),
            .init(id: "Read", name: "Read", icon: "📖", goalUnit: .min, goalValue: 30, isTemplate: true),
            .init(id: "Learn", name: "Learn", icon: "✍🏻", goalUnit: .hours, goalValue: 2, isTemplate: true)
        ])
    ]
    
    override init() {
        super.init()
        configInput()
    }
    
    private func configInput() {
        input.selectCustom.subscribe(onNext: { [weak self] _ in
            self?.routing.routeToCreate.onNext(nil)
        }).disposed(by: self.disposeBag)
        
        input.selectTemplate.subscribe(onNext: { [weak self] habit in
            guard let self else {
                return
            }
            
            if let _ = HabitDAO.shared.getHabit(id: habit.id) {
                self.routing.showAlert.onNext("Habit already exists")
            } else {
                self.routing.routeToCreate.onNext(habit)
            }
        }).disposed(by: self.disposeBag)
    }
    
    var title: String {
        return isVietnameseLanguage ? "Chọn thói quen" : "Choose Habit"
    }
}
