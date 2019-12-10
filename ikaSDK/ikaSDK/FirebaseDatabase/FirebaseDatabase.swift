//
//  FirebaseDatabase.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import Promises

public enum OperationResult {
    case success(NSDictionary?)
    case failure(Error)
}

public typealias OperationCompletionHandler = (OperationResult) -> ()

public class FirebaseDatabase {

    public static let sharedInstance = FirebaseDatabase()
    private(set) var databaseReference: DatabaseReference!
    private(set) var activeUser = Auth.auth().currentUser

    private init() {
        databaseReference = Database.database().reference()
    }

    fileprivate func readData(pathString: String, completionHandler: @escaping OperationCompletionHandler) {
        databaseReference.child(pathString).observeSingleEvent(of: .value, with: { snapshot in
            guard let responseDict = snapshot.value as? NSDictionary else {
                completionHandler(.success(nil))
                return
            }
            completionHandler(.success(responseDict))
        }) { (error) in
            print(error.localizedDescription)
            completionHandler(.failure(error))
        }
    }

    fileprivate func writeData(pathString: String, data: NSDictionary, completionHandler: @escaping OperationCompletionHandler) {
        databaseReference.child(pathString).setValue(data) { error, _ in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            completionHandler(.success(nil))
        }
    }

    fileprivate func updateData(pathString: String, updates: [AnyHashable : Any], completionHandler: @escaping OperationCompletionHandler) {
        databaseReference.child(pathString).updateChildValues(updates) { error, _ in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            completionHandler(.success(nil))
        }
    }

    fileprivate func listenToDataUpdates(pathString: String, completionHandler: @escaping OperationCompletionHandler) {
        databaseReference.child(pathString).observe(.value) { snapshot in
             guard let responseDict = snapshot.value as? NSDictionary else {
                completionHandler(.success(nil))
                return
            }
            completionHandler(.success(responseDict))
        }
    }
}

extension FirebaseDatabase {
    public func readData(pathString: String) -> Promise<NSDictionary?> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            self.readData(pathString: pathString, completionHandler: { result in
                if case .failure(let error) = result {
                    reject(error)
                }
                if case .success(let responseDict) = result {
                    fulfill(responseDict)

                }
            })
        })
    }

    public func listenToDataUpdates(pathString: String) -> Promise<NSDictionary?> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            self.listenToDataUpdates(pathString: pathString, completionHandler: { result in
                if case .failure(let error) = result {
                    reject(error)
                }
                if case .success(let responseDict) = result {
                    fulfill(responseDict)

                }
            })
        })
    }

    public func writeData(pathString: String, data: NSDictionary) -> Promise<Void> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            self.writeData(pathString: pathString, data:data, completionHandler: { result in
                if case .failure(let error) = result {
                    reject(error)
                }
                if case .success(_) = result {
                    fulfill(())
                }
            })
        })
    }

    public func updateData(pathString: String, updates: [AnyHashable : Any]) -> Promise<Void> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            self.updateData(pathString: pathString, updates:updates, completionHandler: { result in
                if case .failure(let error) = result {
                    reject(error)
                }
                if case .success(_) = result {
                    fulfill(())
                }
            })
        })
    }
}
