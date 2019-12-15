//
//  ToSPageView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/10/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI

struct ToSPageView: View {
    @Binding var display: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Terms of Service")
                .font(.largeTitle)
            Text(TERMS_OF_SERVICE)
                .font(.body)
                .padding(.vertical, 20)
            Button(action: {
                self.display = false
            }) {
                Text("Close")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 64)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(5)
            }
        }.padding([.leading, .trailing], 20)
    }
}

struct ToSPageView_Previews: PreviewProvider {
    static var previews: some View {
        ToSPageView(display: .constant(true))
    }
}
