//
//  AvatarView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/10/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI

struct AvatarView: View {
    var image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 10)
    }
}

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        AvatarView(image: UIImage(named: "icon")!)
    }
}
