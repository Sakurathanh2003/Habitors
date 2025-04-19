//
//  MoodHistory.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 19/4/25.
//

import SwiftUI
import RxSwift

struct MoodHistory: View {
    @ObservedObject var viewModel: MoodHistoryViewModel
    @State var moodGroup: [Date: [MoodRecord]] = [:]
    @State var chooseDeletedRecord: MoodRecord?
    
    var body: some View {
        VStack {
            HStack {
                Image("ic_back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        viewModel.routing.stop.onNext(())
                    }
                Spacer()
            }
            .frame(height: 56)
            .overlay(
                Text("Mood History")
                    .gilroyBold(16)
            )
            .padding(.horizontal, 20)
            
            if moodGroup.isEmpty {
                Spacer().frame(height: 100)
                Image("ic_empty")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text("You haven't logged any moods yet.")
                    .gilroyRegular(16)
                    .padding(.top, 5)
                Spacer()
            } else {
                ScrollView(.vertical) {
                    LazyVGrid(columns: [.init()]) {
                        ForEach(moodGroup.keys.sorted(by: { $0 >= $1 }), id: \.hashValue) { date in
                            let moods = moodGroup[date]
                            
                            HStack {
                                Text(date.format("dd MMMM yyyy"))
                                    .gilroyBold(18)
                                Spacer()
                            }.frame(height: 25)
                            
                            if let moods {
                                ForEach(moods.sorted(by: { $0.createdDate >= $1.createdDate}) , id: \.id) { moodRecord in
                                    moodView(moodRecord)
                                }
                            }
                    
                        }
                    }.padding(.horizontal, 20)
                }
            }
        }
        .overlay(
            ZStack {
                if let record = chooseDeletedRecord {
                    DeleteDialog(objectName: "record") {
                        deleteRecord(record)
                        withAnimation {
                            chooseDeletedRecord = nil
                        }
                    } cancelAction: {
                        withAnimation {
                            chooseDeletedRecord = nil
                        }
                    }
                }
            }
        )
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            getListRecord()
        }
    }
    
    @ViewBuilder
    func moodView(_ record: MoodRecord) -> some View {
        let mood = record.value
        let backgroundColor = mood.color
        HStack {
            Image("icon_\(mood.rawValue)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 0) {
                Text(mood.rawValue.capitalized)
                    .gilroyBold(16)
                    .frame(height: 20)
                Text(record.createdDate.format("HH:mm"))
                    .gilroyRegular(10)
                    .frame(height: 16)
            }
            
            Spacer()
            
            Image("Recycle Bin")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundStyle(.white)
                .onTapGesture {
                    withAnimation {
                        chooseDeletedRecord = record
                    }
                }
        }
        .padding(10)
        .background(
            backgroundColor.opacity(0.7)
        )
        .cornerRadius(5)
    }
    
    func deleteRecord(_ record: MoodRecord) {
        MoodRecordDAO.shared.deleteObject(item: record)
        getListRecord()
    }
    
    func getListRecord() {
        let listMood = MoodRecordDAO.shared.getAll().sorted(by: { $0.createdDate >= $1.createdDate})
        moodGroup = Dictionary(grouping: listMood) { record in
            Calendar.current.startOfDay(for: record.createdDate)
        }
    }
}

#Preview {
    MoodHistory(viewModel: MoodHistoryViewModel())
}
