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
        category = dict["category"] as? String
    }

}
