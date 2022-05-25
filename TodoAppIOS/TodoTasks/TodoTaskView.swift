//
//  TodoTaskView.swift
//  TodoAppIOS
//
//  Created by Andres Käver on 25.04.2022.
//

import SwiftUI

struct TodoTaskView: View {
    @StateObject var vm = TodoTaskVM()
    
    @State private var isModalPresented = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vm.localItems){ item in
                    NavigationLink {
                        Text(item.taskName ?? "None")
                    } label: {
                        Text(item.taskName ?? "None")
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
                        Label("Add Task", systemImage: "plus")
                    }
                    .fullScreenCover(isPresented: $isModalPresented, content: NewTodoTaskView.init)
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet){
        withAnimation {
            for i in offsets.makeIterator() {
                let item = vm.localItems[i]
                vm.deleteItemAsync(item: item)
            }
        }
    }
}

struct TodoTaskView_Previews: PreviewProvider {
    static var previews: some View {
        TodoTaskView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewInterfaceOrientation(.portrait)
    }
}
