//
//  PostTextView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI
import Introspect
import CoreLocation

struct PostTextView: View {
    let delegate: DismissDelegate
    let currentLocationCoordinate: CLLocationCoordinate2D
    var beaconsManage: BeaconsManage?
    
    @State var text: String = ""
    
    @State private var isLoading: Bool = false
    @State private var showingAlert = false
    @State private var alertContent: String = ""
    
    var body: some View {
        VStack() {
            TextView(text: $text)
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 240)
            HStack {
                Image(systemName: "info.circle")
                    .imageScale(.medium)
                    .foregroundColor(.gray)
                Text("character limit: 16")
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .font(.footnote)
                    .foregroundColor(Color.gray)
            }.padding(.vertical, 10)
            VStack {
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
        }.padding([.leading, .trailing], 20)
        .navigationBarTitle(Text("Post Text"), displayMode: .large)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Post Failed"), message: Text(alertContent), dismissButton: .default(Text("OK")))
        }
    }
    
    func submit() {
        isLoading = true
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText != "" else {
            alertContent = "Empty text"
            showingAlert = true
            isLoading = false
            return
        }
        let returnMsg = UserClient.shared.postText(text: trimmedText, latitude: currentLocationCoordinate.latitude, longitude: currentLocationCoordinate.longitude)
        guard returnMsg == nil else {
            alertContent = returnMsg!
            showingAlert = true
            isLoading = false
            return
        }
        beaconsManage?.addTextNode(verbatim: trimmedText)
        isLoading = false
        self.delegate.dismissModal()
    }
}

struct PostTextView_Previews: PreviewProvider {
    class DumbDismissDelegate: DismissDelegate {
        func dismissModal() {}
    }
    
    static var previews: some View {
        PostTextView(delegate: DumbDismissDelegate(), currentLocationCoordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    }
}
