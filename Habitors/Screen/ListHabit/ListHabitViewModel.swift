//
//  ListHabitViewModel.swift
//  Habitors
//
//  Created by Thanh Vu on 6/5/25.
//

import UIKit
import RxSwift

struct ListHabitViewModelInput: InputOutputViewModel {

}

struct ListHabitViewModelOutput: InputOutputViewModel {

}

struct ListHabitViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var routeToHabit = PublishSubject<Habit>()
}

final class ListHabitViewModel: BaseViewModel<ListHabitViewModelInput, ListHabitViewModelOutput, ListHabitViewModelRouting> {
    @Published var habits: [Habit] = []
    
    override init() {
        super.init()
        getData()
    }
    
    override func configNotificationCenter() {
        super.configNotificationCenter()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: .deleteHabitItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: .updateHabitItem, object: nil)
    }
    
    @objc private func getData() {
        self.habits = HabitDAO.shared.getAll().sorted(by: { $0.name <= $1.name })
    }
}
