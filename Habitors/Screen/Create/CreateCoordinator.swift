//
//  CreateCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import UIKit

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
        self.parentVC?.view.transform = .init(translationX: 0, y: UIScreen.main.bounds.height)
        controller.dismiss(animated: true) { [weak self] in
            self?.parentVC?.dismiss(animated: false)
            self?.send(event: UserDidCreateHabit())
        }
    }
}
