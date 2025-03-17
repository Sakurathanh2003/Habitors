//
//  Calendar+Extension.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/3/25.
//

import Foundation

extension Calendar {
    func getDatesInMonth() -> [Date] {
        let today = Date()
        
        // Lấy khoảng thời gian của tháng hiện tại
        let range = self.range(of: .day, in: .month, for: today)!
        
        // Lấy ngày đầu tiên của tháng
        let startOfMonth = self.date(from: self.dateComponents([.year, .month], from: today))!
        
        // Tạo danh sách các ngày
        return range.map { day -> Date in
            return self.date(byAdding: .day, value: day - 1, to: startOfMonth)!
        }
    }
}
