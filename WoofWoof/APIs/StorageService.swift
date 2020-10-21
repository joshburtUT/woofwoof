//
//  StorageService.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import FirebaseStorage

let STORAGE_REF = Storage.storage().reference()
let REF_PROFILE_IMAGES = STORAGE_REF.child("profile_images")
let REF_POST_IMAGES = STORAGE_REF.child("post_images")


struct StorageService {
    static func uploadUserProfileImage(image: UIImage, completion: @escaping(String) -> Void) {
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
        
        let filename = NSUUID().uuidString
        let storageRef = REF_PROFILE_IMAGES.child(filename)
        storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            if error != nil {
                print("JOSH: Error uploading image to Storage with error: \(error?.localizedDescription)")
                return
            }
            storageRef.downloadURL { (downloadUrl, error) in
                if error != nil {
                    print("JOSH: Error creating downloadUrl with error: \(error?.localizedDescription)")
                    return
                }
                guard let profileImageUrl = downloadUrl?.absoluteString else { return }
                completion(profileImageUrl)
            }
        }
    }
}
