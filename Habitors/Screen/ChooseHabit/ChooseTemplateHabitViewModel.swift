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
}
