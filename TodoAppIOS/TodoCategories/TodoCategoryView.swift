//
//  TodoCategoryView.swift
//  TodoAppIOS
//
//  Created by Andres Käver on 25.04.2022.
//

import SwiftUI

struct TodoCategoryView: View {
    @StateObject var vm = TodoCategoryVM()
    
    @State private var isModalPresented = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vm.localItems){ item in
                    NavigationLink {
                        // All items have same name on getting, wtf??
                        Text(item.categoryName ?? "None")
                    } label: {
                        Text(item.categoryName ?? "None")
                    }
                }.onMove { indexSet, offset in
                    vm.localItems.move(fromOffsets: indexSet, toOffset: offset)
                }
                .onDelete(perform: deleteItems)
            }.task {
                await vm.getDataAsync()
            }
            .refreshable {
                await vm.getDataAsync()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {isModalPresented.toggle()}){
                        Label("Add Category", systemImage: "plus")
                    }
                    .fullScreenCover(isPresented: $isModalPresented, content: NewTodoCategoryView.init)
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet){
        withAnimation {
            for i in offsets.makeIterator() {
                let item = vm.localItems[i]
                vm.deleteItemAsync(item: item)
                
                // I got the delete to work locally, but how do I call the same delete for background? Using async here breaks everything
            }
        }
    }
}

struct TodoCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        TodoCategoryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewInterfaceOrientation(.portrait)
    }
}
