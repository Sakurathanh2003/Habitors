//
//  MoodieViewModel.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 16/4/25.
//

import UIKit
import RxSwift
import SwiftUI

struct MoodieViewModelInput: InputOutputViewModel {
    var selectMood = PublishSubject<()>()
}

struct MoodieViewModelOutput: InputOutputViewModel {

}

struct MoodieViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var history = PublishSubject<Bool>() // Có back thẳng về màn home hay không
}

final class MoodieViewModel: BaseViewModel<MoodieViewModelInput, MoodieViewModelOutput, MoodieViewModelRouting> {
    @Published var currentIndex = 0
    @Published var moods = Mood.allCases
    @Published var addSuccessMood: Mood?
    
    override init() {
        super.init()
        configInput()
    }
    
    private func configInput() {
        self.input.selectMood.subscribe(onNext: { [weak self] in
            guard let self else {
                return
            }
            
            let mood = mood(of: currentIndex)
            MoodRecordDAO.shared.addObject(mood: mood)
            withAnimation {
                self.addSuccessMood = mood
            }
        }).disposed(by: self.disposeBag)
    }
    
    func mood(of index: Int) -> Mood {
        return moods[index]
    }
}
