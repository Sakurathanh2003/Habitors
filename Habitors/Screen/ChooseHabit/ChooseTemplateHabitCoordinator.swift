//
//  ChooseTemplateHabitCoordinator.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import UIKit

final class ChooseTemplateHabitCoordinator: PresentedCoordinator {
    
    private var createHabitCoordinator: CreateCoordinator?
    
    lazy var controller: ChooseTemplateHabitViewController = {
        let viewModel = ChooseTemplateHabitViewModel()
        let controller = ChooseTemplateHabitViewController(viewModel: viewModel, coordinator: self)
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
    
    override func handle(event: any CoordinatorEvent) -> Bool {
        if event is UserDidCreateHabit {
            stop()
            return true
        }
        
        return false
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is CreateCoordinator {
            self.createHabitCoordinator = nil
            print("dismiss create habit")
        }
    }
    
    func routeToCreate(habit: Habit?) {
        self.createHabitCoordinator = CreateCoordinator(habit: habit, controller: controller)
        self.createHabitCoordinator?.start()
        self.addChild(createHabitCoordinator)
    }
}
