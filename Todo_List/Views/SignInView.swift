//
//  LoginView.swift
//  Todo_List
//
//  Created by Cosmin Ghinea on 26.05.2023.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var coordinator: SignInWithAppleCoordinator?
    @State private var animationProgress: Double = 0.0
    @State private var isPresentingLoginModal = false
    
    func interpolate(_ progress: Double, delay: Double) -> CGFloat {
        let value = max(0, progress - delay)
        return CGFloat(1 - value) * 30
    }

    var body: some View {
        NavigationView {
            VStack {
                HeaderView(title: "To Do List",
                           subtitle: "Get things done",
                           angle: 15,
                           background: .pink)
                
                Text("Please sign in here.")
                SignInWithAppleButton()
                    .frame(width: 280, height: 45)
                    .onTapGesture {
                        self.coordinator = SignInWithAppleCoordinator()
                        if let coordinator = self.coordinator {
                            coordinator.startSignInWithAppleFlow {
                                print("You successfully signed in.")
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                Button(action: {
                    isPresentingLoginModal.toggle()
                }) {
                    Text("Sign in with email")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 280, height: 45)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.bottom, 64)
                }
                .offset(y: interpolate(animationProgress, delay: 0.5))
                .animation(.easeInOut(duration: 0.5), value: animationProgress)
                
            }
            .padding(.horizontal, 20)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.7)) {
                    animationProgress = 1.0
                }
            }
            .sheet(isPresented: $isPresentingLoginModal) {
                LoginView(isPresentingLoginModal: $isPresentingLoginModal)
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
