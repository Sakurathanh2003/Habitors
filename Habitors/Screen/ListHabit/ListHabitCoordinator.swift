//
//  ListHabitCoordinator.swift
//  Habitors
//
//  Created by Thanh Vu on 6/5/25.
//

import UIKit

final class ListHabitCoordinator: NavigationBaseCoordinator {
    private var editHabitCoordinator: CreateCoordinator?

    lazy var controller: ListHabitViewController = {
        let viewModel = ListHabitViewModel()
        let controller = ListHabitViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        navigationController.pushViewController(controller, animated: true)
    }

    override func stop(completion: (() -> Void)? = nil) {
        navigationController.popViewController(animated: true)
        super.stop(completion: completion)
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is CreateCoordinator {
            self.editHabitCoordinator = nil
        }
    }
    
    func routeToEditHabit(habit: Habit) {
        self.editHabitCoordinator = CreateCoordinator(habit: habit, controller: controller)
        self.editHabitCoordinator?.start()
        self.addChild(editHabitCoordinator)
    }
}
