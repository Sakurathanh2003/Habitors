//
//  DashedLineView.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 13/3/25.
//

import Foundation
import SwiftUI

struct DashedLineView: View {
    var color: Color
    var lineHeight: CGFloat
    
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0)) // Bắt đầu từ góc trái
            path.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: 0)) // Vẽ sang phải
        }
        .stroke(style: StrokeStyle(lineWidth: lineHeight, dash: [10, 5])) // Độ dài nét & khoảng cách
        .foregroundColor(color) // Màu của đường line
        .frame(height: lineHeight) // Độ dày của đường
    }
}

