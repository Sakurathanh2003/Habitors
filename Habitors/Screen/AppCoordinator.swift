//
//  AppCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 17/3/25.
//

import Foundation

class AppCoordinator: WindowBaseCoordinator {
    private var homeCoordinator: HomeCoordinator?
    private var splashCoordinator: SplashCoordinator?
    
    override func start() {
        super.start()
        routeToSplash()
    }
    
    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is SplashCoordinator {
            self.splashCoordinator = nil
            self.routeToHome()
        }
    }
    
    private func routeToHome() {
        self.homeCoordinator = HomeCoordinator(window: window)
        self.homeCoordinator?.start()
        self.addChild(homeCoordinator)
    }
    
    private func routeToSplash() {
        self.splashCoordinator = SplashCoordinator(window: window)
        self.splashCoordinator?.start()
        self.addChild(splashCoordinator)
    }
}
