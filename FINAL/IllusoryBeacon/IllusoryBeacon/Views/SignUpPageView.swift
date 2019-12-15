//
//  SignUpPageView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/9/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI
import Introspect

struct SignUpPageView: View {
    @State private var email: String = ""
    @State private var nickname: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    @State private var isLoading: Bool = false
    @State private var showingAlert = false
    @State private var alertContent: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            LogoHeader()
            Spacer()
            VStack {
                VStack {
                    // SwiftUI does not support define ReturnKeyType natively at this moment
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .introspectTextField { textField in
                            textField.returnKeyType = .done
                        }
                    TextField("Nickname", text: $nickname)
                        .textContentType(.nickname)
                        .keyboardType(.asciiCapable)
                        .introspectTextField { textField in
                            textField.returnKeyType = .done
                        }
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                        .keyboardType(.asciiCapable)
                        .introspectTextField { textField in
                            textField.returnKeyType = .done
                        }
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .keyboardType(.asciiCapable)
                        .introspectTextField { textField in
                            textField.returnKeyType = .done
                        }
                }.font(.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                VStack {
                    Button(action: signup) {
                        Text(isLoading ? "Loading..." : "Sign Up")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 64)
                            .foregroundColor(Color.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color("DarkGreen"), Color("LightGreen")]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(5)
                            .shadow(radius: 10)
                            .padding(.vertical, 5)
                    }
                    AgreeToSFooter(buttonName: "Sign Up")
                        .padding(.horizontal, -15)
                        .padding(.top, 5)
                }
            }.padding(.horizontal, 20)
            Spacer()
        }.modifier(AdaptsToSoftwareKeyboard())
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Signup Failed"), message: Text(alertContent), dismissButton: .default(Text("OK")))
        }
    }
    
    func signup() {
        isLoading = true
        guard password == confirmPassword else {
            alertContent = "Confirm passwords is identical."
            showingAlert = true
            isLoading = false
            return
        }
        let returnMsg = UserClient.shared.signup(email: email, nickname: nickname, password: password)
        if returnMsg != nil {
            alertContent = returnMsg!
            showingAlert = true
            isLoading = false
            return
        }
        isLoading = false
        showMainTabBarView()
    }
    
    func showMainTabBarView() {
        let storyboard = UIStoryboard.init(name: "TabView", bundle: nil)
        let tabBar = storyboard.instantiateViewController(withIdentifier: "MainTabBar")
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }!
        window.rootViewController = tabBar
        UIView.transition(with: window, duration: 2.0, options: .transitionFlipFromBottom, animations: nil, completion: nil)
    }
}

struct SignUpPageView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpPageView()
    }
}
