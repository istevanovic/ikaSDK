//
//  MessagingModels.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation

public struct Message {
    let messageId: String?
    let read: Bool
    let origin: String?
    let text: String?
    let time: TimeInterval?

    public init(with dict: NSDictionary, messageId: String?) {
        self.messageId = messageId
        read = dict["read"] as! Bool
        text = dict["text"] as? String
        time = dict["time"] as? TimeInterval
        origin = dict["origin"] as? String
    }
}

public struct Chat {
    let chatUserId: String?
    var chatUserName: String?
    var chatUserImage: String?
    let messages: [Message]?

    public mutating func setChatUserInfo(_ username: String, _ image: String) {
        self.chatUserName = username
        self.chatUserImage = image
    }

    public init(messagesDict: NSDictionary, chatterId: String?) {
        chatUserId = chatterId
        chatUserName = ""
        var messages: [Message] = []
        for key in messagesDict.allKeys {
            let messageDict = messagesDict[key] as! NSDictionary
            let message = Message.init(with: messageDict, messageId: key as? String)
            messages.append(message)
        }
        self.messages = messages.sorted(by: { msg1, msg2 -> Bool in
            return msg1.time ?? 0 < msg2.time ?? 0
        })
    }
}

