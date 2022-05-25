//
//  PersistenceController.swift
//  TodoAppIOS
//
//  Created by Andres Käver on 25.04.2022.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "DataModel")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            PersistenceController.handleError(error)
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                PersistenceController.handleError(error as NSError)
            }
        }
    }
    
    static func handleError(_ error: Error?) {
        if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
        }
    }
    
    
    static var preview: PersistenceController = {
        let inMemoryPersistence = PersistenceController(inMemory: true)
        let viewContext = inMemoryPersistence.container.viewContext

        let todoPriority = TodoPriority(context: viewContext)
        todoPriority.priorityName = "High"
        
        let todoCategory = TodoCategory(context: viewContext)
        todoCategory.categoryName = "Home"
                
        
        for i in 0..<10 {
            let todoTask = TodoTask(context: viewContext)
            todoTask.todoPriority = todoPriority
            todoTask.todoCategory = todoCategory
            todoTask.taskName = "Task \(i)"
            todoTask.createdDt = Date()
            todoTask.isArchived = false
            todoTask.isCompleted = false
        }
        inMemoryPersistence.save()
        return inMemoryPersistence
    }()
    
}
