//
//  HomeViewController.swift
//  Habitors
//
//  Created by CucPhung on 13/3/25.
//

import UIKit
import RxSwift

class HomeViewController: BaseViewController {
    var viewModel: HomeViewModel
    weak var coordinator: HomeCoordinator?

    init(viewModel: HomeViewModel, coordinator: HomeCoordinator) {
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
    
    override func viewDidFirstAppear() {
        super.viewDidFirstAppear()
        viewModel.input.selectDate.onNext(Date())
    }

    // MARK: - Config
    func config() {
        insertFullScreen(HomeView(viewModel: viewModel))
        configViewModelInput()
        configViewModelOutput()
        configRoutingOutput()
    }

    func configViewModelInput() {

    }

    func configViewModelOutput() {
        
    }

    func configRoutingOutput() {
        viewModel.routing.routeToCreate.subscribe(onNext: { [weak self] in
            self?.coordinator?.routeToCreate()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToHabitRecord.subscribe(onNext: { [weak self] record in
            self?.coordinator?.routeToHabitRecord(record: record)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToOverview.subscribe(onNext: { [weak self] in
            self?.coordinator?.routeToOverview()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.showAlert.subscribe(onNext: { [weak self] msg in
            self?.presentAlert(title: "Alert", message: msg)
        }).disposed(by: self.disposeBag)
    }
}
