//
//  MoodieViewController.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 16/4/25.
//

import UIKit

class MoodieViewController: BaseViewController {
    var viewModel: MoodieViewModel
    weak var coordinator: MoodieCoordinator?

    init(viewModel: MoodieViewModel, coordinator: MoodieCoordinator) {
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
        insertFullScreen(MoodieView(viewModel: viewModel))
        configRoutingOutput()
    }

    func configRoutingOutput() {

    }
}
