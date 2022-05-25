//
//  TodoAppIOSApp.swift
//  TodoAppIOS
//
//  Created by Andres Käver on 25.04.2022.
//

import SwiftUI

@main
struct AppEntry: App {
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
