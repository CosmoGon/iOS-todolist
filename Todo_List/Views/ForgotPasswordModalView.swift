//
//  ForgotPasswordModalView.swift
//  Todo_List
//
//  Created by Cosmin Ghinea on 07.06.2023.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordModalView: View {
    @Binding var email: String
    @State private var errorMessage: String = ""
    var resetPasswordAction: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Reset Password")
                .font(.title)
                .foregroundColor(.primary)
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer(minLength: 8)

            HStack(spacing: 16) {
                Button(action: {
                    if email.isEmpty {
                        errorMessage = "Please enter your email."
                    } else {
                        // Check if the email is registered in Firebase Authentication
                        isEmailRegistered(email: email) { isRegistered in
                            if isRegistered {
                                errorMessage = ""
                                resetPasswordAction()
                            } else {
                                errorMessage = "This email is not registered."
                            }
                        }
                    }
                }) {
                    Text("Reset Password")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(8)
                }

                Button(action: onCancel) {
                    Text("Cancel")
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(8)
                }
            }

            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)
                .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color(.systemGray).opacity(0.4), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .frame(height: 250)
        .transition(.move(edge: .bottom))
    }

    private func isEmailRegistered(email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().fetchSignInMethods(forEmail: email) { signInMethods, error in
            if let error = error {
                print("Error checking email registration: \(error.localizedDescription)")
                completion(false)
            } else {
                if let signInMethods = signInMethods, !signInMethods.isEmpty {
                    // Email is registered
                    completion(true)
                } else {
                    // Email is not registered
                    completion(false)
                }
            }
        }
    }
}

struct ForgotPasswordModalView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordModalView(email: .constant(""), resetPasswordAction: {}, onCancel: {})
    }
}
