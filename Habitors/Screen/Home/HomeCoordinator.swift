//
//  HomeCoordinator.swift
//  Habitors
//
//  Created by CucPhung on 13/3/25.
//

import UIKit
import SwiftUI

final class HomeCoordinator: WindowBaseCoordinator {
    
    private var listHabitCoordinator: ListHabitCoordinator?
    private var chooseTemplateCoordinator: ChooseTemplateHabitCoordinator?
    private var habitRecordCoordinator: HabitRecordCoordinator?
    
    private var detailArticleCoordinator: DetailArticleCoordinator?
    private var moodieCoordinator: MoodieCoordinator?
    
    private var settingCoordinator: SettingCoordinator?
    
    lazy var controller: HomeViewController = {
        let viewModel = HomeViewModel()
        let controller = HomeViewController(viewModel: viewModel, coordinator: self)
        return controller
    }()

    override func start() {
        super.start()
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.isNavigationBarHidden = true
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    override func handle(event: any CoordinatorEvent) -> Bool {
        if event is DetailArticleWantToBackHabitTabEvent {
            controller.viewModel.currentTab = .home
            detailArticleCoordinator?.stop()
            return true
        }
        
        return false
    }

    override func childDidStop(_ child: Coordinator) {
        super.childDidStop(child)
        
        if child is ChooseTemplateHabitCoordinator {
            self.chooseTemplateCoordinator = nil
        }
        
        if child is HabitRecordCoordinator {
            self.habitRecordCoordinator = nil
        }
        
        if child is DetailArticleCoordinator {
            self.detailArticleCoordinator = nil
        }
        
        if child is SettingCoordinator {
            self.settingCoordinator = nil
        }
        
        if child is ListHabitCoordinator {
            self.listHabitCoordinator = nil
        }
    }
    
    func routeToListHabit() {
        self.listHabitCoordinator = ListHabitCoordinator(navigationController: controller.navigationController!)
        self.listHabitCoordinator?.start()
        self.addChild(listHabitCoordinator)
    }
    
    func routeToCreate() {
        self.chooseTemplateCoordinator = ChooseTemplateHabitCoordinator(controller: controller)
        self.chooseTemplateCoordinator?.start()
        self.addChild(chooseTemplateCoordinator)
    }
    
    func routeToHabitRecord(record: HabitRecord) {
        self.habitRecordCoordinator = HabitRecordCoordinator(record: record, navigationController: controller.navigationController!)
        self.habitRecordCoordinator?.start()
        self.addChild(habitRecordCoordinator)
    }
    
    func routeToArticle(_ item: Article) {
        self.detailArticleCoordinator = DetailArticleCoordinator(article: item, navigationController: controller.navigationController!)
        self.detailArticleCoordinator?.start()
        self.addChild(detailArticleCoordinator)
    }
    
    func routeToMoodie() {
        self.moodieCoordinator = MoodieCoordinator(navigationController: controller.navigationController!)
        self.moodieCoordinator?.start()
        self.addChild(moodieCoordinator)
    }
    
    func routeToQuickNote() {
        let hostingController = UIHostingController(rootView: QuickNoteHistory())
        controller.navigationController?.pushViewController(hostingController, animated: true)
    }
    
    func routeToSetting() {
        self.settingCoordinator = SettingCoordinator(navigationController: controller.navigationController!)
        self.settingCoordinator?.start()
        self.addChild(settingCoordinator)
    }
}
