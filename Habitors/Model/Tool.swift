//
//  Tool.swift
//  Habitors
//
//  Created by Vũ Thị Thanh on 14/3/25.
//

import Foundation

enum ToolType: String, Codable {
    case music
    case video
    case drawing
    case coding
}

class Tool: Codable {
    var id: String
    var name: String
    var type: ToolType
    var items: [Item]

    struct Item: Codable {
        var id: String
        var name: String
        var description: String?
        
        init(id: String = UUID().uuidString, name: String, description: String? = nil) {
            self.id = id
            self.name = name
            self.description = description
        }
    }

    init(id: String, name: String, type: ToolType, items: [Item]) {
        self.id = id
        self.name = name
        self.type = type
        self.items = items
    }
}
