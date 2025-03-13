//
//  HomeViewModel.swift
//  Habitors
//
//  Created by CucPhung on 13/3/25.
//

import UIKit
import RxSwift
import SwiftUI

struct HomeViewModelInput: InputOutputViewModel {
    var selectTab = PublishSubject<HomeTab>()
}

struct HomeViewModelOutput: InputOutputViewModel {

}

struct HomeViewModelRouting: RoutingOutput {

}

final class HomeViewModel: BaseViewModel<HomeViewModelInput, HomeViewModelOutput, HomeViewModelRouting> {
    @Published var currentTab: HomeTab = .home
    
    override init() {
        super.init()
        configInput()
    }
    
    private func configInput() {
        input.selectTab.subscribe(onNext: { [unowned self] tab in
            withAnimation {
                self.currentTab = tab
            }
        }).disposed(by: self.disposeBag)
    }
}

// MARK: - Get
extension HomeViewModel {
    func isSelected(_ tab: HomeTab) -> Bool {
        return currentTab == tab
    }
}
