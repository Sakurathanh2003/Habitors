//
//  ChooseTemplateHabitViewModel.swift
//  Habitors
//
//  Created by CucPhung on 19/3/25.
//

import UIKit
import RxSwift

struct ChooseTemplateHabitViewModelInput: InputOutputViewModel {

}

struct ChooseTemplateHabitViewModelOutput: InputOutputViewModel {

}

struct ChooseTemplateHabitViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
}

final class ChooseTemplateHabitViewModel: BaseViewModel<ChooseTemplateHabitViewModelInput, ChooseTemplateHabitViewModelOutput, ChooseTemplateHabitViewModelRouting> {

}
