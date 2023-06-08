//
//  LoginView.swift
//  Todo_List
//
//  Created by Cosmin Ghinea on 26.05.2023.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewViewModel()
    @State private var isShowingForgotPasswordModal = false

    var body: some View {
        NavigationView {
            VStack {
                // Header
                HeaderView(title: "To Do List",
                           subtitle: "Get things done",
                           angle: 15,
                           background: .pink)
                
                Form {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(DefaultTextFieldStyle())
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color.red)
                    }
                    
                    TLButton(title: "Log in", background: .blue) {
                        viewModel.login()
                    }
                    .padding()
                    
                    Button(action: {
                        isShowingForgotPasswordModal = true
                    }) {
                        Text("Forgot password?")
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .offset(y: -50)
                
                // Create account
                VStack {
                    Text("New around here?")
                    
                    NavigationLink("Create an account",
                                   destination: RegisterView())
                }
                .padding(.bottom, 50)
                
                Spacer()
            }
        }
        .sheet(isPresented: $isShowingForgotPasswordModal) {
            ForgotPasswordModalView(email: $viewModel.email, resetPasswordAction: {
                viewModel.resetPassword()
                isShowingForgotPasswordModal = false
            }, onCancel: {
                isShowingForgotPasswordModal = false
            })
        }
        .alert(isPresented: $viewModel.showResetPasswordAlert) {
            Alert(
                title: Text("Reset Password"),
                message: Text("Reset password email sent"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
