//
//  ListHabitViewController.swift
//  Habitors
//
//  Created by Thanh Vu on 6/5/25.
//

import UIKit
import RxSwift

class ListHabitViewController: BaseViewController {
    var viewModel: ListHabitViewModel
    weak var coordinator: ListHabitCoordinator?

    init(viewModel: ListHabitViewModel, coordinator: ListHabitCoordinator) {
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
        insertFullScreen(ListHabitView(viewModel: viewModel))
        configRoutingOutput()
    }

    func configRoutingOutput() {
        viewModel.routing.stop.subscribe(onNext: { [weak self] _ in
            self?.coordinator?.stop()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToHabit.subscribe(onNext: { [weak self] habit in
            self?.coordinator?.routeToEditHabit(habit: habit)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.presentDeleteDialog.subscribe(onNext: { [weak self] in
            self?.coordinator?.presentDeleteDialog()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.presentAlert.subscribe(onNext: { [weak self] message in
            self?.presentAlert(title: "", message: message)
        }).disposed(by: self.disposeBag)
    }
}
