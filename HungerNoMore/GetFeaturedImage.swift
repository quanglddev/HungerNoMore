//
//  GetFeaturedImage.swift
//  HungerNoMore
//
//  Created by QUANG on 5/30/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension PlacesTVC {
    
    func featuredImages(withPlaces: [Place], completion: @escaping ([UIImage?]) -> ()) {
        
        let basePath = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=900&photoreference="
        let api_key = "AIzaSyBZF0vuGM3Pn7HfihHYkJuqtxKbBTaPEzE" //CHANGE CHANGE CHANGE THIS CHANGE
        
        var restaurantsImages = [UIImage?]()
        
        for place in withPlaces {
            let url = basePath + place.photo_reference + "&key=\(api_key)"
            
            //let image =
            
            //Check cache prevent redownloading
            if let imageFromCache = imageCache.object(forKey: place.photo_reference as NSString) {
                restaurantsImages += [imageFromCache]
                continue
            }
            
            Alamofire.request(URL(string: url)!)
                .validate(contentType: ["image/jpeg"])
                .responseData { response in
                    guard response.result.isSuccess else {
                        print("Error while fetching: \(String(describing: response.result.error!))")
                        return
                    }
                    
                    if response.response?.statusCode == 403 || response.response?.statusCode == 400 {
                        for _ in restaurantsImages.count...self.restaurants.count {
                            restaurantsImages += [#imageLiteral(resourceName: "placeholder")]
                        }
                        
                        completion(restaurantsImages)
                        
                        return
                    }
                    
                    let responseImage = UIImage(data: response.data!)
                    
                    restaurantsImages += [responseImage]
                    
                    imageCache.setObject(responseImage!, forKey: place.photo_reference as NSString)
                    
                    if restaurantsImages.count == withPlaces.count {
                        completion(restaurantsImages)
                    }
            }
        }
    }
}
import Foundation
import SystemConfiguration

extension PlacesTVC {    
    func isInternetAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}

