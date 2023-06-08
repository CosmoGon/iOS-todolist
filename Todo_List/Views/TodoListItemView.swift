//
//  TodoListItemView.swift
//  Todo_List
//
//  Created by Cosmin Ghinea on 26.05.2023.
//

import SwiftUI

struct TodoListItemView: View {
    @StateObject var viewModel = TodoListItemViewViewModel()
    @State private var isEditing = false
    @State private var updatedTitle = ""
    
    let item: ToDoListItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if isEditing {
                    TextField("Enter title", text: $updatedTitle, onCommit: {
                        viewModel.updateItemTitle(item: item, newTitle: updatedTitle)
                        isEditing = false
                    })
                    .font(.body)
                } else {
                    Text(item.title)
                        .font(.body)
                        .onTapGesture {
                            isEditing = true
                            updatedTitle = item.title
                        }
                }
                
                Text("\(Date(timeIntervalSince1970: item.dueDate).formatted(date: .abbreviated, time: .shortened))")
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
            }
            
            Spacer()
            
            Button {
                viewModel.toggleIsDone(item: item)
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(Color.blue)
            }
        }
    }
}

struct TodoListItemView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListItemView(item: .init(id: "123",
                                     title: "Get milk",
                                     dueDate: Date().timeIntervalSince1970,
                                     createdDate: Date().timeIntervalSince1970,
                                     isDone: false
                                    ))
    }
}
