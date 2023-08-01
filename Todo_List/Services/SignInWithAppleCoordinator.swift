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
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first {
            return window
        } else {
            fatalError("Unable to retrieve window scene.")
        }

    }
    
    

    // Unhashed nonce.
    fileprivate var currentNonce: String?

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
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential, including the user's full name.
      let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                        rawNonce: nonce,
                                                        fullName: appleIDCredential.fullName)
        Auth.auth().currentUser?.link(with: credential, completion: { (authresult, error) in
            if let error = error, (error as NSError).code == AuthErrorCode.credentialAlreadyInUse.rawValue {
                print("The user you're trying to sign in with has already been linked.")
                if let updatedCredential = (error as NSError).userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? OAuthCredential {
                    print("Signin in using the updated credentials.")
                    Auth.auth().signIn(with: updatedCredential) { (authresult, error) in
                        if (authresult?.user) != nil {
                            if let callback = self.onSignedIn {
                                callback()
                            }
                        }
                    }
                }
            }
            else {
                if let callback = self.onSignedIn {
                    callback()
                }
            }
        })
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

    
