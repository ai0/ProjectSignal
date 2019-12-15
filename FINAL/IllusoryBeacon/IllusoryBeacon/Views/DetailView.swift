//
//  DetailView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/7/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI
import CoreLocation

struct DetailView: View {
    
    @EnvironmentObject var previewContent: PreviewContent
    
    let delegate: DismissDelegate
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                displayView(for: previewContent)
            }.padding([.leading, .trailing], 20)
            Spacer()
            Button(action: delegate.dismissModal) {
                Text("OK")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 64)
                    .foregroundColor(Color.white)
                    .background(Color.blue)
                    .cornerRadius(5)
                    .padding([.leading, .trailing], 20)
            }
            Spacer()
        }
    }
    
    func displayView(for previewContent: PreviewContent) -> AnyView {
        switch previewContent.contentType {
        case .Text:
            return AnyView(Text(previewContent.textContent!)
                .font(.largeTitle))
        case .Image:
            return AnyView(Image(uiImage: previewContent.imageContent!)
                .resizable()
                .scaledToFit()
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 360)
                .border(Color.white, width: 4)
                .shadow(radius: 10))
        case .Map:
            return AnyView(MapView(coordinate: previewContent.locationCoordinate!)
                .frame(height: 360)
                .cornerRadius(15))
        default:
            return AnyView(Text("Failed to load")
                .font(.largeTitle))
        }
    }

}

struct ARObjectDetailView_Previews: PreviewProvider {

    class DumbDismissDelegate: DismissDelegate {
        func dismissModal() {}
    }

    static var previews: some View {
        Group {
            DetailView(delegate: DumbDismissDelegate())
                .environmentObject(PreviewContent(textContent: "Illusory Beacon!"))
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro"))
                .previewDisplayName("Text")

            DetailView(delegate: DumbDismissDelegate())
                .environmentObject(PreviewContent(locationCoordinate: CLLocationCoordinate2D(latitude: 32.8452754, longitude: -96.7848905))) // SMU Dallas Hall
                .previewDevice(PreviewDevice(rawValue: "iPhone 11 Pro"))
                .previewDisplayName("Map")
        }
    }
}
