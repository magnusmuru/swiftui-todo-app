//
//  NewTodoTaskView.swift
//  TodoAppIOS
//
//  Created by Magnus Muru on 25.05.2022.
//

import SwiftUI

struct NewTodoTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State var taskName: String = ""
    @State var selectedPriority: TodoPriority = TodoPriority()
    @State var selectedCategory: TodoCategory = TodoCategory()
    @StateObject var vm = TodoTaskVM()
    @StateObject var priorityVm = TodoPriorityVM()
    @StateObject var categoryVm = TodoCategoryVM()
    
    
    var body: some View {
        
        VStack (alignment: .trailing) {
            List {
                Text("Task name")
                    .font(.callout)
                    .bold()
                
                TextField("Enter task name", text: $taskName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            
                Picker("Priority", selection: $selectedPriority) {
                    ForEach(priorityVm.localItems, id: \.self) { priority in
                        Text(priority.priorityName!)
                    }
                }
                Picker("Category", selection: $selectedCategory) {
                    ForEach(categoryVm.localItems, id: \.self, content: { category in
                        Text(category.categoryName!)
                    })
                }
            }

            HStack {
                Button("Add"){
                    Task {
                        await vm.addItemAsync(name: taskName)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                Button("Cancel"){
                    presentationMode.wrappedValue.dismiss()
                }

            }
            .padding(.horizontal)

        }
        .task {
            await categoryVm.getDataAsync()
            await priorityVm.getDataAsync()
        }
        
    }
}

struct NewTodoTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NewTodoTaskView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

