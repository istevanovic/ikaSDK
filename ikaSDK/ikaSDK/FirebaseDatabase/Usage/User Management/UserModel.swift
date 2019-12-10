//
//  UserModel.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation

public class UserModel {
    var userInfoDict: NSDictionary
    var userId: String?
    var fullName: String?
    var email: String?
    var phoneNumber: String?
    var age: String?
    var profilePicture: String?
    var address: String?
    var photos: [String]?
    var productCatalogOwnerId: String?

    public init(with dict: NSDictionary) {
        userInfoDict = dict
        age = dict["age"] as? String
        address = dict["address"] as? String
        fullName = dict["fullName"] as? String
        phoneNumber = dict["phoneNumber"] as? String
        email = dict["email"] as? String
        profilePicture = dict["profilePicture"] as? String
    }
}
