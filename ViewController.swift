//
//  ViewController.swift
//  AsisHack 2018-7-22
//
//  Created by Leo on 2018/03/19.
//  Copyright © 2018年 Leo. All rights reserved.
// test1@gmail.com

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import SafariServices
import SwiftyJSON
import UserNotifications
import Alamofire

class ViewController: UIViewController, GMSMapViewDelegate, SFSafariViewControllerDelegate, MyPostControllerDelegate, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var latitude: String?
    var longitude: String?
    
    var myLocation = CLLocation(latitude: 0, longitude: 0)
    
    var manager: CLLocationManager?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.myLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        
        
    }
    
    fileprivate func demoMarkerNothing(manager: CLLocationManager) {
//        self.courses.removeAll()
        allMarkerAppend(manager: manager)
    }
    
    fileprivate func allMarkerAppend(manager: CLLocationManager) {
        
    }
    
    var posts = [Post]()
    var loc = ""
    var tag = 0
    
//    private let APIKey = "0251c6db1ddbe9127d3ce4953361c1c3"
//    private let OpenWeatherMapUrl = "http://api.openweathermap.org/data/2.5/weather??lat=34&lon=135&APPID=#{0251c6db1ddbe9127d3ce4953361c1c3}"
    
    
    func didDelete(post: Post) {
        print(post.latitude, post.longitude)
        let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.latitude)!, longitude: CLLocationDegrees(post.longitude)!)
        
        print(post.location)
        let marker = GMSMarker(position: position)
        print(marker)
        marker.map = nil
    }
    
    var restaurantPreviewView: RestaurantPreviewView = {
        let v=RestaurantPreviewView()
        return v
    }()
    
    @objc func handleShelter() {
        setupDemo()
        setupButtons()
    }
    
    @objc func handleWeather() {
        setupDemo2()
        setupButtons2()
    }
    
    @objc func handleYabai() {
        setupDemo()
        setupButtons()
    }
    
    @objc func handlemyPage() {
        print("Message coming from HomeController")
        
//        setupDemo()
        setupButtons3()
        
        //        setupDemo()
        //        allMarkerAppend(manager: self.manager!)
        //        let myPostController = MyPostController(collectionViewLayout: UICollectionViewFlowLayout())
        //        myPostController.posts = posts
        //        myPostController.delegate = self
        //        navigationController?.pushViewController(myPostController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDemo2()
        setupButtons2()

    }
    
    fileprivate func setupShelter() {
        
        guard let path = Bundle.main.path(forResource: "shelter", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else { return }
            do {
                self.courses = try JSONDecoder().decode([Course].self, from: data)
                print("this is courses",self.courses.count)
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
            }.resume()
    }
    
    var courses = [Course]()
    var kagaSuiris = [KagaSuiri]()
    struct KagaSuiri: Decodable {
        let latitude: String
        let longitude: String
    }
    
    fileprivate func setupDemo() {
        guard let path = Bundle.main.path(forResource: "shelter", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else { return }
            do {
                self.courses = try JSONDecoder().decode([Course].self, from: data)
                print("this is courses",self.courses.count)
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
            }.resume()
    }
    
    fileprivate func setupDemo2() {
        guard let path = Bundle.main.path(forResource: "suiri", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else { return }
            do {
                self.courses = try JSONDecoder().decode([Course].self, from: data)
                print("this is courses",self.courses.count)
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
            }.resume()
    }
    
    fileprivate func setupDemo3() {
        guard let path = Bundle.main.path(forResource: "shelter", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else { return }
            do {
                self.courses = try JSONDecoder().decode([Course].self, from: data)
                print("this is courses",self.courses.count)
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
            }.resume()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        
    }

    fileprivate func setupButtons() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //MARK:- Setup MapView
        let camera = GMSCameraPosition.camera(withLatitude: 35.652832,longitude: 128.839478, zoom: 4)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.delegate=self
        
        let mapInsets = UIEdgeInsets(top:100.0, left:0.0, bottom:0.0, right:0.0)
        mapView.padding = mapInsets
        
        self.view = mapView
        
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        
        print("this is courses",self.courses.count)
        if courses.count > 0 {
            for i in 0...(courses.count) - 1 {
                let coordinate2 = CLLocation(latitude: CLLocationDegrees(self.courses[i].latitude)!, longitude: CLLocationDegrees(self.courses[i].longitude)!)
                let distanceInMeters = coordinate2.distance(from: self.myLocation)

                var borderColor: UIColor = .white

                borderColor = .white
                let distanceInKm = distanceInMeters/1000
                _ = round(distanceInKm*10)/10
                let marker = GMSMarker()
                var merkerTitle = ""

                let image = UIImage(named: "shelter")

                guard let creationDate = courses[i].creationDate else { return }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                _ = formatter.date(from: creationDate) as! Date
                //            let dateUnix = date.timeIntervalSince1970

//                merkerTitle = "\(date.timeAgoDisplay()) \(disRound)km 先"
                merkerTitle = "shelter"
                marker.opacity = 1.0
                marker.map = mapView
                self.tag = 100
                let customMarker = CustomMarkerView(title: merkerTitle, image: image!, borderColor: borderColor, id: self.courses[i].id!, tag: 1)
                marker.iconView = customMarker
                marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.courses[i].latitude)!, longitude: CLLocationDegrees(self.courses[i].longitude)!)
            }
        }
        
        restaurantPreviewView = RestaurantPreviewView(frame: CGRect(x: 0, y: 0, width: screenWidth-30, height: screenHeight * 1/3 + 44))
        
        let cameraButton = UIButton(type: .system)
        cameraButton.setImage(#imageLiteral(resourceName: "camera3-2").withRenderingMode(.alwaysOriginal), for: .normal)
        cameraButton.backgroundColor = .white
        cameraButton.layer.cornerRadius = 25
        cameraButton.addTarget(self, action: #selector(handleCamera), for: .touchUpInside)
        
        mapView.addSubview(cameraButton)
        cameraButton.anchor(top: nil, left: nil, bottom: mapView.bottomAnchor, right: mapView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 106, paddingRight: 14, width: 50, height: 50)
        
        let myPageButton = UIButton(type: .system)
        
        myPageButton.setImage(#imageLiteral(resourceName: "suprise").withRenderingMode(.alwaysOriginal), for: .normal)
        myPageButton.backgroundColor = .white
//        myPageButton.layer.cornerRadius = 25
        myPageButton.addTarget(self, action: #selector(handlemyPage), for: .touchUpInside)
        
        mapView.addSubview(myPageButton)
        myPageButton.anchor(top: nil, left: nil, bottom: cameraButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 40, height: 40)
        myPageButton.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor).isActive = true
        myPageButton.layer.cornerRadius = 20
        myPageButton.clipsToBounds = true
        
        
        let weatherButton = UIButton(type: .system)
        weatherButton.setImage(#imageLiteral(resourceName: "hydrent").withRenderingMode(.alwaysOriginal), for: .normal)
        weatherButton.backgroundColor = .white
        weatherButton.layer.cornerRadius = 20
        weatherButton.addTarget(self, action: #selector(handleWeather), for: .touchUpInside)
        
        let hinanButton = UIButton(type: .system)
        hinanButton.setImage(#imageLiteral(resourceName: "Unknown").withRenderingMode(.alwaysOriginal), for: .normal)
        hinanButton.backgroundColor = .white
        hinanButton.layer.cornerRadius = 25
        hinanButton.addTarget(self, action: #selector(handleShelter), for: .touchUpInside)
        
        mapView.addSubview(weatherButton)
        weatherButton.anchor(top: nil, left: nil, bottom: myPageButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 40, height: 40)
        weatherButton.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor).isActive = true
        weatherButton.imageView?.contentMode = .scaleAspectFit
        weatherButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        mapView.addSubview(hinanButton)
        hinanButton.anchor(top: nil, left: nil, bottom: weatherButton.topAnchor, right: mapView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 14, width: 50, height: 50)
        hinanButton.imageView?.contentMode = .scaleAspectFit
        hinanButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            let ref = Database.database().reference().child("posts")
            
            ref.observe(.value, with: { (snapshot) in
                self.posts.removeAll()
                guard let dictionaries = snapshot.value as? [String: Any] else { return }
                
                dictionaries.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    
                    var post = Post(user: user, dictionary: dictionary)
                    post.id = key
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    self.posts.append(post)
                    print(self.posts.count)
                    Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let value = snapshot.value as? Int, value == 1 {
                            post.hasLiked = true
                        } else {
                            post.hasLiked = false
                        }
                        
                        guard let postImageUrl = post.imageUrl else { return }
                        var image: UIImage?
                        var lastURLUsedToLoadImage: String?
                        image = nil
                        lastURLUsedToLoadImage = postImageUrl
                        
                        if let cachedImage = imageCache[postImageUrl] {
                            image = cachedImage
                            return
                        }
                        
                        guard let url = URL(string: postImageUrl) else { return }
                        
                        URLSession.shared.dataTask(with: url) { (data, response, err) in
                            if let err = err {
                                print("Failed to fetch post image:", err)
                                return
                            }
                            
                            if url.absoluteString != lastURLUsedToLoadImage {
                                return
                            }
                            
                            guard let imageData = data else { return }
                            
                            let photoImage = UIImage(data: imageData)
                            
                            imageCache[url.absoluteString] = photoImage
                            
                            guard let id = post.id else { return }
                            
                            DispatchQueue.main.async {
                                image = photoImage
                                guard let image = image else { return }
                                
                                let marker = GMSMarker()
                                var merkerTitle = ""
                                
                                
                                
                                //        let content = UNMutableNotificationContent()
                                //        content.title = "10 km先, "
                                //        content.body = "Body"
                                //        content.sound = UNNotificationSound.default()
                                //
                                
                                //
                                let coordinate0 = CLLocation(latitude: CLLocationDegrees(post.latitude)!, longitude: CLLocationDegrees(post.longitude)!)
                                let distanceInMeters = coordinate0.distance(from: self.myLocation)
                                //                                let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(post.latitude)!, CLLocationDegrees(post.longitude)!)
                                //                                let region = CLCircularRegion.init(center: coordinate, radius: 1000.0, identifier: "Headquarter")
                                //                                region.notifyOnEntry = true;
                                //                                region.notifyOnExit = false;
                                //                                let trigger = UNLocationNotificationTrigger.init(region: region, repeats: false)
                                //
                                //                                // id, content, trigger から UNNotificationRequest 作成
                                //                                let request = UNNotificationRequest.init(identifier: "LocationNotification", content: content, trigger: trigger)
                                //
                                //                                // UNUserNotificationCenter に request を追加
                                //                                let center = UNUserNotificationCenter.current()
                                //                                center.add(request)
                                
                                var borderColor: UIColor = .white
                                
                                if distanceInMeters > 100 {
                                    
                                    
                                    borderColor = .yellow
                                    let distanceInKm = distanceInMeters/1000
                                    let disRound = round(distanceInKm*10)/10
                                    
                                    
                                    merkerTitle = "\(post.creationDate.timeAgoDisplay()) \(disRound)km "
                                    marker.opacity = 1.0
                                    marker.map = mapView
                                    self.tag = 100
                                    let customMarker = CustomMarkerView(title: merkerTitle, image: image, borderColor: borderColor, id: id, tag: self.tag)
                                    marker.iconView = customMarker
                                    marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.latitude)!, longitude: CLLocationDegrees(post.longitude)!)
                                } else {
                                    borderColor = .red
                                    merkerTitle = "\(post.creationDate.timeAgoDisplay())   Near!!!! "
                                    marker.opacity = 1.0
                                    marker.map = mapView
                                    self.tag = 10
                                    let customMarker = CustomMarkerView(title: merkerTitle, image: image, borderColor: borderColor, id: id, tag: self.tag)
                                    marker.iconView = customMarker
                                    marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.latitude)!, longitude: CLLocationDegrees(post.longitude)!)
                                }
                                
                                self.posts.sort(by: { (p1, p2) -> Bool in
                                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                                })
                            }
                            
                            }.resume()
                    }, withCancel: { (err) in
                        print("Failed to fetch like info for post:", err)
                    })
                })
                
                
            }) { (err) in
                print(err)
            }
        }
    }
    
    fileprivate func setupButtons2() {
        //MARK:- Setup MapView
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: 35.652832,longitude: 128.839478, zoom: 4)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.delegate=self
        
        let mapInsets = UIEdgeInsets(top:100.0, left:0.0, bottom:0.0, right:0.0)
        mapView.padding = mapInsets
        
        self.view = mapView
        
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        
        print("this is courses",self.courses.count)
        if courses.count > 0 {
            for i in 0...(courses.count) - 1 {
                let coordinate2 = CLLocation(latitude: CLLocationDegrees(self.courses[i].latitude)!, longitude: CLLocationDegrees(self.courses[i].longitude)!)
                let distanceInMeters = coordinate2.distance(from: self.myLocation)
                
                var borderColor: UIColor = .white
                
                borderColor = .white
                let distanceInKm = distanceInMeters/1000
                _ = round(distanceInKm*10)/10
                let marker = GMSMarker()
                var merkerTitle = ""
                
                let image = UIImage(named: "Hydrant-512")
                
                guard let creationDate = courses[i].creationDate else { return }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                _ = formatter.date(from: creationDate) as! Date
                //            let dateUnix = date.timeIntervalSince1970
                
                //                merkerTitle = "\(date.timeAgoDisplay()) \(disRound)km 先"
                merkerTitle = "hydrant"
                marker.opacity = 1.0
                marker.map = mapView
                self.tag = 100
                let customMarker = CustomMarkerView(title: merkerTitle, image: image!, borderColor: borderColor, id: self.courses[i].id!, tag: 1)
                marker.iconView = customMarker
                marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.courses[i].latitude)!, longitude: CLLocationDegrees(self.courses[i].longitude)!)
            }
        }
        
        restaurantPreviewView = RestaurantPreviewView(frame: CGRect(x: 0, y: 0, width: screenWidth-30, height: screenHeight * 1/3 + 44))
        
        let cameraButton = UIButton(type: .system)
        cameraButton.setImage(#imageLiteral(resourceName: "camera3-2").withRenderingMode(.alwaysOriginal), for: .normal)
        cameraButton.backgroundColor = .white
        cameraButton.layer.cornerRadius = 25
        cameraButton.addTarget(self, action: #selector(handleCamera), for: .touchUpInside)
        
        mapView.addSubview(cameraButton)
        cameraButton.anchor(top: nil, left: nil, bottom: mapView.bottomAnchor, right: mapView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 106, paddingRight: 14, width: 50, height: 50)
        
        let myPageButton = UIButton(type: .system)
        
        myPageButton.setImage(#imageLiteral(resourceName: "suprise").withRenderingMode(.alwaysOriginal), for: .normal)
        myPageButton.backgroundColor = .white
        myPageButton.layer.cornerRadius = 20
        myPageButton.addTarget(self, action: #selector(handlemyPage), for: .touchUpInside)
        
        mapView.addSubview(myPageButton)
        myPageButton.anchor(top: nil, left: nil, bottom: cameraButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 40, height: 40)
        myPageButton.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor).isActive = true
        myPageButton.clipsToBounds = true
        
        
        let weatherButton = UIButton(type: .system)
        weatherButton.setImage(#imageLiteral(resourceName: "hydrent").withRenderingMode(.alwaysOriginal), for: .normal)
        weatherButton.backgroundColor = .white
        weatherButton.layer.cornerRadius = 25
        weatherButton.addTarget(self, action: #selector(handleWeather), for: .touchUpInside)
        
        let hinanButton = UIButton(type: .system)
        hinanButton.setImage(#imageLiteral(resourceName: "Unknown").withRenderingMode(.alwaysOriginal), for: .normal)
        hinanButton.backgroundColor = .white
        hinanButton.layer.cornerRadius = 20
        hinanButton.addTarget(self, action: #selector(handleShelter), for: .touchUpInside)
        
        mapView.addSubview(weatherButton)
        weatherButton.anchor(top: nil, left: nil, bottom: myPageButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 50, height: 50)
        weatherButton.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor).isActive = true
        weatherButton.imageView?.contentMode = .scaleAspectFit
        weatherButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        mapView.addSubview(hinanButton)
        hinanButton.anchor(top: nil, left: nil, bottom: weatherButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 40, height: 40)
        hinanButton.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor).isActive = true
        hinanButton.imageView?.contentMode = .scaleAspectFit
        hinanButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            let ref = Database.database().reference().child("posts")
            
            ref.observe(.value, with: { (snapshot) in
                self.posts.removeAll()
                guard let dictionaries = snapshot.value as? [String: Any] else { return }
                
                dictionaries.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    
                    var post = Post(user: user, dictionary: dictionary)
                    post.id = key
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    self.posts.append(post)
                    print(self.posts.count)
                    Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let value = snapshot.value as? Int, value == 1 {
                            post.hasLiked = true
                        } else {
                            post.hasLiked = false
                        }
                        
                        guard let postImageUrl = post.imageUrl else { return }
                        var image: UIImage?
                        var lastURLUsedToLoadImage: String?
                        image = nil
                        lastURLUsedToLoadImage = postImageUrl
                        
                        if let cachedImage = imageCache[postImageUrl] {
                            image = cachedImage
                            return
                        }
                        
                        guard let url = URL(string: postImageUrl) else { return }
                        
                        URLSession.shared.dataTask(with: url) { (data, response, err) in
                            if let err = err {
                                print("Failed to fetch post image:", err)
                                return
                            }
                            
                            if url.absoluteString != lastURLUsedToLoadImage {
                                return
                            }
                            
                            guard let imageData = data else { return }
                            
                            let photoImage = UIImage(data: imageData)
                            
                            imageCache[url.absoluteString] = photoImage
                            
                            guard let id = post.id else { return }
                            
                            DispatchQueue.main.async {
                                image = photoImage
                                guard let image = image else { return }
                                
                                let marker = GMSMarker()
                                var merkerTitle = ""
                                
                                
                                
                                //        let content = UNMutableNotificationContent()
                                //        content.title = "10 km先, "
                                //        content.body = "Body"
                                //        content.sound = UNNotificationSound.default()
                                //
                                
                                //
                                let coordinate0 = CLLocation(latitude: CLLocationDegrees(post.latitude)!, longitude: CLLocationDegrees(post.longitude)!)
                                let distanceInMeters = coordinate0.distance(from: self.myLocation)
                                //                                let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(post.latitude)!, CLLocationDegrees(post.longitude)!)
                                //                                let region = CLCircularRegion.init(center: coordinate, radius: 1000.0, identifier: "Headquarter")
                                //                                region.notifyOnEntry = true;
                                //                                region.notifyOnExit = false;
                                //                                let trigger = UNLocationNotificationTrigger.init(region: region, repeats: false)
                                //
                                //                                // id, content, trigger から UNNotificationRequest 作成
                                //                                let request = UNNotificationRequest.init(identifier: "LocationNotification", content: content, trigger: trigger)
                                //
                                //                                // UNUserNotificationCenter に request を追加
                                //                                let center = UNUserNotificationCenter.current()
                                //                                center.add(request)
                                
                                var borderColor: UIColor = .white
                                
                                if distanceInMeters > 100 {
                                    
                                    
                                    borderColor = .yellow
                                    let distanceInKm = distanceInMeters/1000
                                    let disRound = round(distanceInKm*10)/10
                                    
                                    
                                    merkerTitle = "\(post.creationDate.timeAgoDisplay()) \(disRound)km "
                                    marker.opacity = 1.0
                                    marker.map = mapView
                                    self.tag = 100
                                    let customMarker = CustomMarkerView(title: merkerTitle, image: image, borderColor: borderColor, id: id, tag: self.tag)
                                    marker.iconView = customMarker
                                    marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.latitude)!, longitude: CLLocationDegrees(post.longitude)!)
                                } else {
                                    borderColor = .red
                                    merkerTitle = "\(post.creationDate.timeAgoDisplay()) Near!!!!"
                                    marker.opacity = 1.0
                                    marker.map = mapView
                                    self.tag = 10
                                    let customMarker = CustomMarkerView(title: merkerTitle, image: image, borderColor: borderColor, id: id, tag: self.tag)
                                    marker.iconView = customMarker
                                    marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.latitude)!, longitude: CLLocationDegrees(post.longitude)!)
                                }
                                
                                self.posts.sort(by: { (p1, p2) -> Bool in
                                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                                })
                            }
                            
                            }.resume()
                    }, withCancel: { (err) in
                        print("Failed to fetch like info for post:", err)
                    })
                })
                
                
            }) { (err) in
                print(err)
            }
        }
    }
    
    fileprivate func setupButtons3() {
        print("tap suprise button!!!!")
        
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        //MARK:- Setup MapView
        let camera = GMSCameraPosition.camera(withLatitude: 35.652832,longitude: 128.839478, zoom: 4)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.delegate=self
        
        let mapInsets = UIEdgeInsets(top:100.0, left:0.0, bottom:0.0, right:0.0)
        mapView.padding = mapInsets
        
        self.view = mapView
        
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        restaurantPreviewView = RestaurantPreviewView(frame: CGRect(x: 0, y: 0, width: screenWidth-30, height: screenHeight * 1/3 + 44))
        
        let cameraButton = UIButton(type: .system)
        cameraButton.setImage(#imageLiteral(resourceName: "camera3-2").withRenderingMode(.alwaysOriginal), for: .normal)
        cameraButton.backgroundColor = .white
        cameraButton.layer.cornerRadius = 25
        cameraButton.addTarget(self, action: #selector(handleCamera), for: .touchUpInside)
        
        mapView.addSubview(cameraButton)
        cameraButton.anchor(top: nil, left: nil, bottom: mapView.bottomAnchor, right: mapView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 106, paddingRight: 14, width: 50, height: 50)
        
        let myPageButton = UIButton(type: .system)
        
        myPageButton.setImage(#imageLiteral(resourceName: "suprise").withRenderingMode(.alwaysOriginal), for: .normal)
        myPageButton.backgroundColor = .white
        //        myPageButton.layer.cornerRadius = 25
        myPageButton.addTarget(self, action: #selector(handlemyPage), for: .touchUpInside)
        
        mapView.addSubview(myPageButton)
        myPageButton.anchor(top: nil, left: nil, bottom: cameraButton.topAnchor, right: mapView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 14, width: 50, height: 50)
        myPageButton.layer.cornerRadius = 25
        myPageButton.clipsToBounds = true
        
        
        let weatherButton = UIButton(type: .system)
        weatherButton.setImage(#imageLiteral(resourceName: "hydrent").withRenderingMode(.alwaysOriginal), for: .normal)
        weatherButton.backgroundColor = .white
        weatherButton.layer.cornerRadius = 20
        weatherButton.addTarget(self, action: #selector(handleWeather), for: .touchUpInside)
        
        let hinanButton = UIButton(type: .system)
        hinanButton.setImage(#imageLiteral(resourceName: "Unknown").withRenderingMode(.alwaysOriginal), for: .normal)
        hinanButton.backgroundColor = .white
        hinanButton.layer.cornerRadius = 20
        hinanButton.addTarget(self, action: #selector(handleShelter), for: .touchUpInside)
        
        mapView.addSubview(weatherButton)
        weatherButton.anchor(top: nil, left: nil, bottom: myPageButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 40, height: 40)
        weatherButton.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor).isActive = true
        weatherButton.imageView?.contentMode = .scaleAspectFit
        weatherButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        mapView.addSubview(hinanButton)
        hinanButton.anchor(top: nil, left: nil, bottom: weatherButton.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 40, height: 40)
        hinanButton.centerXAnchor.constraint(equalTo: cameraButton.centerXAnchor).isActive = true
        hinanButton.imageView?.contentMode = .scaleAspectFit
        hinanButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            let ref = Database.database().reference().child("posts")
            
            ref.observe(.value, with: { (snapshot) in
                self.posts.removeAll()
                guard let dictionaries = snapshot.value as? [String: Any] else { return }
                
                dictionaries.forEach({ (key, value) in
                    guard let dictionary = value as? [String: Any] else { return }
                    
                    var post = Post(user: user, dictionary: dictionary)
                    post.id = key
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    self.posts.append(post)
                    print(self.posts.count)
                    Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let value = snapshot.value as? Int, value == 1 {
                            post.hasLiked = true
                        } else {
                            post.hasLiked = false
                        }
                        
                        guard let postImageUrl = post.imageUrl else { return }
                        var image: UIImage?
                        var lastURLUsedToLoadImage: String?
                        image = nil
                        lastURLUsedToLoadImage = postImageUrl
                        
                        if let cachedImage = imageCache[postImageUrl] {
                            image = cachedImage
                            return
                        }
                        
                        guard let url = URL(string: postImageUrl) else { return }
                        
                        URLSession.shared.dataTask(with: url) { (data, response, err) in
                            if let err = err {
                                print("Failed to fetch post image:", err)
                                return
                            }
                            
                            if url.absoluteString != lastURLUsedToLoadImage {
                                return
                            }
                            
                            guard let imageData = data else { return }
                            
                            let photoImage = UIImage(data: imageData)
                            
                            imageCache[url.absoluteString] = photoImage
                            
                            guard let id = post.id else { return }
                            
                            DispatchQueue.main.async {
                                image = photoImage
                                guard let image = image else { return }
                                
                                let marker = GMSMarker()
                                var merkerTitle = ""
                                
                                
                                
                                //        let content = UNMutableNotificationContent()
                                //        content.title = "10 km先, "
                                //        content.body = "Body"
                                //        content.sound = UNNotificationSound.default()
                                //
                                
                                //
                                let coordinate0 = CLLocation(latitude: CLLocationDegrees(post.latitude)!, longitude: CLLocationDegrees(post.longitude)!)
                                let distanceInMeters = coordinate0.distance(from: self.myLocation)
                                //                                let coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(post.latitude)!, CLLocationDegrees(post.longitude)!)
                                //                                let region = CLCircularRegion.init(center: coordinate, radius: 1000.0, identifier: "Headquarter")
                                //                                region.notifyOnEntry = true;
                                //                                region.notifyOnExit = false;
                                //                                let trigger = UNLocationNotificationTrigger.init(region: region, repeats: false)
                                //
                                //                                // id, content, trigger から UNNotificationRequest 作成
                                //                                let request = UNNotificationRequest.init(identifier: "LocationNotification", content: content, trigger: trigger)
                                //
                                //                                // UNUserNotificationCenter に request を追加
                                //                                let center = UNUserNotificationCenter.current()
                                //                                center.add(request)
                                
                                var borderColor: UIColor = .white
                                
                                if distanceInMeters > 100 {
                                    
                                    
                                    borderColor = .yellow
                                    let distanceInKm = distanceInMeters/1000
                                    let disRound = round(distanceInKm*10)/10
                                    
                                    
                                    merkerTitle = "\(post.creationDate.timeAgoDisplay()) \(disRound)km "
                                    marker.opacity = 1.0
                                    marker.map = mapView
                                    self.tag = 100
                                    let customMarker = CustomMarkerView(title: merkerTitle, image: image, borderColor: borderColor, id: id, tag: self.tag)
                                    marker.iconView = customMarker
                                    marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.latitude)!, longitude: CLLocationDegrees(post.longitude)!)
                                } else {
                                    borderColor = .red
                                    merkerTitle = "\(post.creationDate.timeAgoDisplay())  near!!!"
                                    marker.opacity = 1.0
                                    marker.map = mapView
                                    self.tag = 10
                                    let customMarker = CustomMarkerView(title: merkerTitle, image: image, borderColor: borderColor, id: id, tag: self.tag)
                                    marker.iconView = customMarker
                                    marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(post.latitude)!, longitude: CLLocationDegrees(post.longitude)!)
                                }
                                
                                self.posts.sort(by: { (p1, p2) -> Bool in
                                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                                })
                            }
                            
                            }.resume()
                    }, withCancel: { (err) in
                        print("Failed to fetch like info for post:", err)
                    })
                })
                
                
            }) { (err) in
                print(err)
            }
        }
    }
    
    
    
    @objc func onStartPointlabel(_ sender:UISlider!)
    {
        print(sender.value)
        
    }
    
    
    
    @objc func handleCamera() {
        print("Showing camera")
        let cameraController = CameraController()
        present(cameraController, animated: true, completion: nil)
    }
    
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return nil }
        guard let image = customMarkerView.img else { return nil}
        guard let title = customMarkerView.title else { return nil}
        restaurantPreviewView.setData(title: title, img: image, price: 22)
        return restaurantPreviewView
    }
    
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return }
        print("tap window")
        handleTapWindow(marker: marker, customMarkerView: customMarkerView)
    }
    
    enum MyError: Error {
        case FoundNil(String)
    }
    
    func handleTapWindow(marker: GMSMarker, customMarkerView: CustomMarkerView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        
        alertController.addAction(UIAlertAction(title: "delete", style: .destructive, handler: { (_) in
            
            do {
                print("delete")
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                guard let id = customMarkerView.id else { return }
                let ref = Database.database().reference().child("posts").child(id)
                let userRef = Database.database().reference().child("userPosts").child(uid).child(id)
                ref.removeValue(completionBlock: { (err, ref) in
                    print("successfully delete post from firebase DB")
                    userRef.removeValue(completionBlock: { (err, ref) in
                        print("successfully delete userPostsId from firebase DB")
                        marker.map = nil
                        self.judgeYabai()
                    })
                })
                
                throw MyError.FoundNil("スターをつけられない")
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    let savedLabel = UILabel()
    
    fileprivate func judgeYabai() {
        
        savedLabel.text = "delete OK!"
        savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
        savedLabel.textColor = .white
        savedLabel.numberOfLines = 0
        savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
        savedLabel.textAlignment = .center
        
        savedLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 80)
        savedLabel.center = self.view.center
        
        self.view.addSubview(savedLabel)
        
        savedLabel.layer.transform = CATransform3DMakeScale(0, 0, 0)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            
            self.savedLabel.layer.transform = CATransform3DMakeScale(1, 1, 1)
            
        }, completion: { (completed) in
            //completed
            
            UIView.animate(withDuration: 0.5, delay: 0.75, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                
                self.savedLabel.layer.transform = CATransform3DMakeScale(0.1, 0.1, 0.1)
                self.savedLabel.alpha = 0
                
            }, completion: { (_) in
                
                self.savedLabel.removeFromSuperview()
                
            })
            
        })
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
//        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return }
//        guard let img = customMarkerView.img else { return }
//
//        guard let title = customMarkerView.title else { return }
//        let tag = customMarkerView.tag
//        print(tag)
//        if tag == 10 {
//            let customMarker = CustomMarkerView(title: title, image: img, borderColor: .black, id: customMarkerView.id, tag: self.tag)
//            marker.opacity = 1
//            marker.iconView = customMarker
//        } else {
//            let customMarker = CustomMarkerView(title: title, image: img, borderColor: .lightGray, id: customMarkerView.id, tag: self.tag)
//            marker.iconView = customMarker
//        }
    }
}



//        let startPointSlider = UISlider(frame: CGRect(x:0, y:0, width:350, height:30))
//        startPointSlider.layer.position = CGPoint(x:self.view.frame.midX, y:500)
//        startPointSlider.backgroundColor = UIColor.clear
//        startPointSlider.layer.cornerRadius = 10.0
//        startPointSlider.layer.shadowOpacity = 0.5
//        startPointSlider.layer.masksToBounds = false
//        startPointSlider.setValue(50.0, animated: true)
//
//        startPointSlider.addTarget(self, action: #selector(self.onStartPointlabel(_:)), for: .valueChanged)
//
//        // 最小値と最大値を設定する.
//        startPointSlider.minimumValue = 0
//        startPointSlider.maximumValue = 100
//
//        self.view.addSubview(startPointSlider)
//        startPointSlider.anchor(top: nil, left: mapView.leftAnchor, bottom: mapView.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 76, paddingBottom: 20, paddingRight: 76, width: 0, height: 40)
//
//        //一つめのラベル
//        let startPointlabel = UILabel()
//        startPointlabel.text = "１時間前"
//        startPointlabel.sizeToFit()
//        startPointlabel.layer.position = CGPoint(x:self.view.frame.midX, y:450)
//        self.view.addSubview(startPointlabel)
//        startPointlabel.anchor(top: nil, left: startPointSlider.leftAnchor, bottom: startPointSlider.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 80, height: 20)
//
//        let endPointlabel = UILabel()
//        endPointlabel.text = "現在"
//        endPointlabel.textAlignment = .right
//        endPointlabel.sizeToFit()
//        endPointlabel.layer.position = CGPoint(x:self.view.frame.midX, y:450)
//        self.view.addSubview(endPointlabel)
//        endPointlabel.anchor(top: nil, left: nil, bottom: startPointSlider.topAnchor, right: startPointSlider.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 80, height: 20)



