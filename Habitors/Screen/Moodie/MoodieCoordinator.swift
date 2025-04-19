//
//  MoodieCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 16/4/25.
//

import UIKit
import SwiftUI

final class MoodieCoordinator: NavigationBaseCoordinator {
    var historyCoodinator: MoodHistoryCoordinator?
    lazy var controller: MoodieViewController = {
        let viewModel = MoodieViewModel()
        let controller = MoodieViewController(viewModel: viewModel, coordinator: self)
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
    
    override func handle(event: any CoordinatorEvent) -> Bool {
        if event is MoodHistoryWantToDismissEvent {
            self.stop()
            return true
        }
        
        return false
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is MoodHistoryCoordinator {
            self.historyCoodinator = nil
        }
    }
    
    func routeToHistory() {
        self.historyCoodinator = MoodHistoryCoordinator(navigationController: navigationController)
        self.historyCoodinator!.start()
        self.addChild(historyCoodinator)
    }
}
