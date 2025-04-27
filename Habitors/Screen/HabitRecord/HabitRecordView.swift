//
//  HabitRecordView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 26/3/25.
//

import SwiftUI
import RxSwift
import SakuraExtension

fileprivate struct Const {
    static let linewidth: CGFloat = 20
}

struct HabitRecordView: View {
    @ObservedObject var viewModel: HabitRecordViewModel

    var body: some View {
        VStack(spacing: 0) {
            NavigationBarView(title: viewModel.title, secondItem: .more, isDarkMode: viewModel.isTurnDarkMode) {
                viewModel.routing.stop.onNext(())
            } secondAction: {
                viewModel.routing.presentOption.onNext(())
            }.padding(.horizontal, 20)
            
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        displayValueView
                        
                        if viewModel.unit.canSetData {
                            changeValueView
                        } else {
                            Spacer()
                            Text("Relevant data will be retrieved from the Health app.")
                                .padding(.horizontal, 20)
                                .multilineTextAlignment(.center)
                                .fontBold(20)
                                .foreColor(viewModel.mainColor)
                        }
                    }
                    .frame(height: proxy.size.height)
                }
            }
        }
        .background(viewModel.backgroundColor.ignoresSafeArea())
        .overlay(
            ZStack {
                if viewModel.isShowingAddValue {
                    InputView(value: 0,
                              titleString: "Enter value (count)",
                              isShowing: $viewModel.isShowingAddValue,
                              saveAction: {
                        if let value = Double($0) {
                            viewModel.input.addValue.onNext(value)
                        }
                    })
                }
            }
        )
    }
    
    // MARK: - Display value
    @ViewBuilder
    var displayValueView: some View {
        ZStack {
            Circle()
                .stroke(Color("Gray02"), lineWidth: Const.linewidth)
                .padding(Const.linewidth)
            
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(Color("Information"), lineWidth: Const.linewidth)
                .padding(Const.linewidth)
                .rotationEffect(.degrees(-90))
        }
        .overlay(
            VStack {
                if !viewModel.isTimeUnit {
                    Text("/\(viewModel.goalValue.text)")
                        .fontRegular(20)
                        .autoresize(1)
                        .foregroundStyle(Color("Gray03"))
                        .opacity(0)
                    
                    Text("\(viewModel.currentValue.text)")
                        .fontBold(UIScreen.main.bounds.width / 5)
                        .autoresize(1)
                        .foreColor(viewModel.mainColor)
                    
                    Text("\(Double(viewModel.progress * 100).textWithDecimal(2))%")
                        .fontBold(20)
                        .autoresize(1)
                        .foregroundStyle(Color("Gray03"))
                } else {
                    Text(viewModel.timeString)
                        .fontBold(UIScreen.main.bounds.width / 5)
                        .autoresize(1)
                        .foreColor(viewModel.mainColor)
                }
            }
            .padding(.horizontal, 30)
        )
        .padding()
        .frame(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.width
        )
    }
    
    // MARK: - Change Value
    @ViewBuilder
    var changeValueView: some View {
        if !viewModel.isTimeUnit {
            if viewModel.unit != .exerciseTime {
                HStack(alignment: .center) {
                    LongPressButtonView {
                        viewModel.input.addValue.onNext(-1)
                    } content: {
                        Image(systemName: "minus")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black)
                            .cornerRadius(25)
                    }
                    
                    Spacer().frame(width: UIScreen.main.bounds.width / 3)
                    
                    LongPressButtonView {
                        viewModel.input.addValue.onNext(1)
                    } content: {
                        Image(systemName: "plus")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black)
                            .cornerRadius(25)
                    }
                }
            }
            
            Spacer(minLength: 0)
            
            quickAddView
        } else {
            Spacer()
            
            Text(viewModel.isCounting ? "Stop" : "Start")
                .fontBold(20)
                .frame(width: UIScreen.main.bounds.width / 2.5, height: 56)
                .background(Color("Error"))
                .cornerRadius(5)
                .foregroundStyle(.white)
                .onTapGesture {
                    if viewModel.isCounting {
                        viewModel.input.stopTimer.onNext(())
                    } else {
                        viewModel.input.startTimer.onNext(())
                    }
                }
            
            Text("Reset")
                .fontBold(20)
                .frame(width: UIScreen.main.bounds.width / 2.5, height: 56)
                .background(Color("Gray03"))
                .cornerRadius(5)
                .foregroundStyle(.white)
                .onTapGesture {
                    viewModel.input.resetTimer.onNext(())
                }
                .padding(.top, 10)
               
            Spacer()
        }
    }
    
    // MARK: - Quick Add View
    @ViewBuilder
    var quickAddView: some View {
        VStack {
            HStack {
                Text("Quick Add")
                    .fontBold(20)
                    .foreColor(viewModel.mainColor)
                
                Spacer()
            }
            
            HStack(spacing: 10) {
                Button {
                    viewModel.input.addValue.onNext(5)
                } label: {
                    Color("Secondary")
                        .frame(height: 56)
                        .overlay(
                            Text("5")
                                .fontBold(20)
                                .foregroundStyle(.white)
                        )
                        .cornerRadius(5)
                }

                Button {
                    viewModel.input.addValue.onNext(10)
                } label: {
                    Color("Secondary")
                        .frame(height: 56)
                        .overlay(
                            Text("10")
                                .fontBold(20)
                                .foregroundStyle(.white)
                        )
                        .cornerRadius(5)
                }
            }
            
            HStack(spacing: 10) {
                Button {
                    viewModel.input.addValue.onNext(15)
                } label: {
                    Color("Secondary")
                        .frame(height: 56)
                        .overlay(
                            Text("15")
                                .fontBold(20)
                                .foregroundStyle(.white)
                        )
                        .cornerRadius(5)
                }
                
                Button {
                    withAnimation {
                        viewModel.input.didTapAddValue.onNext(())
                    }
                } label: {
                    Color("Secondary")
                        .frame(height: 56)
                        .overlay(
                            Text("Other")
                                .fontBold(20)
                                .foregroundStyle(.white)
                        )
                        .cornerRadius(5)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}

#Preview {
    HabitRecordView(
        viewModel:
                .init(record: .init(id: "",
                                    habitID: "",
                                    date: Date(),
                                    status: "",
                                    value: 0,
                                    createdAt: Date())))
}

// MARK: - LongPressButtonView
struct LongPressButtonView<Content: View>: View {
    @State private var timer: Timer?
    @State private var isPressing = false

    var action: (() -> Void)
    var content: (() -> Content)

    var body: some View {
        content()
            .onLongPressGesture(minimumDuration: 0.2, pressing: { pressing in
                if pressing {
                    startTimer()
                } else {
                    stopTimer()
                }
            }, perform: {})
            .onTapGesture {
                action()
            }
    }

    private func startTimer() {
        stopTimer() // Đảm bảo không có timer trước đó
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            action()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
