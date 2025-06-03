//
//  MoodHistoryViewController.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 19/4/25.
//

import UIKit
import RxSwift

class MoodHistoryViewController: BaseViewController {
    var viewModel: MoodHistoryViewModel
    weak var coordinator: MoodHistoryCoordinator?

    init(viewModel: MoodHistoryViewModel, coordinator: MoodHistoryCoordinator) {
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
        insertFullScreen(MoodHistory(viewModel: viewModel))
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
            self?.coordinator?.dismiss()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.presentDeleteDialog.subscribe(onNext: { [weak self] in
            self?.coordinator?.presentDeleteDialog()
        }).disposed(by: self.disposeBag)
    }
}
