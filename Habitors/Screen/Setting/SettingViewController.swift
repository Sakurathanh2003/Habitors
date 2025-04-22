//
//  SettingViewController.swift
//  Habitors
//
//  Created by Thanh Vu on 22/4/25.
//

import UIKit
import RxSwift

class SettingViewController: BaseViewController {
    var viewModel: SettingViewModel
    weak var coordinator: SettingCoordinator?

    init(viewModel: SettingViewModel, coordinator: SettingCoordinator) {
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
        insertFullScreen(SettingView(viewModel: viewModel))
        configViewModelInput()
        configViewModelOutput()
        configRoutingOutput()
    }

    func configViewModelInput() {

    }

    func configViewModelOutput() {
        
    }

    func configRoutingOutput() {
        viewModel.routing.stop.subscribe(onNext: { [weak self] in
            self?.coordinator?.stop()
        }).disposed(by: self.disposeBag)
    }
}
