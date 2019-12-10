//
//  UserManager.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation
import Promises

public class UserManager {
    struct Constants {
        static let UserTableIdentifier = "users"
        static let NewUserInfoParams = [
            "address": nil,
            "age": nil,
            "email": FirebaseDatabase.sharedInstance.activeUser?.email,
            "fullName": nil,
            "phoneNumber": nil,
            "username": nil] as NSDictionary
    }

    public static let sharedInstance = UserManager()
    private init() {}

    private(set) var userInfo: UserModel?

    public func setup() {
        getUserInfo()
            .then { _ in
                if self.userInfo == nil {
                    self.createNewUserInfo()
                        .then { _ in
                            self.userInfo = UserModel(with: Constants.NewUserInfoParams)
                    }
                }
        }
    }

    fileprivate func getUserInfo(userId: String? = FirebaseDatabase.sharedInstance.activeUser?.uid, completionHandler: OperationCompletionHandler?) {
        
        guard let userId = userId else {
            return
        }
        let userInfoPathString = "\(Constants.UserTableIdentifier)/\(userId)"
        FirebaseDatabase.sharedInstance.readData(pathString: userInfoPathString)
            .then { result in
                if let result = result,
                    userId == FirebaseDatabase.sharedInstance.activeUser?.uid {
                    self.userInfo = UserModel(with: result)
                }
                completionHandler?(.success(result))
        }
        .catch { error in
            completionHandler?(.failure(error))
        }
    }

    fileprivate func createNewUserInfo(completionHandler: OperationCompletionHandler?) {
        guard let userId = FirebaseDatabase.sharedInstance.activeUser?.uid else {
            return
        }
        let userInfoPathString = "\(Constants.UserTableIdentifier)/\(userId)"
        FirebaseDatabase.sharedInstance.writeData(pathString: userInfoPathString, data: Constants.NewUserInfoParams)
            .then { _ in
                completionHandler?(.success(nil))
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
    public func getUserInfo(userId: String? = nil) -> Promise<Void> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            self.getUserInfo(userId: userId, completionHandler: { (result) in
                if case .failure(let error) = result {
                    reject(error)
                } else {
                    fulfill(())
                }
            })
        })
    }

    public func createNewUserInfo() -> Promise<Void> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            self.createNewUserInfo(completionHandler: { (result) in
                if case .failure(let error) = result {
                    reject(error)
                } else {
                    fulfill(())
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
}

