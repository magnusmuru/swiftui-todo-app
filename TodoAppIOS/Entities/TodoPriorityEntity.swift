//
//  TodoPriorityEntity.swift
//  TodoAppIOS
//
//  Created by Magnus Muru on 22.05.2022.
//

import Foundation

struct TodoPriorityEntity: Identifiable, Codable {
    var id: UUID = UUID()
    var priorityName: String
    var prioritySort: Int
    var syncDt: Date
    var appUserId: UUID?
}

typealias TodoPriorityEntities = [TodoPriorityEntity]
