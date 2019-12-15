//
//  SettingsView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/10/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI
import SafariServices

struct SettingsView: View {
    @EnvironmentObject var settingsObservable: SettingsObservable
    
    var body: some View {
        VStack(alignment: .leading) {
            Form {
                Section(header: Text("Location Provider")) {
                    Picker(selection: $settingsObservable.locationByGPS, label: Text("Display Order")) {
                        Text("GPS").tag(0)
                        Text("Camera").tag(1)
                    }
                    .padding(.top, -4.0)
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Location Prediction Interval")) {
                    Text("\(Int(settingsObservable.locationPredictionInterval)) seconds")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    Slider(value: $settingsObservable.locationPredictionInterval, in: 1...60, step: 1)
                }
                Section(header: Text("Walk Steps to Update Scene")) {
                    Text("\(Int(settingsObservable.stepsToUpdateScene)) steps")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    Slider(value: $settingsObservable.stepsToUpdateScene, in: 0...60, step: 1)
                }
                Section(header: Text("Maximum Object per Scene")) {
                    Text("\(Int(settingsObservable.maximumObjectPerScene)) objects")
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    Slider(value: $settingsObservable.maximumObjectPerScene, in: 0...20, step: 1)
                }
                Section {
                    Button(action: openGravatar) {
                        HStack {
                            Text("Change avatar via Gravatar")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .imageScale(.medium)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(.top, 20)
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarTitle(Text("Settings"), displayMode: .inline)
    }
    
    func openGravatar() {
        UIApplication.shared.open(URL(string: EXTERNAL_GRAVATAR_URL)!)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(SettingsObservable())
    }
}
