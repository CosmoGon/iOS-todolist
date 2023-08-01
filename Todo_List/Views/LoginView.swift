//
//  LoginView.swift
//  Todo_List
//
//  Created by Cosmin Ghinea on 28.06.2023.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewViewModel()
    @State private var isShowingForgotPasswordModal = false
    @Binding var isPresentingLoginModal: Bool
    
    var body: some View {
        NavigationView {
            VStack {
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
                
                // Create account
                VStack {
                    Text("New around here?")
                    
                    NavigationLink("Create an account",
                                   destination: RegisterView())
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarTitle("Log in", displayMode: .inline)
        .navigationBarItems(trailing: Button("Dismiss", action: {
            isPresentingLoginModal.toggle()
        }))
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
        @State var isPresentingLoginModal = true
        LoginView(isPresentingLoginModal: $isPresentingLoginModal)
    }
}
