//
//  TodayOverviewViewController.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 7/4/25.
//

import UIKit
import RxSwift

class TodayOverviewViewController: BaseViewController {
    var viewModel: TodayOverviewViewModel
    weak var coordinator: TodayOverviewCoordinator?

    init(viewModel: TodayOverviewViewModel, coordinator: TodayOverviewCoordinator) {
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
        insertFullScreen(TodayOverviewView(viewModel: viewModel))
        configViewModelInput()
        configViewModelOutput()
        configRoutingOutput()
    }

    func configViewModelInput() {

    }

    func configViewModelOutput() {
        
    }

    func configRoutingOutput() {
        viewModel.routing.stop.subscribe(onNext: { [weak self] record in
            self?.coordinator?.stop()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToHabitRecord.subscribe(onNext: { [weak self] record in
            self?.coordinator?.routeToHabitRecord(record: record)
        }).disposed(by: self.disposeBag)
    }
}
