//
//  CreateCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import UIKit

final class CreateCoordinator: PresentedCoordinator {
    
    lazy var controller: CreateViewController = {
        let viewModel = CreateViewModel()
        let controller = CreateViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        controller.modalPresentationStyle = .overFullScreen
        parentVC?.present(controller, animated: true)
    }

    override func stop(completion: (() -> Void)? = nil) {
        controller.dismiss(animated: true)
        super.stop(completion: completion)
    }
}
