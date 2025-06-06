//
//  MoodieViewController.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 16/4/25.
//

import RxSwift
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
        viewModel.routing.stop.subscribe(onNext: { [weak self] in
            self?.coordinator?.stop()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.history.subscribe(onNext: { [weak self] needBackToHome in
            self?.coordinator?.routeToHistory(needBackToHome: needBackToHome)
        }).disposed(by: self.disposeBag)
    }
}
