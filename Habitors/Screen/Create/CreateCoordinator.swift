//
//  CreateCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import UIKit

final class CreateCoordinator: Coordinator {
    lazy var controller: CreateViewController = {
        let viewModel = CreateViewModel()
        let controller = CreateViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
    }

    override func stop(completion: (() -> Void)? = nil) {
        super.stop(completion: completion)
    }
}
