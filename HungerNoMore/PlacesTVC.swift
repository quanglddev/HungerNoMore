//
//  PlacesTVC.swift
//  HungerNoMore
//
//  Created by QUANG on 5/29/17.
//  Copyright © 2017 QUANG INDUSTRIES. All rights reserved.
//

import UIKit
import Cosmos
import SwiftyJSON
import Alamofire
import PopupDialog
import CoreLocation
import FaceAware
import MapKit
//static let api_key = "AIzaSyBZF0vuGM3Pn7HfihHYkJuqtxKbBTaPEzE" //CHANGE CHANGE CHANGE THIS CHANGE

let userDefaults = UserDefaults.standard
var savedKeyword: String = ""

struct defaultsKeys {
    static let keyword = "keyword"
}

class PlacesTVC: UITableViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    //MARK: Outlets
    
    @IBOutlet weak var txtSearchOutlet: UITextField!
    
    //MARK: Properties
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var header: String?
    
    var restaurants = [Place]()
    var featuredImages = [UIImage?]()
    
    let placeHolderLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Prepare placeholder for tableview
        placeHolderLabel.font = UIFont(name: placeHolderLabel.font.fontName, size: 20)
        placeHolderLabel.numberOfLines = 0
        placeHolderLabel.text = "No opening \(txtSearchOutlet.text ?? "restaurant/coffee") now 😬"
        placeHolderLabel.textAlignment = .center
        placeHolderLabel.textColor = UIColor.lightGray
        
        placeHolderLabel.isHidden = true
        self.tableView.addSubview(placeHolderLabel)
        
        requestLocation()
        
        txtSearchOutlet.delegate = self                  //set delegate to textfile
        
        if let keyword = userDefaults.string(forKey: defaultsKeys.keyword) {
            savedKeyword = keyword
            txtSearchOutlet.text = savedKeyword
        }
        else {
            savedKeyword = "Delivery Restaurant"
            txtSearchOutlet.text = savedKeyword
        }
        
        let gestureRecognizer = UIGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func hideKeyboard() {
        txtSearchOutlet.text = temp
        self.view.endEditing(true)
    }
    
    @IBAction func btnSearchAction(_ sender: UIBarButtonItem) {
        txtSearchOutlet.becomeFirstResponder()
        txtSearchOutlet.selectedTextRange = txtSearchOutlet.textRange(from: txtSearchOutlet.beginningOfDocument, to: txtSearchOutlet.endOfDocument)
    }
    
    var temp = ""
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = txtSearchOutlet.text {
            temp = text
        }
        txtSearchOutlet.selectedTextRange = txtSearchOutlet.textRange(from: txtSearchOutlet.beginningOfDocument, to: txtSearchOutlet.endOfDocument)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("YOLO")
        print(temp)
        savedKeyword = txtSearchOutlet.text ?? "Delivery Restaurant"
        userDefaults.set(savedKeyword, forKey: defaultsKeys.keyword)
        
        if (txtSearchOutlet.text?.isEmpty)! {
            txtSearchOutlet.text = "Delivery Restaurant"
        }
        
        locationManager.startUpdatingLocation()
        return true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        placeHolderLabel.frame = self.tableView.bounds
    }
    
    @IBAction func btnUpdateLocation(_ sender: UIBarButtonItem) {
        locationManager.startUpdatingLocation()
    }
    
    func loadData(withLatitude: Double, longitude: Double) {
        Place.restaurant(withLatitude: withLatitude, longitude: longitude) { (results: [Place]) in
            self.restaurants = self.mergeSort(results)
            
            /*
            //Creat placeholder Image
            for _ in results {
                self.featuredImages.append(#imageLiteral(resourceName: "placeholder"))
            }*/
            
            for result in results {
                print("\(result.name)")
            }
            
            if results.count == 0 {
                self.placeHolderLabel.isHidden = false
            }
            
            /*
            self.featuredImages(withPlaces: self.restaurants, completion: { (results: [UIImage?]) in
                self.featuredImages = results
                

            })*/
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func mergeSort(_ array: [Place]) -> [Place] {
        // 1
        guard array.count > 1 else { return array }
        
        let middleIndex = array.count / 2
        
        // 2
        let leftArray = mergeSort(Array(array[0..<middleIndex]))
        let rightArray = mergeSort(Array(array[middleIndex..<array.count]))
        
        // here
        return merge(leftArray, rightArray)
    }
    
    func merge(_ left: [Place], _ right: [Place]) -> [Place] {
        var leftIndex = 0
        var rightIndex = 0
        
        var orderedArray: [Place] = []
        
        // 1
        while leftIndex < left.count && rightIndex < right.count {
            while leftIndex < left.count && rightIndex < right.count {
                // 1
                let leftElement = left[leftIndex]
                let rightElement = right[rightIndex]
                
                if getDistance(restaurant: leftElement) < getDistance(restaurant: rightElement) { // 2
                    orderedArray.append(leftElement)
                    leftIndex += 1
                } else if getDistance(restaurant: leftElement) > getDistance(restaurant: rightElement) { // 3
                    orderedArray.append(rightElement)
                    rightIndex += 1
                } else { // 4
                    orderedArray.append(leftElement)
                    leftIndex += 1
                    orderedArray.append(rightElement)
                    rightIndex += 1
                }
            }
        }
        
        // 2
        while leftIndex < left.count {
            orderedArray.append(left[leftIndex])
            leftIndex += 1
        }
        
        while rightIndex < right.count {
            orderedArray.append(right[rightIndex])
            rightIndex += 1
        }
        
        return orderedArray
    }
    
    func getDistance(restaurant: Place) -> Int {
        let location = CLLocation(latitude: restaurant.lat, longitude: restaurant.lng)
        
        let distanceInMeters = location.distance(from: currentLocation!)
        
        return Int(floor(distanceInMeters))
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }
    
    let basePath = ""
    let api_key = "AIzaSyBZF0vuGM3Pn7HfihHYkJuqtxKbBTaPEzE" //CHANGE CHANGE CHANGE THIS CHANGE
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RestaurantCell
        
        let restaurant = restaurants[indexPath.row]
        let restaurantLocation = CLLocation(latitude: restaurant.lat, longitude: restaurant.lng)
        
        if let currentLocation = currentLocation {
            let distanceInMeters = restaurantLocation.distance(from: currentLocation)
            cell.lblDistance.text = "\(Int(floor(distanceInMeters))) m"
        }
        
        cell.lblName.text = restaurant.name
        //cell.restaurantIconView.sd_setImage(with: URL(string: restaurant.icon)!)
        cell.ratingView.rating = restaurant.rating
        cell.featuredImage.sd_setImage(with: URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=900&photoreference=\(restaurant.photo_reference)&key=\(api_key)")!)
        cell.featuredImage.focusOnFaces = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return header ?? "YOUR LOCATION"
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedCell = tableView.cellForRow(at: indexPath) as! RestaurantCell
            
            let restaurant = restaurants[indexPath.row]
            
            let placeid = restaurant.place_id
            
            let url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeid)&key=\(api_key)"
            print(url)
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            Alamofire.request(URL(string: url)!)
                .validate(contentType: ["application/json"])
                .responseJSON { response in
                    guard response.result.isSuccess else {
                        print("Error while fetching: \(String(describing: response.result.error!))")
                        return
                    }
                    
                    do {
                        let responseJSON = try JSON(data: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                        
                        if let formatted_phone_number = responseJSON["result"]["formatted_phone_number"].string {
                            self.popupConfirmCall(name: restaurant.name, image: selectedCell.featuredImage.image, number: formatted_phone_number, dlat: self.restaurants[indexPath.row].lat, dlng: self.restaurants[indexPath.row].lng, vicinity: self.restaurants[indexPath.row].vicinity)
                        }
                        else {
                            self.popupConfirmCall(name: restaurant.name, image: selectedCell.featuredImage.image, number: "NO NUMBER FOUND", dlat: self.restaurants[indexPath.row].lat, dlng: self.restaurants[indexPath.row].lng, vicinity: self.restaurants[indexPath.row].vicinity)
                        }
                    }
                    catch {
                        
                    }
            }
    }
    
    func popupConfirmCall(name: String, image: UIImage?, number: String, dlat: Double, dlng: Double, vicinity: String) {
        //print(number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "(", with: ""))
        print(number)
        if image != nil {
            print("yes")
        }
        
        // Prepare the popup assets
        let title = "REDIRECTING"
        let message = "Ready to order at \(name)?"
        let includedImage = image
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: includedImage)
        
        // Create buttons
        let buttonOne = CancelButton(title: "CANCEL") {
            print("You canceled the call.")
            //print(number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "(", with: ""))
        }
        
        let buttonThree = DefaultButton(title: "\(number)", height: 60) {
            guard let number = URL(string: "telprompt://" + number.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "(", with: "")) else { return }
            UIApplication.shared.open(number)
        }
        
        let buttonMap = DefaultButton(title: "SHOW ROUTE THERE") {
            let slat = self.currentLocation?.coordinate.latitude
            let slng = self.currentLocation?.coordinate.longitude
            
            if !(UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                UIApplication.shared.open(URL(string:"comgooglemaps://saddr=\(slat!),\(slng!)&daddr=\(dlat),\(dlng)&directionsmode=walking")!, options: [:], completionHandler: nil)
            } else {
                print("Can't use comgooglemaps://");
                UIApplication.shared.open(URL(string:"http://maps.apple.com/?saddr=\(slat!),\(slng!)&daddr=\(dlat),\(dlng)")!)
            }
        }
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonThree, buttonMap, buttonOne])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    func requestLocation() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
        
        let location = locations[0]
        
        currentLocation = location
        
        loadData(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(currentLocation!, completionHandler: {
            placemarks, error in
            
            if error == nil && (placemarks?.count)! > 0 {
                let placeMark: CLPlacemark = (placemarks?.last)!
                self.header = ("\(String(describing: placeMark.thoroughfare!)), \(String(describing: placeMark.subAdministrativeArea!)), \(String(describing: placeMark.locality!)), \(String(describing: placeMark.country!))")
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        })
    }
    
    /*
    func loadHistory() {
        header = userDefaults.string(forKey: defaultsKeys.header)
        
        var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last!
        docURL = docURL.appendingPathComponent("cachedJSON.json")
        
        guard let jsonData = NSData(contentsOfFile: docURL.absoluteString) else {
            Place.restaurant(withLatitude: (currentLocation?.coordinate.latitude)!, longitude: (currentLocation?.coordinate.longitude)!) { (results: [Place]) in
                self.restaurants = self.mergeSort(results)
                
                for result in results {
                    print("\(result.name)")
                }
                
                if results.count == 0 {
                    self.placeHolderLabel.isHidden = false
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }

            return
        }
        
        let responseJSON = JSON(data: jsonData as Data, options: JSONSerialization.ReadingOptions.mutableContainers, error: nil)
        
        let rows = responseJSON["results"].count
        
        for i in 0...rows {
            if let eachObject = try? Place(json: responseJSON["results"][i]) {
                restaurants.append(eachObject)
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }*/
    /*
    func openMapForPlace(name: String) {
        let latitude: CLLocationDegrees = (currentLocation?.coordinate.latitude)!
        let longitude: CLLocationDegrees = (currentLocation?.coordinate.longitude)!
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }*/
}
