//
//  DetailArticleCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/4/25.
//

import UIKit

struct DetailArticleWantToBackHabitTabEvent: CoordinatorEvent { }
final class DetailArticleCoordinator: NavigationBaseCoordinator {
    private var article: Article
    
    init(article: Article, navigationController: UINavigationController) {
        self.article = article
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: DetailArticleViewController = {
        let viewModel = DetailArticleViewModel(item: article)
        let controller = DetailArticleViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        navigationController.pushViewController(controller, animated: true)
    }

    override func stop(completion: (() -> Void)? = nil) {
        navigationController.popViewController(animated: true)
        super.stop(completion: completion)
    }
    
    func backToHabitTab() {
        self.send(event: DetailArticleWantToBackHabitTabEvent())
    }
}
