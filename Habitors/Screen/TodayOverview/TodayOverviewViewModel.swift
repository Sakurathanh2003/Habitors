//
//  TodayOverviewViewModel.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 7/4/25.
//

import UIKit
import RxSwift

struct TodayOverviewViewModelInput: InputOutputViewModel {
    var selectHabit = PublishSubject<Habit>()
    var selectBack = PublishSubject<()>()
}

struct TodayOverviewViewModelOutput: InputOutputViewModel {

}

struct TodayOverviewViewModelRouting: RoutingOutput {
    var routeToHabitRecord = PublishSubject<HabitRecord>()
    var stop = PublishSubject<()>()
}

final class TodayOverviewViewModel: BaseViewModel<TodayOverviewViewModelInput, TodayOverviewViewModelOutput, TodayOverviewViewModelRouting> {
    @Published var tasks = [Habit]()
    @Published var completedHabit = [Habit]()
    @Published var inProgressHabit = [Habit]()
    
    override init() {
        super.init()
        configNotification()
        getTasks()
        configInput()
        
        HealthManager.shared.fetchHourlyStepCountData(endDate: Date()) { values, error in
            guard let values else {
                return
            }
            
            for (key, value) in values.sorted(by: { $0.key <= $1.key }) {
                print("\(key.hour):\(key.minute) : \(value)")
            }
        }
    }
    
    private func configInput() {
        input.selectBack.subscribe(onNext: { [weak self] _ in
            self?.routing.stop.onNext(())
        }).disposed(by: self.disposeBag)
        
        input.selectHabit.subscribe(onNext: { [unowned self] selectedHabit in
            if let record = selectedHabit.records.first(where: { $0.date.isSameDay(date: Date()) }) {
                self.routing.routeToHabitRecord.onNext(record)
            } else {
                if let record = HabitRecordDAO.shared.addObject(habitID: selectedHabit.id, value: 0, date: Date(), createdAt: Date()) {
                    self.routing.routeToHabitRecord.onNext(record)
                }
            }
        }).disposed(by: self.disposeBag)
    }

    private func configNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateHabitItem(notification:)), name: .updateHabitItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHabitItem(notification:)), name: .deleteHabitItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHabitItem(notification:)), name: .addHabitItem, object: nil)
    }
    
    @objc func updateHabitItem(notification: Notification) {
        getTasks()
    }
    
    private func getTasks() {
        let dao = HabitDAO()
        self.tasks = dao.getHabitDay(Date())
        self.completedHabit = tasks.filter { $0.isCompleted(Date()) }
        self.inProgressHabit = tasks.filter { !$0.isCompleted(Date()) }
    }
}
