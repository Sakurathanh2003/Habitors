//
//  CreateCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import UIKit
import RxSwift

struct UserDidCreateHabit: CoordinatorEvent { }

final class CreateCoordinator: PresentedCoordinator {
    
    let habit: Habit?
    
    init(habit: Habit? = nil, controller: UIViewController) {
        self.habit = habit
        super.init(controller: controller)
    }
    
    lazy var controller: CreateViewController = {
        let viewModel = CreateViewModel(habit: habit)
        let controller = CreateViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        controller.modalPresentationStyle = .overFullScreen
        parentVC?.present(controller, animated: true)
    }

    override func stop(completion: (() -> Void)? = nil) {
        controller.dismiss(animated: true)
        super.stop(completion: completion)
    }
    
    func didCreateHabit() {
        let alert = UIAlertController(title: "", message: "Create Habit success", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let self else {
                return
            }
            
            self.parentVC?.view.transform = .init(translationX: 0, y: UIScreen.main.bounds.height)
            controller.dismiss(animated: true) { [weak self] in
                self?.parentVC?.dismiss(animated: false)
                self?.send(event: UserDidCreateHabit())
            }
        }
        
        alert.addAction(confirmAction)
        controller.present(alert, animated: true)
    }
    
    func presentDeleteDialog() {
        let alert = UIAlertController(title: User.isVietnamese ? "Xác nhận" : "Confirm",
                                      message: User.isVietnamese ? "Bạn có chắc chắn muốn xoá không? Hành động của bạn không thể quay lại" : "Are you sure want to delete? Your action can't undo", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: User.isVietnamese ? "Huỷ" : "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: User.isVietnamese ? "Chắc chắn" : "Confirm", style: .destructive) { [weak self] _ in
            self?.controller.viewModel.input.delete.onNext(())
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        self.controller.present(alert, animated: true)
    }
}
