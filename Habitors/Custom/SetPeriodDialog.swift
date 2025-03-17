//
//  SetPeriodDialog.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import Foundation
import RxSwift
import SwiftUI

struct SetPeriodDialog: View {
    @State var isMorning: Bool = false
    @State var isEvening: Bool = false
    
    var cancelAction: (() -> Void)
    var doneAction: ((Bool, Bool) -> Void)
    
    init(isMorning: Bool, isEvening: Bool, cancelAction: @escaping () -> Void, doneAction: @escaping (Bool, Bool) -> Void) {
        self.isMorning = isMorning
        self.isEvening = isEvening
        self.cancelAction = cancelAction
        self.doneAction = doneAction
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Set Period")
                    .gilroyBold(20)
                    .foregroundStyle(Color("Black"))
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Morning")
                            .gilroySemiBold(18)
                            .foregroundStyle(Color("Black"))
                        Spacer()
                        HabitToggle(isOn: $isMorning)
                    }
                    .frame(height: 28)
                    
                    HStack {
                        Text("Evening")
                            .gilroySemiBold(18)
                            .foregroundStyle(Color("Black"))
                        Spacer()
                        HabitToggle(isOn: $isEvening)
                    }
                    .frame(height: 28)
                }
                .padding(.top, 33)
                
                HStack(spacing: 20) {
                    Spacer()
                    
                    Button(action: {
                        cancelAction()
                    }, label: {
                        Text("Cancel")
                            .gilroyMedium(14)
                            .foregroundStyle(Color("Black"))
                    })
                    
                    Button(action: {
                        doneAction(isMorning, isEvening)
                    }, label: {
                        Text("Done")
                            .gilroyMedium(14)
                            .foregroundStyle(Color("Primary"))
                    })
                }
                .padding(.top, 24)
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 24)
        }
    }
}
