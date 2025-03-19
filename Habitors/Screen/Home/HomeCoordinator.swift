//
//  HomeCoordinator.swift
//  Habitors
//
//  Created by CucPhung on 13/3/25.
//

import UIKit

final class HomeCoordinator: WindowBaseCoordinator {
    
    private var chooseTemplateCoordinator: ChooseTemplateHabitCoordinator?
    
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

    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is ChooseTemplateHabitCoordinator {
            self.chooseTemplateCoordinator = nil
        }
    }
    
    func routeToCreate() {
        self.chooseTemplateCoordinator = ChooseTemplateHabitCoordinator(controller: controller)
        self.chooseTemplateCoordinator?.start()
        self.addChild(chooseTemplateCoordinator)
    }
}
