//  BaseViewModel.swift

import Foundation
import RxSwift
import UIKit
import SwiftUI

public protocol InputOutputViewModel {
    init()
}

public protocol RoutingOutput {
    init()
}

public class BaseViewModel<Input: InputOutputViewModel, Output: InputOutputViewModel, Routing: RoutingOutput>: NSObject, ObservableObject {
    @Published var isVietnameseLanguage: Bool = User.isVietnamese
    @Published var isTurnDarkMode: Bool = User.isTurnDarkMode
    
    var input = Input()
    var output = Output()
    var routing = Routing()
    var disposeBag = DisposeBag()
    
    public override init() {
        super.init()
        configNotificationCenter()
    }
    
    func configNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateSetting), name: .updateLanguage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateSetting), name: .updateDarkMode, object: nil)
    }
    
    @objc func updateSetting() {
        self.isVietnameseLanguage = User.isVietnamese
        self.isTurnDarkMode = User.isTurnDarkMode
        self.objectWillChange.send()
    }
}

// MARK: - Get
extension BaseViewModel {
    var backgroundColor: Color {
        return isTurnDarkMode ? .black : .white
    }
    
    var mainColor: Color {
        return isTurnDarkMode ? .white : .black
    }
    
    func translate(_ key: String) -> String {
        return Translator.translate(key: key, isVietnamese: isVietnameseLanguage)
    }
}
