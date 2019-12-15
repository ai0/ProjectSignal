//
//  WelcomePageView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/7/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI
import Introspect

struct WelcomePageView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                LogoHeader()
                Spacer()
                VStack {
                    NavigationLink(destination: SignUpPageView()) {
                        Text("Sign Up")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 64)
                            .foregroundColor(Color.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color("DarkGreen"), Color("LightGreen")]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(5)
                            .shadow(radius: 10)
                            .padding([.leading, .trailing], 20)
                    }
                    NavigationLink(destination: LoginPageView()) {
                        Text("Login")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: 64)
                            .foregroundColor(Color.white)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(5)
                            .shadow(radius: 10)
                            .padding([.leading, .trailing], 20)
                            .padding(.top, 20)
                    }
                }
                Spacer()
            }
        }.introspectNavigationController { navigationController in
            navigationController.navigationBar.tintColor = UIColor.IllusoryBeacon.primary
        }
    }
}

struct WelcomePage_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePageView()
    }
}
