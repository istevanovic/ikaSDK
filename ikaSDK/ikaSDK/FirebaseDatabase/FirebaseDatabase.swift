//
//  FirebaseDatabase.swift
//  ikaSDK
//
//  Created by Ilija Stevanovic on 10/12/2019.
//  Copyright © 2019 ikas. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Promises
import SDWebImage

public enum OperationResult {
    case success(NSDictionary?)
    case failure(Error)
}

public typealias OperationCompletionHandler = (OperationResult) -> ()

public class FirebaseDatabase {
    
    public static let sharedInstance = FirebaseDatabase()
    private(set) var databaseReference: DatabaseReference!
    private(set) var storeRef: StorageReference!
    private(set) var activeUser = Auth.auth().currentUser
    private(set) var uploadedUrl: String?
    
    private init() {
        databaseReference = Database.database().reference()
        storeRef = Storage.storage().reference()
        removeStoredCacheData()
    }
    
    
    fileprivate func readData(pathString: String, completionHandler: @escaping OperationCompletionHandler) {
        databaseReference.child(pathString).observeSingleEvent(of: .value, with: { snapshot in
            guard let responseDict = snapshot.value as? NSDictionary else {
                completionHandler(.success([0:snapshot.value]))
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
    
    public func uploadImage(image: UIImage, photoUrl: String, completionHandler: @escaping OperationCompletionHandler) {
        var data = Data()
        data = image.jpegData(compressionQuality: 0.8)!
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storeRef.child("images/\(photoUrl)").putData(data, metadata: metaData) { metadata, error in
            if error == nil {
                completionHandler(.success(nil))
            } else {
                completionHandler(.failure(error!))
            }
        }
    }
    
    func downloadImage(photoUrl: String) -> Promise<URL?> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            let imageRef = self.storeRef.child("images/\(photoUrl)")
            // Fetch the download URL
            imageRef.downloadURL { url, error in
                if let error = error {
                    reject(error)
                } else {
                    fulfill(url)
                }
            }
        })
    }
    
    public func uploadMultipleImages(imagesAndImageUrls: [AnyHashable : Any]) -> Promise<[String: String]> {
        return Promise(on: .global(qos: .userInitiated), { fulfill, reject in
            let dispatchCount = imagesAndImageUrls
            for keyValuePair in imagesAndImageUrls {
                if let imageForUpload = keyValuePair.value as? UIImage {
                    let uuid = UUID().uuidString
                    self.uploadImage(image: imageForUpload, photoUrl: uuid) { _ in
                        
                    }
                }
            }
            fulfill([:])
        })
    }
}

extension FirebaseDatabase {
    func removeStoredCacheData() {
        UserDefaults.standard.setValue([:], forKey: "cachedImages")
    }
    func storeImage(url: String, data: Data) {
        var cachedImages = UserDefaults.standard.dictionary(forKey: "cachedImages") ?? [:]
        if cachedImages.count >= 50 {
            if let keyForRemoval = cachedImages.keys.randomElement() {
                cachedImages.removeValue(forKey: keyForRemoval)
            }
        }
        cachedImages[url] = data
        UserDefaults.standard.setValue(cachedImages, forKey: "cachedImages")
    }
    
    func fetchStoredImage(url: String) -> Data? {
        if let cachedImages = UserDefaults.standard.dictionary(forKey: "cachedImages"),
           let cachedData = cachedImages[url] as? Data {
            return cachedData
        }
        return nil
    }
}

public extension UIImageView {
    func setupImageFromFirebaseURl(url: String) {
        if let storedImage = FirebaseDatabase.sharedInstance.fetchStoredImage(url: url) {
            self.image = UIImage(data: storedImage)
            return
        }
        let reference = Storage.storage().reference().child(url).getData(maxSize: 1048576) { data, _ in
            if let data = data {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data)
                    FirebaseDatabase.sharedInstance.storeImage(url: url, data: data)
                }
            }
        }
    }
}
