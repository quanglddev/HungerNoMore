//
//  Places.swift
//  HungerNoMore
//
//  Created by QUANG on 5/29/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import Alamofire
import SwiftyJSON

struct Place {
    let name: String
    let icon: String
    let rating: Double
    let lat: Double
    let lng: Double
    let vicinity: String
    let featureImages: String
    let place_id: String
    let photo_reference: String
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    init(json: SwiftyJSON.JSON) throws {
        guard let name = json["name"].string else {
            throw SerializationError.missing("Missing name")
        }
        
        guard let icon = json["icon"].string else {
            throw SerializationError.missing("Missing icon")
        }
        
        guard let rating = json["rating"].double else {
            throw SerializationError.missing("Missing rating")
        }
        
        guard let lat = json["geometry"]["location"]["lat"].double else {
            throw SerializationError.missing("Missing lat")
        }
        
        guard let lng = json["geometry"]["location"]["lng"].double else {
            throw SerializationError.missing("Missing lng")
        }
        
        guard let vicinity = json["vicinity"].string else {
            throw SerializationError.missing("Missing vicinity")
        }
        
        guard let featureImages = json["photos"][0]["html_attributions"][0].string else {
            throw SerializationError.missing("Missing featureImages")
        }

        guard let place_id = json["place_id"].string else {
            throw SerializationError.missing("Missing place_id")
        }
        
        guard let photo_reference = json["photos"][0]["photo_reference"].string else {
            throw SerializationError.missing("Missing photo_reference")
        }
        
        self.name = name
        self.icon = icon
        self.rating = rating
        self.lat = lat
        self.lng = lng
        self.vicinity = vicinity
        self.featureImages = featureImages
        self.place_id = place_id
        self.photo_reference = photo_reference
    }
    
    static let basePath = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

    static let radius = "2000" //m
    
    static func restaurant(withLatitude latitude: Double, longitude: Double, completion: @escaping ([Place]) -> ()) {
        let url = basePath + "location=\(latitude),\(longitude)" + "&radius=\(radius)&keyword=\(savedKeyword.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).replacingOccurrences(of: " ", with: ","))&opennow=true&key=\(api_key)"
        
        var restaurantArray = [Place]()
        
        print(url)
        
        Alamofire.request(URL(string: url)!)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while fetching: \(String(describing: response.result.error!))")
                    return
                }
                
                //saveJSONFile(data: response.data! as NSData)
                
                do {
                    let responseJSON = try JSON(data: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    let rows = responseJSON["results"].count
                    
                    for i in 0...rows {
                        if let eachObject = try? Place(json: responseJSON["results"][i]) {
                            restaurantArray.append(eachObject)
                        }
                    }
                    
                    completion(restaurantArray)
                }
                catch {
                    
                }
        }
    }
    
    /*
    static func saveJSONFile(data: NSData) {
        //Get the local docs directory and append your local filename.
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last!
        docURL = docURL.appendingPathComponent("cachedJSON.json")
        
        //Lastly, write your file to the disk.
        data.write(to: docURL, atomically: true)
    }*/
}

let api_key = "AIzaSyCqNRVjQxMdW1vdeDwT8_o-A-0lyJ6Q2ys" //CHANGE CHANGE CHANGE THIS CHANGE
