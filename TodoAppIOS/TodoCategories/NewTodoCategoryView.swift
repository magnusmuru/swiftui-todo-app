//
//  NewTodoCategoryView.swift
//  TodoAppIOS
//
//  Created by Andres Käver on 25.04.2022.
//

import SwiftUI

struct NewTodoCategoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @State var categoryName: String = ""
    @StateObject var vm = TodoCategoryVM()
    
    var body: some View {
        
        VStack (alignment: .trailing) {
            VStack (alignment: .leading){
                
                Text("Catgeory name")
                    .font(.callout)
                    .bold()
                
                TextField("Enter category name", text: $categoryName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            HStack {
                Button("Add"){
                    Task {
                        await vm.addItemAsync(name: categoryName)
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

struct NewTodoCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NewTodoCategoryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
