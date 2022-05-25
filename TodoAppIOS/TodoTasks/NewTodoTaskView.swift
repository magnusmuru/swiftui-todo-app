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
    @State var date = Date()
    @StateObject var vm = TodoTaskVM()
    @StateObject var priorityVm = TodoPriorityVM()
    @StateObject var categoryVm = TodoCategoryVM()
    
    
    var body: some View {
        
            List {
                Text("Task name")
                    .font(.callout)
                    .bold()
                
                TextField("Enter task name", text: $taskName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            
                Picker("Priority", selection: $selectedPriority) {
                    ForEach(self.priorityVm.localItems, id: \.self) { priority in
                        Text(priority.priorityName!)
                    }
                }
                .pickerStyle(.segmented)
                .task {
                    await priorityVm.getDataAsync()
                }
                Picker("Category", selection: $selectedCategory) {
                    ForEach(self.categoryVm.localItems, id: \.self) { priority in
                        Text(priority.categoryName!)
                    }
                }
                .pickerStyle(.inline)
                .task {
                    await categoryVm.getDataAsync()
                }
                
                DatePicker(
                        "Due Date",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                )
            }

            HStack {
                Button("Add"){
                    Task {
                        await vm.addItemAsync(name: taskName, todoPriority: selectedPriority, todoCategory: selectedCategory, dueDt: date)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                Button("Cancel"){
                    presentationMode.wrappedValue.dismiss()
                }

            }
            .padding(.horizontal)
        
    }
}

struct NewTodoTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NewTodoTaskView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

