//
//  DetailArticleViewController.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/4/25.
//

import UIKit
import RxSwift

class DetailArticleViewController: BaseViewController {
    var viewModel: DetailArticleViewModel
    weak var coordinator: DetailArticleCoordinator?

    init(viewModel: DetailArticleViewModel, coordinator: DetailArticleCoordinator) {
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
        insertFullScreen(ArticleDetailView(viewModel: viewModel))
        configRoutingOutput()
    }

    func configRoutingOutput() {
        viewModel.routing.stop.subscribe(onNext: { [weak self] _ in
            self?.coordinator?.stop()
        }).disposed(by: self.disposeBag)
        
        viewModel.routing.backToHabitTab.subscribe(onNext: { [weak self] _ in
            let alertController = UIAlertController(
                title: "Routine added succesfully!",
                message: "Selected habits added to your routine successfully",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.coordinator?.backToHabitTab()
            }
            
            alertController.addAction(okAction)
            self?.present(alertController, animated: true)
        }).disposed(by: self.disposeBag)
    }
}
