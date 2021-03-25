//
//  UserModel.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation
import FirebaseAuth

public class UserModel {
    public var userInfoDict: NSDictionary
    public var userId: String? {
        return Auth.auth().currentUser?.uid
    }
    public var fullName: String?
    public var email: String
    public var phoneNumber: String?
    public var age: String?
    public var profilePicture: String?
    public var address: String?
    public var photos: [String]?
    public var userName: String?
    public var admin: Bool?

    public init(with dict: NSDictionary) {
        userInfoDict = dict
        age = dict["age"] as? String
        address = dict["location"] as? String
        fullName = dict["name"] as? String
        phoneNumber = dict["phone"] as? String
        email = dict["email"] as! String
        profilePicture = dict["profilePic"] as? String
        userName = dict["username"] as? String
        photos = dict["photos"] as? [String]
        admin = dict["isAdmin"] as? Bool
    }
}
