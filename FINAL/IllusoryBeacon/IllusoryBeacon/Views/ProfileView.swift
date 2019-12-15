//
//  ProfileView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/10/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
    
    @ObservedObject var userStatus: UserStatusObservable

    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    ProfileCard(avatarImage: userStatus.avatar, nickname: userStatus.nickname, email: userStatus.email)
                    HStack {
                        Spacer()
                        VStack {
                            Text("\(userStatus.postTexts)")
                                .font(.custom("HelveticaNeue-UltraLight", size: 72))
                            Text("Posted Text")
                                .font(.custom("Futura-Medium", size: 18))
                        }.foregroundColor(Color.IllusoryBeacon.primary)
                        Spacer()
                        VStack {
                            Text("\(userStatus.postImages)")
                                .font(.custom("HelveticaNeue-UltraLight", size: 72))
                            Text("Posted Image")
                                .font(.custom("Futura-Medium", size: 18))
                        }.foregroundColor(Color.IllusoryBeacon.primary)
                        Spacer()
                    }
                }.padding(.horizontal, 20)
                    .padding(.top, 20)
                VStack {
                    NavigationLink(destination: SettingsView().environmentObject(SettingsObservable())) {
                        ListMenuItem(itemText: "Settings", iconName: "gear")
                            .foregroundColor(Color.blue)
                    }
                    Button(action: logout) {
                        ListMenuItem(itemText: "Logout", iconName: "xmark.square")
                            .foregroundColor(Color.red)
                    }
                }.padding(.top, 20)
                Spacer()
            }.navigationBarTitle(Text("Profile"))
        }
    }
    
    func logout() {
        if UserClient.shared.logout() {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }!
            window.rootViewController = UIHostingController(
                rootView: WelcomePageView()
            )
            UIView.transition(with: window, duration: 2.0, options: .transitionFlipFromBottom, animations: nil, completion: nil)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userStatus: UserStatusObservable())
    }
}
