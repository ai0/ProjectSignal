//
//  PostMenuView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI
import CoreLocation

struct PostMenuView: View {
    let delegate: DismissDelegate
    let currentLocationCoordinate: CLLocationCoordinate2D
    var beaconsManage: BeaconsManage?
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Please choose a post type:")
                    .font(.title)
                HStack{
                    Spacer()
                    NavigationLink(destination: PostTextView(delegate: delegate, currentLocationCoordinate: currentLocationCoordinate, beaconsManage: beaconsManage)) {
                        VStack {
                            Image("text-icon")
                                .resizable()
                                .frame(width: 96, height: 96, alignment: .center)
                            Text("Text")
                                .font(.custom("Futura-Medium", size: 18))
                        }.foregroundColor(Color.IllusoryBeacon.primary)
                    }
                    Spacer()
                    NavigationLink(destination: PostImageView(delegate: delegate, currentLocationCoordinate: currentLocationCoordinate, beaconsManage: beaconsManage)) {
                        VStack {
                            Image("image-icon")
                                .resizable()
                                .frame(width: 96, height: 96, alignment: .center)
                            Text("Image")
                                .font(.custom("Futura-Medium", size: 18))
                        }.foregroundColor(Color.IllusoryBeacon.primary)
                    }
                    Spacer()
                }.padding(.vertical, 40)
                Button(action: delegate.dismissModal) {
                    Text("Cancel")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 64)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .cornerRadius(5)
                }
            }.padding([.leading, .trailing], 20)
        }
    }
}

struct PostMenuView_Previews: PreviewProvider {
    class DumbDismissDelegate: DismissDelegate {
        func dismissModal() {}
    }
    
    static var previews: some View {
        PostMenuView(delegate: DumbDismissDelegate(), currentLocationCoordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    }
}
