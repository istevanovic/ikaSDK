//
//  MessagingManager.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation

public class MessagingManager {

    struct Constants {
        static let InboxTableIdentifier = "inbox"
        static let UsersTableIdentifier = "users"
    }

    public static let sharedInstance = MessagingManager()
    private init() {
        inbox = []
    }
    private(set) var inbox: [Chat]

    public func getChats(completionHandler: OperationCompletionHandler?) {
        guard let userId = FirebaseDatabase.sharedInstance.activeUser?.uid else {
            return
        }
        inbox = []
        let inboxPathString = "\(Constants.InboxTableIdentifier)/\(userId)"
        FirebaseDatabase.sharedInstance.listenToDataUpdates(pathString: inboxPathString)
            .then { result in
                guard let result = result else {
                    return
                }
                for key in result.allKeys {
                    let chatDict = result[key] as! NSDictionary
                    let messagesDict = chatDict["messages"] as? NSDictionary ?? [:]
                    var chat = Chat(messagesDict: messagesDict, chatterId: key as? String)
                    self.inbox.append(chat)
                }

        }
    }

}
