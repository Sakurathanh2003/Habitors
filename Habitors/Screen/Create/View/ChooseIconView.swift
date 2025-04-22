//
//  ChooseIconView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 31/3/25.
//

import Foundation
import SwiftUI
import SwiftUIIntrospect
import SakuraExtension

struct IconCategory {
    var name: String
    var numberOfIcon: Int
    var enterKeyboard: Bool = false
}

struct ChooseIconView: View {
    @State var currentIndex: Int = 0
    @State var didAppear: Bool = false
    @State var emoji: String = "🫶🏻"
    
    let categories: [IconCategory] = [
        .init(name: "education", numberOfIcon: 33),
        .init(name: "sport", numberOfIcon: 20),
        .init(name: "skincare", numberOfIcon: 14),
        .init(name: "food", numberOfIcon: 35),
        .init(name: "finance", numberOfIcon: 12),
        .init(name: "Emoji", numberOfIcon: 0, enterKeyboard: true)
    ]
    
    var currentCategory: IconCategory {
        categories[currentIndex]
    }
    
    var cancelAction: (() -> Void)
    var doneAction: ((String) -> Void)

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack {
                    HStack {
                        Button {
                            withAnimation {
                                didAppear = false
                                cancelAction()
                            }
                        } label: {
                            Image("ic_x")
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 22, height: 22)
                                .foreColor(mainColor)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 46)
                    .overlay(
                        Text("Icon")
                            .gilroyBold(30)
                            .foreColor(mainColor)
                    )
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(categories.indices, id: \.self) { index in
                            let name = categories[index].name
                            let isSelected = index == currentIndex
                        
                            Text(name.capitalized)
                                .gilroyBold(16)
                                .padding(.horizontal, 15)
                                .frame(height: 28)
                                .background(isSelected ? User.isTurnDarkMode ? .white : .black : .clear)
                                .foregroundColor(isSelected ? User.isTurnDarkMode ? .black : .white : .white)
                                .cornerRadius(5)
                                .onTapGesture {
                                    currentIndex = index
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 10)
                
                if !currentCategory.enterKeyboard {
                    ScrollView {
                        listItem()
                    }
                } else {
                    EmojiTextField(text: $emoji)
                        .opacity(0)
                        .frame(width: 0, height: 0)
                        .introspect(.textField, on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) { textfield in
                            
                            
                            textfield.becomeFirstResponder()
                        }
                    
                    Text(emoji)
                        .font(.system(size: 50))
                        .padding(.top, 40)
                    
                    Text("Select this emoji")
                        .gilroySemiBold(20)
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color("Error"))
                        .cornerRadius(5)
                        .onTapGesture {
                            withAnimation {
                                didAppear = false
                                doneAction(emoji)
                            }
                        }
                    
                    Spacer(minLength: 0)
                }
            }
        }
        .offset(y: didAppear ? 0 : UIScreen.main.bounds.height)
        .onAppear {
            withAnimation {
                didAppear = true
            }
        }
    }
    
    var mode: UITextInputMode?{
        for mode in UITextInputMode.activeInputModes {
                    if mode.primaryLanguage == "emoji" {
                        return mode
                    }
                }
        
        return nil
    }
    
    // MARK: - List Item
    func listItem() -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], content: {
            ForEach(1...currentCategory.numberOfIcon, id: \.self) { index in
                Image("ic_\(currentCategory.name)_\(index)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .onTapGesture {
                        withAnimation {
                            didAppear = false
                            doneAction("ic_\(currentCategory.name)_\(index)")
                        }
                    }
            }
        })
        .padding(20)
    }
}

// MARK: - Get
extension ChooseIconView {
    var backgroundColor: Color {
        return User.isTurnDarkMode ? .black : .white
    }
    
    var mainColor: Color {
        return User.isTurnDarkMode ? .white : .black
    }
}

#Preview {
    ChooseIconView {
        
    } doneAction: { _ in
        
    }
}

// MARK: - EmojiTextField
struct EmojiTextField: UIViewRepresentable {
    typealias UIViewType = TextField
    @Binding var text: String
    
    func makeUIView(context: Context) -> TextField {
        let view = TextField()
        view.delegate = context.coordinator
        view.text = text
        return view
    }
    
    
    func updateUIView(_ uiView: TextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField

        init(_ parent: EmojiTextField) {
            self.parent = parent
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            self.parent.text = string
            return true
        }
    }
    
    class TextField: UITextField, UITextFieldDelegate {
        
        // required for iOS 13
        override var textInputContextIdentifier: String? { "" } // return non-nil to show the Emoji keyboard ¯\_(ツ)_/¯
        
        override var textInputMode: UITextInputMode? {
            for mode in UITextInputMode.activeInputModes {
                if mode.primaryLanguage == "emoji" {
                    return mode
                }
            }
            return nil
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            
            commonInit()
        }
        
        func commonInit() {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(inputModeDidChange),
                                                   name: UITextInputMode.currentInputModeDidChangeNotification,
                                                   object: nil)
        }
        
        @objc func inputModeDidChange(_ notification: Notification) {
            guard isFirstResponder else {
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.reloadInputViews()
            }
        }
    }

}

