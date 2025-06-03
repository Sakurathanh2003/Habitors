//
//  CreateViewController.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import UIKit
import RxSwift

class CreateViewController: BaseViewController {
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
        insertFullScreen(CreateView(viewModel: viewModel))
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
        
        viewModel.routing.didCreate.subscribe(onNext: { [weak self] in
            self?.coordinator?.didCreateHabit()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.presentDeleteDialog.subscribe(onNext: { [weak self] in
            self?.coordinator?.presentDeleteDialog()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.showAlert.subscribe(onNext: { [weak self] message in
            let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(cancelAction)
            self?.present(alert, animated: true)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.needPermisson.subscribe(onNext: { [weak self] message in
            let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(cancelAction)
            
            let settingAction = UIAlertAction(title: Translator.translate(key: "Go to Setting"), style: .destructive) { _ in
                UIApplication.shared.openAppleHealthSources()
            }
            
            alert.addAction(settingAction)
            self?.present(alert, animated: true)
        }).disposed(by: self.disposeBag)
    }
}

