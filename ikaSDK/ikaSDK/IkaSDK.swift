//
//  ikaSDK.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import Promises

public enum Usage {
    case userManagement
    case productCatalog
    case messaging
}

public class IkaSDK {
    
    public static let sharedInstance = IkaSDK()
    private init() {
        self.usage = []
    }
    private(set) var usage: [Usage]
    
    public func setup(usage: [Usage]) {
        self.usage = usage
    }
    
    public var isLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    public var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    public func refreshData() -> Promise<Void> {
        return Promise<Void>(on: .global(qos: .userInitiated)) { fulfill, reject in
                all(UserManager.sharedInstance.getUserInfo(),
                ProductCatalogManager.sharedInstance.getAvailableProducts())
                .then { _ in
                    FirebaseDatabase.sharedInstance.readData(pathString: "version")
                        .then { dict in
                            guard let version = dict?[0] as? Int,
                                  version == 1 else {
                                //TODO: FORCE UPDATE
                                return
                            }
                            fulfill(())
                        }
            } .catch { error in
                reject(error)
            }
        }
    }
    
    public func logout() {
        try? Auth.auth().signOut()
    }
}
