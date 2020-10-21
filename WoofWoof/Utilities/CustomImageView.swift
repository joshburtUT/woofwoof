//
//  CustomImageView.swift
//  WoofWoof
//
//  Created by Josh Burt on 10/20/20.
//  Copyright © 2020 Josh Burt. All rights reserved.
//

import UIKit

// temporary storage of downloaded images with key: imageUrl & value: image
var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastImageUrlToLoadImage: String?

    func loadImage(with urlString: String) {
        
        // set image to nil
        self.image = nil
        
        // set last ImageUrlToLoadImage
        lastImageUrlToLoadImage = urlString
        
        // check if image exists in cache
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        // if image does not exist in cache
        // url for image location
        guard let url = URL(string: urlString) else { return }
        
        // fetch contents of url
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("JOSH:: Error fetching image: ", error!.localizedDescription)
                return
            }
            
            // check that the image to load matches the url of the image, else it will skip over
            if self.lastImageUrlToLoadImage != url.absoluteString {
                return
            }
            
            // check that data exists
            guard let imageData = data else { return }
            
            // create image using image data
            let photoImage = UIImage(data: imageData)
            
            // set key & value for image cache
            imageCache[url.absoluteString] = photoImage
            
            // set image
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
}
