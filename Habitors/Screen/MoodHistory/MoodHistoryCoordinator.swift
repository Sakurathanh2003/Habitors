//
//  MoodHistoryCoordinator.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 19/4/25.
//

import UIKit
import RxSwift

struct MoodHistoryWantToDismissEvent: CoordinatorEvent { }

final class MoodHistoryCoordinator: NavigationBaseCoordinator {
    var needBackToHome: Bool
    
    init(needBackToHome: Bool, navigationController: UINavigationController) {
        self.needBackToHome = needBackToHome
        super.init(navigationController: navigationController)
    }
    
    lazy var controller: MoodHistoryViewController = {
        let viewModel = MoodHistoryViewModel()
        let controller = MoodHistoryViewController(viewModel: viewModel, coordinator: self)
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
    
    func dismiss() {
        if needBackToHome {
            self.send(event: MoodHistoryWantToDismissEvent())
        } else {
            self.stop()
        }
    }
    
    func presentDeleteDialog() {
        let alert = UIAlertController(title: User.isVietnamese ? "Xác nhận" : "Confirm",
                                      message: User.isVietnamese ? "Bạn có chắc chắn muốn xoá không? Hành động của bạn không thể quay lại" : "Are you sure want to delete? Your action can't undo", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: User.isVietnamese ? "Huỷ" : "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: User.isVietnamese ? "Chắc chắn" : "Confirm", style: .destructive) { [weak self] _ in
            self?.controller.viewModel.input.delete.onNext(())
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        self.controller.present(alert, animated: true)
    }
}
