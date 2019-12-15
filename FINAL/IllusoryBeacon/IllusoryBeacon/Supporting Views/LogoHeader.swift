//
//  LogoHeader.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/10/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI

struct LogoHeader: View {
    var body: some View {
        VStack {
            Image("icon")
                .resizable()
                .frame(width: 180, height: 180, alignment: .center)
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.IllusoryBeacon.sepia, lineWidth: 4))
                .shadow(radius: 10)
            Text("Illusory Beacon")
                .font(.custom("Futura-Medium", size: 42))
                .foregroundColor(Color.IllusoryBeacon.seconday)
                .padding(.top, 20)
        }
    }
}

struct LogoHeader_Previews: PreviewProvider {
    static var previews: some View {
        LogoHeader()
    }
}
