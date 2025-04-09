//
//  TodayOverviewCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 7/4/25.
//

import UIKit

final class TodayOverviewCoordinator: NavigationBaseCoordinator {
    private var habitRecordCoordinator: HabitRecordCoordinator?
    
    lazy var controller: TodayOverviewViewController = {
        let viewModel = TodayOverviewViewModel()
        let controller = TodayOverviewViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        navigationController.pushViewController(controller, animated: true)
    }

    override func stop(completion: (() -> Void)? = nil) {
        if navigationController.topViewController == controller {
            navigationController.popViewController(animated: true)
        } else {
            navigationController.viewControllers.removeAll(where: { $0 == controller })
        }
        
        super.stop(completion: completion)
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is HabitRecordCoordinator {
            self.habitRecordCoordinator = nil
        }
    }
    
    func routeToHabitRecord(record: HabitRecord) {
        self.habitRecordCoordinator = HabitRecordCoordinator(record: record, navigationController: controller.navigationController!)
        self.habitRecordCoordinator?.start()
        self.addChild(habitRecordCoordinator)
    }
}
