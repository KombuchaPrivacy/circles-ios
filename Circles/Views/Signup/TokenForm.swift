//
//  TokenForm.swift
//  Circles
//
//  Created by Charles Wright on 9/7/21.
//

import SwiftUI

struct TokenForm: View {
    let tokenType: String
    var matrix: MatrixInterface
    @Binding var authFlow: UiaaAuthFlow?

    @State var signupToken: String = ""

    @State var pending = false

    @State var showAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""

    let helpTextForToken = """
    In order to sign up for the service, every new user must present a valid registration token.

    If you found out about the app from a friend or from a posting online, you should be able to get a signup token from the same source.
    """

    let helpTextForTokenFailed = """
    Failed to validate token
    """

    //let stage = LOGIN_STAGE_SIGNUP_TOKEN

    var body: some View {
        VStack {
            //let currentStage: SignupStage = .validateToken

            Spacer()

            Text("Validate your token")
                .font(.title)
                .fontWeight(.bold)

            HStack {
                TextField("abcd-efgh-1234-5678", text: $signupToken)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                Spacer()
                Button(action: {
                    self.showAlert = true
                    self.alertTitle = "Signup Token"
                    self.alertMessage = helpTextForToken
                }) {
                    Image(systemName: "questionmark.circle")
                }
            }
            .frame(width: 300.0, height: 40.0)

            Button(action: {
                if signupToken.isEmpty {
                    return
                }
                // Call out to the server to validate our token
                // If successful, set stage = .getEmail
                self.pending = true
                matrix.signupDoTokenStage(token: signupToken, tokenType: tokenType) { response in
                    switch response {
                    case .failure(let err):
                        print("SIGNUP\tToken stage failed: \(err)")
                        self.showAlert = true
                        self.alertTitle = "Token validation failed"
                        self.alertMessage = helpTextForTokenFailed
                    case .success:
                        // We're done with the current stage.  Let's move on to the next one.
                        //self.stage = next[currentStage]!
                        authFlow?.pop(stage: tokenType)
                    }
                    self.pending = false
                }
            }) {
                Text("Validate Token")
                    .padding()
                    .frame(width: 300.0, height: 40.0)
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(10)
            }
            .disabled(pending)
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle),
                      message: Text(alertMessage),
                      dismissButton: .cancel(Text("OK"))
                )
            }

            Spacer()


            if KOMBUCHA_DEBUG {
                Text(matrix.signupGetSessionId() ?? "Error: No signup session")
                    .font(.footnote)
            }
        }
    }
}

/*
struct TokenStage_Previews: PreviewProvider {
    static var previews: some View {
        TokenStage()
    }
}
*/
