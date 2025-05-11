//
//  TimeDialog.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import SwiftUI
import SwiftUIIntrospect

struct TimeDialog: View {
    @State private var isDragging = false
    @State var currentDate = Date()
    
    @State var hour: Int
    @State var minutes: Int
    
    var cancelAction: (() -> Void)
    var doneAction: ((Time) -> Void)
    
    init(time: Time, cancelAction: @escaping () -> Void, doneAction: @escaping (Time) -> Void) {
        self.hour = time.hour
        self.minutes = time.minutes
        self.cancelAction = cancelAction
        self.doneAction = doneAction
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            
            VStack {
                HStack(alignment: .center, spacing: 39) {
                    Spacer(minLength: 0)
                    Picker(selection: $hour, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                        ForEach(0...23, id: \.self) { value in
                            Text(value.format("%02d"))
                                .fontSemiBold(18)
                                .frame(height: 28)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .introspect(.picker(style: .wheel), on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) {
                        $0.subviews[1].backgroundColor = UIColor.red
                                           .withAlphaComponent(0)
                    }
                    
                    Picker(selection: $minutes, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                        ForEach(0...59, id: \.self) { value in
                            Text(value.format("%02d"))
                                .fontSemiBold(18)
                                .frame(height: 28)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .introspect(.picker(style: .wheel), on: .iOS(.v13, .v14, .v15, .v16, .v17, .v18)) {
                        $0.subviews[1].backgroundColor = UIColor.red
                                           .withAlphaComponent(0)
                    }
                    
                    Spacer(minLength: 0)
                }
                .frame(height: 234)
                .overlay(
                    VStack(spacing: 0) {
                        Spacer()
                        Color("Gray02")
                            .frame(height: 1)
                        
                        Color("Gray02")
                            .frame(height: 1)
                            .padding(.top, 40)
                        Spacer()
                    }
                )
                .padding(.vertical, 20)
                
                HStack(spacing: 20) {
                    Spacer()
                    
                    Button(action: {
                        cancelAction()
                    }, label: {
                        Text("Cancel")
                            .fontMedium(14)
                            .foregroundStyle(Color("Black"))
                    })
                    
                    Button(action: {
                        doneAction(.init(hour: hour, minutes: minutes))
                    }, label: {
                        Text("Done")
                            .fontMedium(14)
                            .foregroundStyle(Color("Primary"))
                    })
                }
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(20)
            .padding(24)
        }
    }
}

#Preview {
    TimeDialog(time: .init(hour: 13, minutes: 12), cancelAction: {
        
    }, doneAction: { _ in
        
    })
}
