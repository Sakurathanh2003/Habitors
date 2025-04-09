//
//  ChooseTemplateHabitViewController.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import UIKit
import RxSwift

class ChooseTemplateHabitViewController: BaseViewController {
    var viewModel: ChooseTemplateHabitViewModel
    weak var coordinator: ChooseTemplateHabitCoordinator?

    init(viewModel: ChooseTemplateHabitViewModel, coordinator: ChooseTemplateHabitCoordinator) {
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
        insertFullScreen(ChooseTemplateHabitView(viewModel: viewModel))
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
        
        viewModel.routing.routeToCreate.subscribe(onNext: { [weak self] habit in
            self?.coordinator?.routeToCreate(habit: habit)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.showAlert.subscribe(onNext: { [weak self] msg in
            self?.presentAlert(title: "", message: msg)
        }).disposed(by: self.disposeBag)
    }
}

