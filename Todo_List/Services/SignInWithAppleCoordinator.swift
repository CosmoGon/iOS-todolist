//
//  SignInWithAppleCoordinator.swift
//  Todo_List
//
//  Created by Cosmin Ghinea on 28.06.2023.
//

import Foundation
import CryptoKit
import AuthenticationServices
import Firebase

class SignInWithAppleCoordinator: NSObject, ASAuthorizationControllerPresentationContextProviding {
    private var onSignedIn: (() -> Void)?
    fileprivate var currentNonce: String?
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("Unable to retrieve window scene.")
        }
        return window
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow(onSignedIn: @escaping () -> Void) {
        self.onSignedIn = onSignedIn
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

@available(iOS 13.0, *)
extension SignInWithAppleCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else { fatalError("Invalid state.") }
            guard let appleIDToken = appleIDCredential.identityToken else { return }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { return }
            
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Error signing in with Apple: \(error.localizedDescription)")
                    return
                }
                
                guard let user = authResult?.user else { return }
                let db = Firestore.firestore()
                
                // Check if the user document exists
                let userDocRef = db.collection("users").document(user.uid)
                userDocRef.getDocument { document, error in
                    if let document = document, document.exists {
                        // User document exists, no need to create it
                        print("User document already exists.")
                    } else {
                        // Create the user document
                        let userData: [String: Any] = [
                            "id": user.uid,
                            "name": user.displayName ?? "Anonymous",
                            "email": user.email ?? "",
                            "joined": Date().timeIntervalSince1970
                        ]
                        userDocRef.setData(userData) { error in
                            if let error = error {
                                print("Error creating user document: \(error.localizedDescription)")
                            } else {
                                print("User document created.")
                            }
                        }
                    }
                }
                
                if let callback = self.onSignedIn {
                    callback()
                }
            }
        }
    }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }
}

private func randomNonceString(length: Int = 32) -> String {
  precondition(length > 0)
  var randomBytes = [UInt8](repeating: 0, count: length)
  let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
  if errorCode != errSecSuccess {
    fatalError(
      "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
    )
  }

  let charset: [Character] =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

  let nonce = randomBytes.map { byte in
    // Pick a random character from the set, wrapping around if needed.
    charset[Int(byte) % charset.count]
  }

  return String(nonce)
}

@available(iOS 13, *)
private func sha256(_ input: String) -> String {
  let inputData = Data(input.utf8)
  let hashedData = SHA256.hash(data: inputData)
  let hashString = hashedData.compactMap {
    String(format: "%02x", $0)
  }.joined()

  return hashString
}

    
