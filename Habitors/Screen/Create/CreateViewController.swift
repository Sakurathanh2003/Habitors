//
//  CreateViewController.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import UIKit

class CreateViewController: UIViewController {
    var viewModel: CreateViewModel
    weak var coordinator: CreateCoordinator?

    init(viewModel: CreateViewModel, coordinator: CreateCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.config()
    }

    // MARK: - Config
    func config() {
        configViewModelInput()
        configViewModelOutput()
        configRoutingOutput()
    }

    func configViewModelInput() {

    }

    func configViewModelOutput() {
        
    }

    func configRoutingOutput() {

    }
}