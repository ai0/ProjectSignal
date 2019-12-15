//
//  ProfileCard.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/10/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI

struct ProfileCard: View {
    var avatarImage: UIImage
    var nickname: String
    var email: String
    
    var body: some View {
        HStack {
            AvatarView(image: avatarImage)
                .frame(width: 64, height: 64)
            VStack(alignment: .leading) {
                Text(nickname)
                Text(email)
                    .padding(.top, 5)
            }.padding(.leading, 10)
            Spacer()
        }.padding(.horizontal, 20)
            .padding(.vertical, 15)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.black, lineWidth: 3))
    }
}

struct ProfileCard_Previews: PreviewProvider {
    static var previews: some View {
        ProfileCard(avatarImage: UIImage(named: "icon")!,
                    nickname: "Zen",
                    email: "beacon@io.vc")
    }
}
