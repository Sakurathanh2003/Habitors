//  BaseViewModel.swift

import Foundation
import RxSwift
import UIKit

public protocol InputOutputViewModel {
    init()
}

public protocol RoutingOutput {
    init()
}

public class BaseViewModel<Input: InputOutputViewModel, Output: InputOutputViewModel, Routing: RoutingOutput>: NSObject, ObservableObject {
    
    var input = Input()
    var output = Output()
    var routing = Routing()
    var disposeBag = DisposeBag()
}
