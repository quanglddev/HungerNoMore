//
//  UIImageView+Download.swift
//  HungerNoMore
//
//  Created by QUANG on 5/29/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

class CustomImageView: UIImageView {
    
    var imageURLString: String?
    
    func downloadImage(from url: String) {
        
        imageURLString = url
        
        let urlRequest = URLRequest(url: URL(string: url)!)
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: url as NSString) {
            DispatchQueue.main.async {
                self.image = imageFromCache
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let err = error {
                print(err)
                return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    let imageToCache = UIImage(data: data)
                    
                    if self.imageURLString == url {
                        self.image = imageToCache
                    }
                    
                    imageCache.setObject(imageToCache!, forKey: url as NSString)
                    
                }
            }
        }
        task.resume()
    }
}
