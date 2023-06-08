//
//  RegisterViewViewModel.swift
//  Todo_List
//
//  Created by Cosmin Ghinea on 26.05.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class RegisterViewViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""

    init() {}

    func register() {
        guard validate() else {
            return
        }

        checkEmailRegistered()
    }

    private func checkEmailRegistered() {
        Auth.auth().fetchSignInMethods(forEmail: email) { [weak self] (signInMethods, error) in
            guard let self = self else { return }

            if let error = error {
                self.errorMessage = "An error occurred: \(error.localizedDescription)"
            } else if let signInMethods = signInMethods, !signInMethods.isEmpty {
                self.errorMessage = "Email is already registered."
            } else {
                self.createUser()
            }
        }
    }

    private func createUser() {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userId = result?.user.uid else {
                return
            }

            self?.insertUserRecord(id: userId)
        }
    }

    private func insertUserRecord(id: String) {
        let newUser = User(id: id,
                           name: name,
                           email: email,
                           joined: Date().timeIntervalSince1970)

        let db = Firestore.firestore()

        db.collection("users")
            .document(id)
            .setData(newUser.asDictionary())
    }

    private func validate() -> Bool {
        errorMessage = ""

        guard !name.trimmingCharacters(in: .whitespaces).isEmpty,
            !email.trimmingCharacters(in: .whitespaces).isEmpty,
            !password.trimmingCharacters(in: .whitespaces).isEmpty else {
                errorMessage = "Please fill in all fields."
                return false
        }

        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email."
            return false
        }

        guard password.count >= 6 else {
            errorMessage = "Password should have at least 6 characters."
            return false
        }

        return true
    }
}
