//
//  ProductCatalogManager.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation
import Promises

public class ProductCatalogManager {


    public static let sharedInstance = ProductCatalogManager()
    private init() {
        productTableIdentifier = "product"
        productCatalog = []
    }

    public func setup(productTableIdentifier: String) {
        self.productTableIdentifier = productTableIdentifier
    }

    private var productTableIdentifier: String

    private(set) var productCatalog: [Product]

    public func getAvailableProducts(completionHandler: OperationCompletionHandler?) {
        productCatalog = []
        let productPathString = "\(productTableIdentifier)"
        FirebaseDatabase.sharedInstance.readData(pathString: productPathString)
            .then {  result in
                if let result = result {
                    for key in result.allKeys {
                        let productDict = result[key] as? NSMutableDictionary ?? [:]
                        productDict["id"] = key
                        let product = Product(with: productDict)
                        self.productCatalog.append(product)
                    }
                }
                completionHandler?(.success(result))
        }   .catch { error in
            completionHandler?(.failure(error))
        }
    }
}

extension ProductCatalogManager {
    public func getAvailableProducts() -> Promise<Void> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            self.getAvailableProducts(completionHandler: { (result) in
                if case .failure(let error) = result {
                    reject(error)
                } else {
                    fulfill(())
                }
            })
        })
    }
}
