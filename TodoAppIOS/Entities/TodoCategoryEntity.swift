//
//  TodoCategory.swift
//  TodoAppIOS
//
//  Created by Magnus Muru on 22.05.2022.
//

import Foundation

struct TodoCategoryEntity: Identifiable, Codable {
    var id: UUID = UUID()
    var categoryName: String
    var categorySort: Int
    var syncDt: Date
}

typealias TodoCategoryEntities = [TodoCategoryEntity]
