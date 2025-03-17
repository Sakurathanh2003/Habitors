//
//  HabitToggle.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import SwiftUI

struct HabitToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(isOn ? Color("Success") : Color.gray.opacity(0.3))
                .animation(.easeInOut(duration: 0.2), value: isOn)

            HStack {
                if isOn {
                    Spacer()
                }
                
                Circle()
                    .fill(Color.white)
                    .padding(3)
                    
                
                if !isOn {
                    Spacer()
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isOn)
        }
        .frame(width: 44, height: 24)
        .onTapGesture {
            isOn.toggle()
            handleToggleAction()
        }
    }

    // Hàm xử lý khi toggle thay đổi
    private func handleToggleAction() {
        if isOn {
            print("🔥 Toggle is ON")
        } else {
            print("❄️ Toggle is OFF")
        }
    }
}
