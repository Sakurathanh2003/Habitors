//
//  DetailArticleViewModel.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/4/25.
//

import SwiftUI
import RxSwift
import UIKit
import SVProgressHUD

struct DetailArticleViewModelInput: InputOutputViewModel {
    var didTapSave = PublishSubject<()>()
}

struct DetailArticleViewModelOutput: InputOutputViewModel {

}

struct DetailArticleViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var backToHabitTab = PublishSubject<()>()
}

final class DetailArticleViewModel: BaseViewModel<DetailArticleViewModelInput, DetailArticleViewModelOutput, DetailArticleViewModelRouting> {
    @Published var isEditingRoutine: Bool = false
    @Published var selectedHabit: [Article.Habit] = []
    var item: Article
    
    init(item: Article) {
        self.item = item
        super.init()
        configInput()
    }
    
    private func configInput() {
        input.didTapSave.subscribe(onNext: { [weak self] _ in
            guard let self else {
                return
            }
            
            SVProgressHUD.show()
            
            let habits = selectedHabit.map({ $0.makeHabit() }).filter({ !HabitDAO.shared.isCreated($0) })
            for habit in habits {
                HabitDAO.shared.addObject(item: habit)
            }
            
            SVProgressHUD.dismiss()
            self.routing.backToHabitTab.onNext(())
        }).disposed(by: self.disposeBag)
    }
}

extension Article.Habit {
    func makeHabit() -> Habit {
        return Habit(id: self.name,
                     name: self.name,
                     icon: self.icon,
                     goalUnit: self.unit,
                     goalValue: self.goalValue,
                     isTemplate: true,
                     startedDate: Date(),
                     frequency: .init(),
                     records: [])
    }
}
