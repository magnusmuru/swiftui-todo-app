//
//  TodoTaskEntity.swift
//  TodoAppIOS
//
//  Created by Magnus Muru on 22.05.2022.
//

import Foundation

struct TodoTaskEntity: Identifiable, Codable {
    var id: UUID = UUID()
    var taskName: String
    var taskSort: Int
    var createdDt: Date
    var dueDt: Date
    var isCompleted: Bool
    var isArchived: Bool
    var todoCategoryId: UUID
    var todoPriorityId: UUID
    var syncDt: Date
}

typealias TodoTaskEntities = [TodoTaskEntity]
