//
//  ArticleCategory.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 15/4/25.
//
import Foundation

struct ArticleCategory: Codable {
    var id: String
    var title: String
    var items: [Article]
}
