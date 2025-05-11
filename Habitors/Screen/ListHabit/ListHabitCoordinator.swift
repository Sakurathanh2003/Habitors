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
    
    func presentDeleteDialog() {
        let alert = UIAlertController(title: User.isVietnamese ? "Xác nhận" : "Confirm",
                                      message: User.isVietnamese ? "Bạn có chắc chắn muốn xoá không? Hành động của bạn không thể quay lại" : "Are you sure want to delete? Your action can't undo", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: User.isVietnamese ? "Huỷ" : "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: User.isVietnamese ? "Chắc chắn" : "Confirm", style: .destructive) { [weak self] _ in
            self?.controller.viewModel.delete()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        self.controller.present(alert, animated: true)
    }
}
