//
//  ListHabitViewModel.swift
//  Habitors
//
//  Created by Thanh Vu on 6/5/25.
//

import UIKit
import RxSwift

struct ListHabitViewModelInput: InputOutputViewModel {
    var selectHabit = PublishSubject<Habit>()
    var didTapDelete = PublishSubject<()>()
}

struct ListHabitViewModelOutput: InputOutputViewModel {

}

struct ListHabitViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var routeToHabit = PublishSubject<Habit>()
    
    var presentDeleteDialog = PublishSubject<()>()
    var presentAlert = PublishSubject<String>()
}

final class ListHabitViewModel: BaseViewModel<ListHabitViewModelInput, ListHabitViewModelOutput, ListHabitViewModelRouting> {
    @Published var habits: [Habit] = []
    @Published var selectedHabit: [String] = []
    @Published var isSelectMode: Bool = false
    
    override init() {
        super.init()
        configInput()
        getData()
    }
    
    private func configInput() {
        input.selectHabit.subscribe(onNext: { [weak self] habit in
            guard let self else {
                return
            }
            
            if isSelectMode {
                if let index = selectedHabit.firstIndex(of: habit.id) {
                    selectedHabit.remove(at: index)
                } else {
                    selectedHabit.append(habit.id)
                }
                return
            }
            
            self.routing.routeToHabit.onNext(habit)
        }).disposed(by: self.disposeBag)
        
        input.didTapDelete.subscribe(onNext: { [weak self] _ in
            self?.routing.presentDeleteDialog.onNext(())
        }).disposed(by: self.disposeBag)
    }
    
    override func configNotificationCenter() {
        super.configNotificationCenter()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: .deleteHabitItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: .updateHabitItem, object: nil)
    }
    
    @objc private func getData() {
        self.habits = HabitDAO.shared.getAll().sorted(by: { $0.name <= $1.name })
    }
    
    func isSelected(habit: Habit) -> Bool {
        return selectedHabit.contains(where: { $0 == habit.id })
    }
    
    func delete() {
        let selectedHabit = selectedHabit.compactMap({ HabitDAO.shared.getHabit(id: $0) })
        
        for habit in selectedHabit {
            HabitDAO.shared.deleteObject(item: habit)
        }
        
        self.routing.presentAlert.onNext(isVietnameseLanguage ? "Xoá thành công" : "Delete successful")
        self.isSelectMode = false
    }
}
