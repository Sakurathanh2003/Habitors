//
//  SingleTaskView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import SwiftUI

struct SingleTaskView: View {
    var task: Task
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 4)
                .fill(.white)
                .frame(width: 59, height: 59)
                .overlay(
                    Text("👾")
                )
            
            VStack(alignment: .leading, spacing: 10) {
                Text(task.name)
                    .gilroySemiBold(16)
                    .foregroundStyle(Color("Black"))
                
                if task.isCompleted {
                    Text("Completed")
                        .gilroyMedium(12)
                        .foregroundStyle(Color("Success"))
                } else {
                    Text(task.date.format("hh:mm a"))
                        .gilroyMedium(12)
                        .foregroundStyle(Color("Gray"))
                }
            }
            
            Spacer(minLength: 0)
            
            if task.isCompleted {
                Circle()
                    .fill(Color("Success"))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "checkmark")
                            .renderingMode(.template)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 8)
                            .foregroundStyle(.white)
                    )
            } else {
                Circle()
                    .stroke(Color("Gray03"), lineWidth: 1)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 81)
        .background(Color("Gray01"))
        .cornerRadius(12)
    }
}

#Preview {
    SingleTaskView(task: .init(name: "Learn quran for 1 hour", isCompleted: true, date: Date()))
        .previewLayout(.sizeThatFits)
}
