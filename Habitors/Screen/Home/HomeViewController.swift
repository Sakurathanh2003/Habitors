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
        configRoutingOutput()
    }

    func configRoutingOutput() {
        viewModel.routing.routeToCreate.subscribe(onNext: { [weak self] in
            self?.coordinator?.routeToCreate()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToHabitRecord.subscribe(onNext: { [weak self] record in
            self?.coordinator?.routeToHabitRecord(record: record)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.showAlert.subscribe(onNext: { [weak self] msg in
            self?.presentAlert(title: "Alert", message: msg)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToArticle.subscribe(onNext: { [weak self] item in
            self?.coordinator?.routeToArticle(item)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToMoodie.subscribe(onNext: { [weak self] in
            self?.coordinator?.routeToMoodie()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToQuickNote.subscribe(onNext: { [weak self] in
            self?.coordinator?.routeToQuickNote()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToSetting.subscribe(onNext: { [weak self] in
            self?.coordinator?.routeToSetting()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToListHabit.subscribe(onNext: { [weak self] in
            self?.coordinator?.routeToListHabit()
        }).disposed(by: self.disposeBag)
    }
}
