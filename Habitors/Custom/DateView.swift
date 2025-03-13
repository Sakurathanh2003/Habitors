//
//  DateView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import SwiftUI

struct DateView: View {
    var date: Date
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("Gray02"), lineWidth: 1)
                .padding(1)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Black"))
                .frame(
                    width: isSelected ? nil : 0,
                    height: isSelected ? nil : 0
                )
            
            VStack(spacing: 12) {
                Text(date.format("E"))
                    .gilroyRegular(12)
                    .foregroundStyle(textColor)
                
                Text(date.format("dd"))
                    .gilroySemiBold(16)
                    .foregroundStyle(textColor)
            }
        }
        .frame(width: 52,height: 88)
    }
    
    var textColor: Color {
        return isSelected ? .white : Color("Gray")
    }
}

#Preview {
    DateView(date: Date(), isSelected: true)
}
