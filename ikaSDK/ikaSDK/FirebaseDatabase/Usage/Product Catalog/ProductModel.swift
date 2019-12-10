//
//  ProductModel.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation

public class Product {
    var productDict: NSDictionary
    var productId: String?
    var name: String?
    var description: String?
    var address: String?
    var images: [String]?
    var mainImage: String?

    public init(with dict: NSDictionary) {
        productDict = dict
        productId = dict["id"] as? String
        name = dict["name"] as? String
        address = dict["location"] as? String
        images = []
        for photo in (dict["photos"] as? Array<String> ?? []) {
            images?.append(photo)
        }
        mainImage = dict["imageUrl"] as? String
    }

}
