//
//  MoodieViewModel.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 16/4/25.
//

import UIKit
import RxSwift

struct MoodieViewModelInput: InputOutputViewModel {

}

struct MoodieViewModelOutput: InputOutputViewModel {

}

struct MoodieViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
}

final class MoodieViewModel: BaseViewModel<MoodieViewModelInput, MoodieViewModelOutput, MoodieViewModelRouting> {

}
