//
//  MoodHistoryViewModel.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 19/4/25.
//

import UIKit
import RxSwift
import SwiftUI

struct MoodHistoryViewModelInput: InputOutputViewModel {
    var wantToDelete = PublishSubject<MoodRecord>()
    var delete = PublishSubject<()>()
}

struct MoodHistoryViewModelOutput: InputOutputViewModel {

}

struct MoodHistoryViewModelRouting: RoutingOutput {
    var stop = PublishSubject<()>()
    var presentDeleteDialog = PublishSubject<()>()
}

final class MoodHistoryViewModel: BaseViewModel<MoodHistoryViewModelInput, MoodHistoryViewModelOutput, MoodHistoryViewModelRouting> {
    @Published var chooseDeletedRecord: MoodRecord?
    @Published var moodGroup: [Date: [MoodRecord]] = [:]
    
    override init() {
        super.init()
        getListRecord()
        configInput()
    }
    
    private func configInput() {
        input.wantToDelete.subscribe(onNext: { [weak self] item in
            self?.chooseDeletedRecord = item
            self?.routing.presentDeleteDialog.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.delete.subscribe(onNext: { [weak self] in
            guard let self, let item = chooseDeletedRecord else {
                return
            }
            
            MoodRecordDAO.shared.deleteObject(item: item)
            getListRecord()
        }).disposed(by: self.disposeBag)
    }
    
    private func getListRecord() {
        let listMood = MoodRecordDAO.shared.getAll().sorted(by: { $0.createdDate >= $1.createdDate})
        moodGroup = Dictionary(grouping: listMood) { record in
            Calendar.current.startOfDay(for: record.createdDate)
        }
    }
}
