//
//  TodoTaskVM.swift
//  TodoAppIOS
//
//  Created by Magnus Muru on 25.05.2022.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class TodoTaskVM : Combine.ObservableObject {
    
    @Published var items : TodoTaskEntities = []
    @Published var localItems : [TodoTask] = []
    
    var counter = 0
    
    let context = PersistenceController.shared.container.viewContext
    
    private var service = TodoTaskService()
    
    @MainActor
    func getDataAsync() async {
        await context.perform {
            do {
                let fetchRequest : NSFetchRequest = TodoTask.fetchRequest()
                self.localItems = try self.context.fetch(fetchRequest)
                for item in self.localItems {
                    print(item.syncDt ?? "Date not found")
                }
            }
            catch let error {
                print(error)
            }
        }
        items = await service.getAllTasks()
        
        for item in self.localItems {
            if (item.syncDt == nil) {
                counter += 1
                let itemToAdd = TodoTaskEntity(taskName: item.taskName!, taskSort: counter, createdDt: item.createdDt!, dueDt: item.dueDt!, isCompleted: item.isCompleted, isArchived: item.isArchived, todoCategoryId: (item.todoCategory?.id)!, todoPriorityId: (item.todoPriority?.id)!, syncDt: Date.now)
                if let itemAdded = await service.postDataAsync(itemToAdd) {
                    item.id = itemAdded.id
                    item.syncDt = itemAdded.syncDt
                    await context.perform {
                        do {
                            _ = item
                            try self.context.save()
                        }
                        catch let error {
                            print(error)
                        }
                        
                    }
                }
            }
        }
        
        for item in self.items {
            let results = self.localItems.filter {$0.id == item.id}
            if (results.isEmpty) {
                await service.deleteDataAsync(item.id)
            }
        }
    }
    
    @MainActor
    func addItemAsync(name: String) async {
        let category = TodoTask(context: self.context)
        category.taskName = name
        category.id = UUID()
        
        
        counter += 1
        let itemToAdd = TodoTaskEntity(taskName: category.taskName!, taskSort: counter, createdDt: category.createdDt!, dueDt: category.dueDt!, isCompleted: category.isCompleted, isArchived: category.isArchived, todoCategoryId: (category.todoCategory?.id)!, todoPriorityId: (category.todoPriority?.id)!, syncDt: Date.now)
        if let itemAdded = await service.postDataAsync(itemToAdd) {
            items.append(itemAdded)
            category.syncDt = itemAdded.syncDt
        }
        
        await context.perform {
            do {
                _ = category
                try self.context.save()
            }
            catch let error {
                print(error)
            }
            
        }
        localItems.append(category)
        
    }
    
    @MainActor
    func deleteItemAsync(item: TodoTask) {
        context.perform {
            do {
                try self.context.delete(item)
                try self.context.save()
            }
            catch let error {
                print(error)
            }
            
        }
        if let index = localItems.firstIndex(of: item) {
            localItems.remove(at: index)
        }
    }
}
