//
//  SplashCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import UIKit

final class SplashCoordinator: WindowBaseCoordinator {
    lazy var controller: SplashViewController = {
        let viewModel = SplashViewModel()
        let controller = SplashViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        window.rootViewController = controller
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
    }

    override func stop(completion: (() -> Void)? = nil) {
        super.stop(completion: completion)
    }
}
