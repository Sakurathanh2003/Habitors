//
//  InputView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 5/4/25.
//
import RxSwift
import SwiftUI
import SakuraExtension

struct InputView: View {
    @Binding var isShowing: Bool
    @State var text: String = ""
    @State var title: String
    @State var didAppear: Bool = false
    var saveAction: ((String) -> Void)
    
    @FocusState private var keyboardFocused: Bool
    
    init(value: Double, titleString: String, isShowing: Binding<Bool>, saveAction: @escaping (String) -> Void) {
        self.text = value == 0 ? "" : value.text
        self.title = titleString
        self.saveAction = saveAction
        self._isShowing = isShowing
    }

    var body: some View {
        VStack(spacing: 0) {
            Color.clear
            VStack {
                HStack {
                    Text(title)
                        .fontBold(20)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image("ic_x")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .foreColor(.black)
                    }
                }
                .padding(.horizontal, 20)
                .frame(height: 46)
                
                HStack {
                    TextField(text: $text) {
                        Text(User.isVietnamese ? "Nhập giá trị" : "Enter Value")
                            .fontBold(18)
                    }
                    .keyboardType(.numberPad)
                    .focused($keyboardFocused)
                    .fontBold(18)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .frame(height: 56)
                    .background(Color("Gray01"))
                    .cornerRadius(10)
                    
                    Text(User.isVietnamese ? "Lưu" : "Save")
                        .fontBold(16)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 10)
                        .background(Color("Error"))
                        .cornerRadius(5)
                        .foregroundColor(.white)
                        .onTapGesture {
                            saveAction(text)
                            dismiss()
                        }
                }
                .padding(.bottom, 5)
                .padding(.horizontal, 20)
            }
            .background(Color.white.ignoresSafeArea())
        }
        .offset(y: didAppear ? 0 : UIScreen.main.bounds.height / 3)
        .onAppear(perform: {
            withAnimation {
                didAppear = true
                keyboardFocused = true
            }
        })
        .background(
            Color.black.opacity(didAppear ? 0.5 : 0).ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
        )
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.5)) {
            keyboardFocused = false
            didAppear = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.isShowing = false
        }
    }
}
