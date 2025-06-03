//
//  MoodHistory.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 19/4/25.
//

import SwiftUI
import RxSwift
import SakuraExtension

struct MoodHistory: View {
    @ObservedObject var viewModel: MoodHistoryViewModel
   
    var body: some View {
        VStack {
            NavigationBarView(
                title: Translator.translate(key: "Mood History"),
                secondItem: nil,
                isDarkMode: viewModel.isTurnDarkMode) {
                    viewModel.routing.stop.onNext(())
                }
                .padding(.horizontal, 20)
            
            if viewModel.moodGroup.isEmpty {
                Spacer().frame(height: 100)
                Image("ic_empty")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text(Translator.translate(key: "You haven't logged any moods yet."))
                    .fontRegular(16)
                    .foreColor(.gray)
                    .padding(.top, 5)
                Spacer()
            } else {
                ScrollView(.vertical) {
                    LazyVGrid(columns: [.init()]) {
                        ForEach(viewModel.moodGroup.keys.sorted(by: { $0 >= $1 }), id: \.hashValue) { date in
                            let moods = viewModel.moodGroup[date]
                            
                            HStack {
                                Text(date.format("dd MMMM yyyy"))
                                    .fontBold(18)
                                    .foreColor(mainColor)
                                
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
        .background(backgroundColor.ignoresSafeArea())
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
                Text(Translator.translate(key: mood.rawValue.capitalized))
                    .fontBold(16)
                    .frame(height: 20)
                Text(record.createdDate.format("HH:mm"))
                    .fontRegular(10)
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
                    viewModel.input.wantToDelete.onNext(record)
                }
        }
        .padding(10)
        .background(
            backgroundColor.opacity(0.7)
        )
        .cornerRadius(5)
    }
    
   
    var backgroundColor: Color {
        return viewModel.isTurnDarkMode ? .black : .white
    }
    
    var mainColor: Color {
        return viewModel.isTurnDarkMode ? .white : .black
    }
}

#Preview {
    MoodHistory(viewModel: MoodHistoryViewModel())
}
