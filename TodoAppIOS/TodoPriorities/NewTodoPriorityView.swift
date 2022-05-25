//
//  NewTodoPriorityView.swift
//  TodoAppIOS
//
//  Created by Magnus Muru on 22.05.2022.
//

import SwiftUI

struct NewTodoPriorityView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State var priorityName: String = ""
    @StateObject var vm = TodoPriorityVM()
    
    
    var body: some View {
        
        VStack (alignment: .trailing) {
            VStack (alignment: .leading){
                
                Text("Priority level")
                    .font(.callout)
                    .bold()
                
                TextField("Enter priority level", text: $priorityName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            HStack {
                Button("Add"){
                    Task {
                        await vm.addItemAsync(name: priorityName)
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
}

struct NewTodoPriorityView_Previews: PreviewProvider {
    static var previews: some View {
        NewTodoPriorityView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
