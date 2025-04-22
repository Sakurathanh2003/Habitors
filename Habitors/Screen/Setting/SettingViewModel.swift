//
//  SettingViewModel.swift
//  Habitors
//
//  Created by Thanh Vu on 22/4/25.
//

import UIKit
import RxSwift
import SwiftUI

struct SettingViewModelInput: InputOutputViewModel {
    var didTapLanguageToggle = PublishSubject<()>()
    var didTapDarkModeToggle = PublishSubject<()>()
}

struct SettingViewModelOutput: InputOutputViewModel {

}

struct SettingViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
}

final class SettingViewModel: BaseViewModel<SettingViewModelInput, SettingViewModelOutput, SettingViewModelRouting> {
    
    override init() {
        super.init()
        configInput()
    }
    
    private func configInput() {
        input.didTapLanguageToggle.subscribe(onNext: {
            User.isVietnamese.toggle()
        }).disposed(by: self.disposeBag)
        
        input.didTapDarkModeToggle.subscribe(onNext: {
            User.isTurnDarkMode.toggle()
        }).disposed(by: self.disposeBag)
    }
}
