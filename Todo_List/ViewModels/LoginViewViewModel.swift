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
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (_, error) in
            guard let self = self else { return }
            
            if let error = error as NSError? {
                print("Login error code: \(error.code)")
                print("Login error description: \(error.localizedDescription)")
                self.handleAuthError(error)
            } else {
                // Handle successful login
                self.errorMessage = ""
            }
        }
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
        
        return true
    }
    
    private func handleAuthError(_ error: NSError) {
        switch error.code {
        case AuthErrorCode.wrongPassword.rawValue:
            self.errorMessage = "Invalid password. Please try again."
        case AuthErrorCode.userNotFound.rawValue:
            self.errorMessage = "Email is not registered."
        default:
            self.errorMessage = "An error occurred: \(error.localizedDescription)"
        }
    }
    
    func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            if let error = error {
                // Handle the error
                print("Password reset error: \(error.localizedDescription)")
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
