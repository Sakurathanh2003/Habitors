//
//  MoodHistoryViewModel.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 19/4/25.
//

import UIKit
import RxSwift

struct MoodHistoryViewModelInput: InputOutputViewModel {

}

struct MoodHistoryViewModelOutput: InputOutputViewModel {

}

struct MoodHistoryViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
}

final class MoodHistoryViewModel: BaseViewModel<MoodHistoryViewModelInput, MoodHistoryViewModelOutput, MoodHistoryViewModelRouting> {
    
}
