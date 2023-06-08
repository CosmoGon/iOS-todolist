//
//  TodoView.swift
//  Todo_List
//
//  Created by Cosmin Ghinea on 26.05.2023.
//

import SwiftUI
import FirebaseFirestoreSwift

struct TodoView: View {
    @StateObject var viewModel: TodoViewViewModel
    @FirestoreQuery var items: [ToDoListItem]
    
    init(userId: String) {
        self._items = FirestoreQuery(
            collectionPath: "users/\(userId)/todos"
        )
        self._viewModel = StateObject (
            wrappedValue: TodoViewViewModel(userId: userId)
        )
    }
    
    var sortedItems: [ToDoListItem] {
        items.sorted { $0.dueDate < $1.dueDate }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(sortedItems) { item in
                    TodoListItemView(item: item)
                        .swipeActions {
                            Button("Delete") {
                                viewModel.delete(id: item.id)
                            }
                            .tint(.red)
                        }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("To Do List")
            .toolbar {
                Button {
                    viewModel.showingNewItemView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewItemView) {
                NewItemView(newItemPresented: $viewModel.showingNewItemView)
            }
        }
    }
}


struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView(userId: "1SJX5Umj5IhzvKYyIjrz3eilBZ13")
    }
}
