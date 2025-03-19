//
//  AppCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 17/3/25.
//

import Foundation

class AppCoordinator: WindowBaseCoordinator {
    private var homeCoordinator: HomeCoordinator?
    
    override func start() {
        super.start()
        routeToHome()
    }
    
    private func routeToHome() {
        self.homeCoordinator = HomeCoordinator(window: window)
        self.homeCoordinator?.start()
        self.addChild(homeCoordinator)
    }
}
