//
//  HomeCoordinator.swift
//  Habitors
//
//  Created by CucPhung on 13/3/25.
//

import UIKit

final class HomeCoordinator: WindowBaseCoordinator {
    
    private var createCoordinator: CreateCoordinator?
    
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
        
        if child is CreateCoordinator {
            self.createCoordinator = nil
        }
    }
    
    func routeToCreate() {
        self.createCoordinator = CreateCoordinator(controller: controller)
        self.createCoordinator?.start()
        self.addChild(createCoordinator)
    }
}
