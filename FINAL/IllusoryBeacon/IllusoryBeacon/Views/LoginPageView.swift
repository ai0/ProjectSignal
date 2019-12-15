//
//  LoginPageView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/9/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI

struct LoginPageView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
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
                    // SwiftUI does not support define ReturnKeyType at this moment
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .introspectTextField { textField in
                            textField.returnKeyType = .done
                        }
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .keyboardType(.asciiCapable)
                        .introspectTextField { textField in
                            textField.returnKeyType = .done
                        }
                }.font(.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: login) {
                    Text(isLoading ? "Loading..." : "Login")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 64)
                        .foregroundColor(Color.white)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(5)
                        .shadow(radius: 10)
                        .padding(.top, 40)
                }
                AgreeToSFooter(buttonName: "Login")
                    .padding(.horizontal, -15)
                    .padding(.top, 5)
            }.padding([.leading, .trailing], 20)
            Spacer()
        }.modifier(AdaptsToSoftwareKeyboard())
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Login Failed"), message: Text(alertContent), dismissButton: .default(Text("OK")))
        }
    }
    
    func login() {
        isLoading = true
        let returnMsg = UserClient.shared.login(email: email, password: password)
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

struct LoginPageView_Previews: PreviewProvider {
    static var previews: some View {
        LoginPageView()
    }
}
