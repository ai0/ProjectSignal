//
//  AgreeToSFooter.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/10/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI

struct AgreeToSFooter: View {
    
    let buttonName: String
    
    @State private var shouldDisplayToS: Bool = false
    
    var body: some View {
        Button(action: {
            self.shouldDisplayToS = true
        }) {
            Text("↗️ By clicking the \(buttonName) button above, I hereby agree to and accept the terms of service.")
                .font(.footnote)
                .foregroundColor(.blue)
        }.sheet(isPresented: $shouldDisplayToS) {
            ToSPageView(display: self.$shouldDisplayToS)
        }
    }
}

struct AgreeToSFooter_Previews: PreviewProvider {
    static var previews: some View {
        AgreeToSFooter(buttonName: "Sign Up")
    }
}
