//
//  MainView.swift
//  TodoAppIOS
//
//  Created by Andres Käver on 25.04.2022.
//

import SwiftUI


struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView{
            TodoTaskView()
                .tabItem {
                    Label("Tasks", systemImage: "list.bullet.circle")
                }
            TodoCategoryView()
                .tabItem {
                    Label("Categories", systemImage: "slider.horizontal.3")
                }
            TodoPriorityView()
                .tabItem {
                    Label("Priorities", systemImage: "slider.vertical.3")
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        
    }
}
