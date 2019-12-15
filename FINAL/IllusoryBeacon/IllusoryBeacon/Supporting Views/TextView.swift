//
//  TextView.swift
//  IllusoryBeacon
//
//  Created by Jing Su on 12/11/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {

        let textView = UITextView()
        textView.delegate = context.coordinator

        textView.font = UIFont(name: "HelveticaNeue", size: 18)
        textView.textColor = UIColor.white
        textView.backgroundColor = UIColor.IllusoryBeacon.primary
        
        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true

        textView.textContainer.maximumNumberOfLines = 1
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.keyboardType = .asciiCapable
        textView.returnKeyType = .done

        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    class Coordinator : NSObject, UITextViewDelegate {

        var parent: TextView

        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                textView.resignFirstResponder()
                return false
            }
            // 16 chars restriction
            return textView.text.count + (text.count - range.length) <= 16
        }

        func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
    }
}
