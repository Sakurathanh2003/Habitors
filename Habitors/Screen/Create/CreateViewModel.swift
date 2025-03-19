//
//  CreateViewModel.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import UIKit
import SwiftUI
import RxSwift

struct CreateViewModelInput: InputOutputViewModel {
    var selectRepeatDay = PublishSubject<Int>()
}

struct CreateViewModelOutput: InputOutputViewModel {

}

struct CreateViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
}

final class CreateViewModel: BaseViewModel<CreateViewModelInput, CreateViewModelOutput, CreateViewModelRouting> {
    @Published var name: String = ""
    @Published var isTurnOnReminder: Bool = false
    @Published var selectedDate = [Date]()
    
    // Period
    @Published var isMorning: Bool = false
    @Published var isEvening: Bool = false
    
    // Repeat
    @Published var repeatDay = [Int]()
    
    @Published var isShowingCalendar: Bool = false
    @Published var isShowingPeriodDialog: Bool = false
    
    @Published var times = [Time]()
    
    override init() {
        super.init()
        configInput()
    }
    
    private func configInput() {
        input.selectRepeatDay.subscribe(onNext: { [unowned self] stt in
            if let index = repeatDay.firstIndex(of: stt) {
                repeatDay.remove(at: index)
            } else {
                repeatDay.append(stt)
            }
        }).disposed(by: self.disposeBag)
    }
}

// MARK: - Get
extension CreateViewModel {
    var descriptionOfHabitDate: String {
        guard let firstDay = selectedDate.first else {
            return ""
        }
        
        if selectedDate.count == 1 {
            return firstDay.format("dd MMMM")
        }
        
        return "\(selectedDate.count) days"
    }
    
    func didSelectedRepeatDay(_ index: Int) -> Bool {
        return repeatDay.contains(where: { $0 == index })
    }
}

#Preview {
    CreateView(viewModel: .init())
}
