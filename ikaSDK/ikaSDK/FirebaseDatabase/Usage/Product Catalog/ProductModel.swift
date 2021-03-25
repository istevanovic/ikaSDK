//
//  ProductModel.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation

public class Product {
    public var productDict: NSDictionary
    public var productId: String?
    public var name: String?
    public var description: String?
    public var address: String?
    public var images: [String]?
    public var mainImage: String?
    public var category: String?
    public var phoneNumber: String?
    public var canWhatsapp: Bool
    public var canCall: Bool
    public var canSms: Bool
    public var facebookUrl :String?
    public var instagramHandle: String?

    public init(with dict: NSDictionary) {
        productDict = dict
        description = dict["description"] as? String
        productId = dict["id"] as? String
        name = dict["name"] as? String
        address = dict["location"] as? String
        images = []
        for photo in (dict["photos"] as? Array<String> ?? []) {
            images?.append(photo)
        }
        mainImage = dict["imageUrl"] as? String
        category = dict["category"] as? String
        phoneNumber = dict["phoneNumber"] as? String
        instagramHandle = dict["instagramUrl"] as? String
        facebookUrl = dict["facebookUrl"] as? String
        canCall = dict["phoneCall"] as? Bool ?? true
        canSms = dict["sms"] as? Bool ?? true
        canWhatsapp = dict["whatsApp"] as? Bool ?? true
    }

}
