//
//  UserManager.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation
import Promises
import UIKit
import FirebaseAuth

open class UserManager {
    struct Constants {
        static let UserTableIdentifier = "users"
    }
    
    public static let sharedInstance = UserManager()
    private init() {}
    
    private(set) public var userInfo: UserModel?
    private(set) public var inspectedUserInfo: UserModel?
    
    public func setup() {
        getUserInfo()
    }
    
    fileprivate func getUserInfo(userId: String, completionHandler: OperationCompletionHandler?) {
        let userInfoPathString = "\(Constants.UserTableIdentifier)/\(userId)"
        FirebaseDatabase.sharedInstance.readData(pathString: userInfoPathString)
            .then { result in
                if let result = result,
                   userId == Auth.auth().currentUser?.uid {
                    self.userInfo = UserModel(with: result)
                    completionHandler?(.success(result))
                } else {
                    self.inspectedUserInfo = UserModel(with: result!)
                    completionHandler?(.success(result))
                }
                
            }
            .catch { error in
                completionHandler?(.failure(error))
            }
    }

    fileprivate func updateUserInfo(updates: [AnyHashable: Any], completionHandler: OperationCompletionHandler?) {
        guard let userId = FirebaseDatabase.sharedInstance.activeUser?.uid else {
            return
        }
        let userInfoPathString = "\(Constants.UserTableIdentifier)/\(userId)"
        FirebaseDatabase.sharedInstance.updateData(pathString: userInfoPathString, updates: updates)
            .then { _ in
                completionHandler?(.success(nil))
        }
        .catch { error in
            completionHandler?(.failure(error))
        }
    }
}

extension UserManager {
    public func getUserInfo(userId: String? = IkaSDK.sharedInstance.userId) -> Promise<UserModel> {
        FirebaseDatabase.sharedInstance.removeStoredCacheData()
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            self.getUserInfo(userId: (userId ?? IkaSDK.sharedInstance.userId)!, completionHandler: { (result) in
                if case .failure(let error) = result {
                    reject(error)
                } else {
                    if userId == IkaSDK.sharedInstance.userId && self.userInfo != nil {
                        fulfill(self.userInfo!)
                    } else {
                        fulfill(self.inspectedUserInfo!)
                    }
                }
            })
        })
    }
    
    public func updateUserInfo(updates: [AnyHashable: Any]) -> Promise<Void> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            self.updateUserInfo(updates: updates, completionHandler: { (result) in
                if case .failure(let error) = result {
                    reject(error)
                } else {
                    fulfill(())
                }
            })
        })
    }
    
    public func updateProfileImage(image: UIImage) -> Promise<Void> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            FirebaseDatabase.sharedInstance.uploadImage(image: image, photoUrl: "\(IkaSDK.sharedInstance.userId!)") { _ in
                self.updateUserInfo(updates: ["profilePic": "images/\(IkaSDK.sharedInstance.userId!)"]) { _ in
                    fulfill(())
                }
            }
        })
    }
    
    public func downloadProfileImage() -> Promise<URL?> {
        return FirebaseDatabase.sharedInstance.downloadImage(photoUrl: "\(IkaSDK.sharedInstance.userId!)")
    }
}

