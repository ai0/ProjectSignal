//
//  DismissDelegate.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/7/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

//import Combine
//
//final class DismissDelegate: ObservableObject {
//
//    //@Published var onDismiss = false
//
//    let objectDidChange = PassthroughSubject<DismissDelegate, Never>()
//
//    var onDismiss = false {
//        didSet {
//            objectDidChange.send(self)
//        }
//    }
//
//}

/* The above code did not work...
   and hard to debug the bindable object life cycle
   SwiftUI is pretty buggy
   So let's do it simple & dirty */

protocol DismissDelegate {

    func dismissModal() -> ()
    
}

