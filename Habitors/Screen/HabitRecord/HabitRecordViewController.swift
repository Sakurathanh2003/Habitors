//
//  HabitRecordViewController.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 26/3/25.
//

import UIKit
import RxSwift

class HabitRecordViewController: BaseViewController {
    var viewModel: HabitRecordViewModel
    weak var coordinator: HabitRecordCoordinator?

    init(viewModel: HabitRecordViewModel, coordinator: HabitRecordCoordinator) {
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
        insertFullScreen(HabitRecordView(viewModel: viewModel))
        configRoutingOutput()
    }
    
    func configRoutingOutput() {
        viewModel.routing.stop.subscribe(onNext: { [weak self] in
            self?.coordinator?.stop()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.routeToEditHabit.subscribe(onNext: { [weak self] habit in
            self?.coordinator?.routeToCreate(habit: habit)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.needToPermission.subscribe(onNext: { [weak self] message in
            let alert = UIAlertController(title: "Oops", message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Ok", style: .cancel)
            alert.addAction(cancelAction)
            
            let settingAction = UIAlertAction(title: "Go to Setting", style: .destructive) { _ in
                UIApplication.shared.openAppleHealthSources()
            }
            
            alert.addAction(settingAction)
            self?.present(alert, animated: true)
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.showAlert.subscribe(onNext: { [weak self] msg in
            self?.presentAlert(title: "", message: msg)
        }).disposed(by: self.disposeBag)
    }
}
