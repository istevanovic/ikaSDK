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
        productTableIdentifier = "offer"
        productCatalog = []
    }

    public func setup(productTableIdentifier: String) {
        self.productTableIdentifier = productTableIdentifier
    }

    private var productTableIdentifier: String

    private(set) public var productCatalog: [Product]

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
    
    public func productForId(id: String) -> Product? {
        return productCatalog.first { product -> Bool in
            product.productId == id
        }
    }
    
    fileprivate func updateProductInfo(updates: [AnyHashable: Any], completionHandler: OperationCompletionHandler?) {
        // TODO
         completionHandler?(.success(nil))
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
    
    public func updateProductInfo(productId: String, updates: [AnyHashable: Any]) -> Promise<Void> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            fulfill(())
        })
    }
    
    public func updateProductImage(productId: String, image: UIImage) -> Promise<Void> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            fulfill(())
        })
    }
}
