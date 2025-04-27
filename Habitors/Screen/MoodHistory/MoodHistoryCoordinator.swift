//
//  MoodHistoryCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 19/4/25.
//

import UIKit

struct MoodHistoryWantToDismissEvent: CoordinatorEvent { }

final class MoodHistoryCoordinator: NavigationBaseCoordinator {
    var needBackToHome: Bool
    
    init(needBackToHome: Bool, navigationController: UINavigationController) {
        self.needBackToHome = needBackToHome
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: MoodHistoryViewController = {
        let viewModel = MoodHistoryViewModel()
        let controller = MoodHistoryViewController(viewModel: viewModel, coordinator: self)
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
    
    func dismiss() {
        if needBackToHome {
            self.send(event: MoodHistoryWantToDismissEvent())
        } else {
            self.stop()
        }
    }
}
