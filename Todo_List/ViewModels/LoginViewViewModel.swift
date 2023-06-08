//
//  LoginViewViewModel.swift
//  Todo_List
//
//  Created by Cosmin Ghinea on 26.05.2023.
//

import Foundation
import FirebaseAuth
import Firebase

class LoginViewViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var resetPasswordEmailSent = false
    @Published var showResetPasswordAlert = false 
    
    init() { }
    
    func login() {
        guard validate() else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password)
    }
    
    private func validate() -> Bool {
        errorMessage = ""
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields."
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email."
            return false
        }
        
        checkEmailRegistered()
        
        return true
    }
    
    private func checkEmailRegistered() {
        Auth.auth().fetchSignInMethods(forEmail: email) { [weak self] (signInMethods, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "An error occurred: \(error.localizedDescription)"
            } else if let signInMethods = signInMethods, !signInMethods.isEmpty {
                self.checkPassword()
            } else {
                self.errorMessage = "Email is not registered."
            }
        }
    }
    
    private func checkPassword() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (_, error) in
            guard let self = self else { return }
            
            if error != nil {
                self.errorMessage = "Invalid password. Please try again."
            } else {
                Auth.auth().signIn(withEmail: self.email, password: self.password)
            }
        }
    }
    
    func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                // Handle the error
                print("Password reset failed: \(error.localizedDescription)")
            } else {
                // Password reset email sent successfully
                print("Password reset email sent to \(self?.email ?? "")")
                self?.resetPasswordEmailSent = true
                self?.showResetPasswordAlert = true
            }
        }
    }
    
    func resetPasswordEmailSentCompleted() {
        resetPasswordEmailSent = false
    }
}
