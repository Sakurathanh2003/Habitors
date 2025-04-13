//
//  HomeCoordinator.swift
//  Habitors
//
//  Created by CucPhung on 13/3/25.
//

import UIKit

final class HomeCoordinator: WindowBaseCoordinator {
    
    private var chooseTemplateCoordinator: ChooseTemplateHabitCoordinator?
    private var habitRecordCoordinator: HabitRecordCoordinator?
    
    private var todayOverviewCoordinator: TodayOverviewCoordinator?
    
    lazy var controller: HomeViewController = {
        let viewModel = HomeViewModel()
        let controller = HomeViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    override func handle(event: any CoordinatorEvent) -> Bool {
        
        
        return false
    }

    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is ChooseTemplateHabitCoordinator {
            self.chooseTemplateCoordinator = nil
        }
        
        if child is HabitRecordCoordinator {
            self.habitRecordCoordinator = nil
        }
    }
    
    func routeToCreate() {
        self.chooseTemplateCoordinator = ChooseTemplateHabitCoordinator(controller: controller)
        self.chooseTemplateCoordinator?.start()
        self.addChild(chooseTemplateCoordinator)
    }
    
    func routeToHabitRecord(record: HabitRecord) {
        self.habitRecordCoordinator = HabitRecordCoordinator(record: record, navigationController: controller.navigationController!)
        self.habitRecordCoordinator?.start()
        self.addChild(habitRecordCoordinator)
    }
    
    func routeToOverview() {
        self.todayOverviewCoordinator = TodayOverviewCoordinator(navigationController: controller.navigationController!)
        self.todayOverviewCoordinator?.start()
        self.addChild(todayOverviewCoordinator)
    }
}
