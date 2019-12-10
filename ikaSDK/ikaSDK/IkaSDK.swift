//
//  ikaSDK.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation

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


    
}
