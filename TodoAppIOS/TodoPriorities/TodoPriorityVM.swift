//
//  TodoPriorityVM.swift
//  TodoAppIOS
//
//  Created by Magnus Muru on 24.05.2022.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class TodoPriorityVM : Combine.ObservableObject {
    
    @Published var items : TodoPriorityEntities = []
    @Published var localItems : [TodoPriority] = []
    
    var counter = 0
    
    let context = PersistenceController.shared.container.viewContext
    
    private var service = TodoPriorityService()
    
    @MainActor
    func getDataAsync() async {
        await context.perform {
            do {
                let fetchRequest : NSFetchRequest = TodoPriority.fetchRequest()
                self.localItems = try self.context.fetch(fetchRequest)
                for item in self.localItems {
                    print(item.syncDt ?? "Date not found")
                }
            }
            catch let error {
                print(error)
            }
        }
        items = await service.getAllPriorities()
        
        for item in self.localItems {
            if (item.syncDt == nil) {
                counter += 1
                let itemToAdd = TodoPriorityEntity(priorityName: item.priorityName!, prioritySort: counter, syncDt: Date.now)
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
        let category = TodoPriority(context: self.context)
        category.priorityName = name
        category.id = UUID()
        
        
        counter += 1
        let itemToAdd = TodoPriorityEntity(id: category.id!, priorityName: category.priorityName!, prioritySort: counter, syncDt: Date.now)
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
    func deleteItemAsync(item: TodoPriority) {
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
