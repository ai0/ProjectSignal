//
//  ListMenuItem.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/10/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI

struct ListMenuItem: View {
    var itemText: String
    var iconName: String
    var actionIconName: String = "chevron.right"
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .frame(width: 24)
                .imageScale(.medium)
                .foregroundColor(.gray)
            Text(itemText)
            Spacer()
            Image(systemName: actionIconName)
                .frame(width:24)
                .imageScale(.medium)
                .foregroundColor(.gray)
        }.padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

struct ListMenuItem_Previews: PreviewProvider {
    static var previews: some View {
        ListMenuItem(itemText: "Settings", iconName:"gear")
    }
}
