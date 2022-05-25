//
//  TodoCategoryVM.swift
//  TodoAppIOS
//
//  Created by Magnus Muru on 22.05.2022.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class TodoCategoryVM : Combine.ObservableObject {
    
    @Published var items : TodoCategoryEntities = []
    @Published var localItems : [TodoCategory] = []
    
    var counter = 0
    
    let context = PersistenceController.shared.container.viewContext
    
    private var service = TodoCategoryService()
    
    @MainActor
    func getDataAsync() async {
        await context.perform {
            do {
                let fetchRequest : NSFetchRequest = TodoCategory.fetchRequest()
                self.localItems = try self.context.fetch(fetchRequest)
                for item in self.localItems {
                    print(item.syncDt ?? "Date not found")
                }
            }
            catch let error {
                print(error)
            }
        }
        items = await service.getAllCategories()
        
        for item in self.localItems {
            if (item.syncDt == nil) {
                counter += 1
                let itemToAdd = TodoCategoryEntity(categoryName: item.categoryName!, categorySort: counter, syncDt: Date.now)
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
        let category = TodoCategory(context: self.context)
        category.categoryName = name
        category.id = UUID()
        
        
        counter += 1
        let itemToAdd = TodoCategoryEntity(categoryName: category.categoryName!, categorySort: counter, syncDt: Date.now)
        if let itemAdded = await service.postDataAsync(itemToAdd) {
            items.append(itemAdded)
            category.id = itemAdded.id
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
    func deleteItemAsync(item: TodoCategory) {
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
