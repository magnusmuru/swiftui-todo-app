//
//  TodoPriorityView.swift
//  TodoAppIOS
//
//  Created by Andres Käver on 25.04.2022.
//

import SwiftUI

struct TodoPriorityView: View {
    @StateObject var vm = TodoPriorityVM()
    
    @State private var isModalPresented = false
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vm.localItems){ item in
                    NavigationLink {
                        Text(item.priorityName!)
                    } label: {
                        Text(item.priorityName!)
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
                        Label("Add Priority", systemImage: "plus")
                    }
                    .fullScreenCover(isPresented: $isModalPresented, content: NewTodoPriorityView.init)
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

struct TodoPriorityView_Previews: PreviewProvider {
    static var previews: some View {
        TodoPriorityView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewInterfaceOrientation(.portrait)
    }
}
