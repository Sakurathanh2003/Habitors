//
//  Article.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/4/25.
//
import Foundation

struct Article: Codable {
    var id: String
    var image: String
    var title: String
    var content: String
    
    var habits: [Habit]
    
    struct Habit: Codable {
        var icon: String
        var name: String
    }
}


