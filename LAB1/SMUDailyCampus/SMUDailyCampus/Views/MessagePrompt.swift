//
//  MessagePrompt.swift
//  SMUDailyCampus
//
//  Created by Jing Su on 9/15/19.
//  Copyright © 2019 Jing Su. All rights reserved.
//

import SwiftMessages

class MessagePrompt {
    
    let success = Theme.success
    let warning = Theme.warning
    let error = Theme.error
    let info = Theme.info
    
    func prompt(theme: Theme, content: String, duration: Double) {
        let messageView = MessageView.viewFromNib(layout: .statusLine)
        var messageConfig = SwiftMessages.Config()
        messageConfig.presentationContext = .window(windowLevel: .statusBar)
        if duration > 0 {
            messageConfig.duration = .seconds(seconds: duration)
        } else {
            messageConfig.duration = .forever
        }
        messageView.configureTheme(theme)
        messageView.configureContent(body: content)
        SwiftMessages.show(config: messageConfig, view: messageView)
    }
    
}
