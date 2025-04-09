//
//  HabitRecordCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 26/3/25.
//

import UIKit

final class HabitRecordCoordinator: NavigationBaseCoordinator {
    private var createHabitCoordinator: CreateCoordinator?
    
    let record: HabitRecord
    
    init(record: HabitRecord, navigationController: UINavigationController) {
        self.record = record
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: HabitRecordViewController = {
        let viewModel = HabitRecordViewModel(record: record)
        let controller = HabitRecordViewController(viewModel: viewModel, coordinator: self)
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
    
    func routeToCreate(habit: Habit?) {
        self.createHabitCoordinator = CreateCoordinator(habit: habit, controller: controller)
        self.createHabitCoordinator?.start()
        self.addChild(createHabitCoordinator)
    }
}
