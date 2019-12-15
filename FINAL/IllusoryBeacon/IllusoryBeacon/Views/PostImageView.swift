//
//  PostImageView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI
import CoreLocation

struct PostImageView: View {
    let delegate: DismissDelegate
    let currentLocationCoordinate: CLLocationCoordinate2D
    var beaconsManage: BeaconsManage?
    
    @State var showImagePicker: Bool = false
    @State var image: UIImage? = nil
    
    @State private var isLoading: Bool = false
    @State private var showingAlert = false
    @State private var alertContent: String = ""
    
    var body: some View {
        VStack() {
            Image(uiImage: image ?? UIImage(named: "image-icon")!)
                .resizable()
                .scaledToFit()
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 360)
                .shadow(radius: 10)
            VStack {
                Button(action: chooseImage) {
                    Text("Choose Image")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 64)
                        .foregroundColor(Color.white)
                        .background(Color.gray)
                        .cornerRadius(5)
                }.padding(.vertical, 5)
                Button(action: submit) {
                    Text(isLoading ? "Posting..." : "Submit")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 64)
                        .foregroundColor(Color.white)
                        .background(Color.blue)
                        .cornerRadius(5)
                }.padding(.vertical, 5)
                Button(action: delegate.dismissModal) {
                    Text("Cancel")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 64)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .cornerRadius(5)
                }.padding(.vertical, 5)
            }.padding(.vertical, 20)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: self.$image)
            }
        }.padding([.leading, .trailing], 20)
        .navigationBarTitle(Text("Post Image"), displayMode: .large)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Post Failed"), message: Text(alertContent), dismissButton: .default(Text("OK")))
        }
    }
    
    func chooseImage() {
        withAnimation {
            self.showImagePicker = true
        }
    }
    
    func submit() {
        isLoading = true
        guard image != nil else {
            alertContent = "No image selected"
            showingAlert = true
            isLoading = false
            return
        }
        let resizedImage = image!.resize(targetSize: CGSize(width: 1280, height: 720))
        let returnMsg = UserClient.shared.postImage(image: resizedImage, latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude)
        guard returnMsg == nil else {
            alertContent = returnMsg!
            showingAlert = true
            isLoading = false
            return
        }
        beaconsManage?.addImageNode(image: resizedImage)
        isLoading = false
        self.delegate.dismissModal()
    }
}

struct PostImageView_Previews: PreviewProvider {
    class DumbDismissDelegate: DismissDelegate {
        func dismissModal() {}
    }
    
    static var previews: some View {
        PostImageView(delegate: DumbDismissDelegate(), currentLocationCoordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    }
}
