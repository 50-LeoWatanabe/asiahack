//
//  CameraController.swift
//  InstagramFirebase
//
//  Created by Brian Voong on 4/24/17.
//  Copyright © 2017 Lets Build That App. All rights reserved.
//

import UIKit
import AVFoundation
import GooglePlaces
import Firebase
import CoreML
import Vision
import ImageIO

extension CGImagePropertyOrientation {
    /**
     Converts a `UIImageOrientation` to a corresponding
     `CGImagePropertyOrientation`. The cases for each
     orientation are represented by different raw values.
     
     - Tag: ConvertOrientation
     */
    init(_ orientation: UIImageOrientation) {
        switch orientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

class CameraController: UIViewController, AVCapturePhotoCaptureDelegate, UIViewControllerTransitioningDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
//        picker.dismiss(animated: true)
        capturePhotoButton.isHidden = true
        sentButton.isHidden = false
        sentButton.isEnabled = true
        pictureButton.isHidden = true
        
        // We always expect `imagePickerController(:didFinishPickingMediaWithInfo:)` to supply the original image.
        if let image =
            info["UIImagePickerControllerOriginalImage"] as? UIImage {
            previewImageView.contentMode = UIViewContentMode.scaleAspectFit
            previewImageView.image = image
            selectedImage = image
            
            let height:CGFloat = self.view.bounds.height
            let width:CGFloat = self.view.bounds.width
            
            let testView = UIView()
            testView.backgroundColor = .white
            view.addSubview(testView)
            testView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: width, height: height - 150)
            
            let previewImageView2 = UIImageView(image: selectedImage)
            previewImageView2.contentMode = .scaleAspectFit
            previewImageView2.clipsToBounds = true
            testView.addSubview(previewImageView2)
            previewImageView2.anchor(top: testView.topAnchor, left: testView.leftAnchor, bottom: testView.bottomAnchor, right: testView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            
            
            
            updateClassifications(for: image)
        }
        
//        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        dismiss(animated: true, completion: nil)
        
    }
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // Initialize Vision Core ML model from base Watson Visual Recognition model
            
            //  Uncomment this line to use the tools model.
            let model = try VNCoreMLModel(for: FireClasify_scale_3().model)
            
            //  Uncomment this line to use the plants model.
            // let model = try VNCoreMLModel(for: watson_plants().model)
            
            // Create visual recognition request using Core ML model
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            }
            request.imageCropAndScaleOption = .scaleFit
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func updateClassifications(for image: UIImage) {
        label.text = "cheking..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.label.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.label.text = "I can not chaek this..."
            } else {
                // Display top classification ranked by confidence in the UI.
                self.label.text = "Yes!!!"
//                 + classifications[0].identifier
                
                if self.label.text == "No!!" {
                    self.sentButton.isHidden = true
                } else {
                    self.judgeYabai()
                    self.sentButton.isHidden = false
                }
            }
        }
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true)
    }
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    let capturePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "capture_photo"), for: .normal)
        button.addTarget(self, action: #selector(handleCapturePhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCapturePhoto() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let settings = AVCapturePhotoSettings()
        
        guard let previewFormatType = settings.availablePreviewPhotoPixelFormatTypes.first else { return }
        
        settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewFormatType]
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    let pictureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "galary"), for: .normal)
        button.addTarget(self, action: #selector(handlePicture), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    @objc func handlePicture() {
        self.presentPhotoPicker(sourceType: .photoLibrary)
    }
    
    let sentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "send2"), for: .normal)
        button.addTarget(self, action: #selector(handleSent), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    @objc func handleSent() {
        print("sent image to firebase DB")
//        label.text = "sharing..."
        sentButton.isHidden = true
        DispatchQueue.main.async {
            self.savedLabel.text = "share...."
//            self.judgeYabai()
        }
        
        guard let uploadData = UIImageJPEGRepresentation(selectedImage, 0.3) else { return }
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("posts").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
            
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image:", err)
                return
            }
            
            guard let imageUrl = metadata?.downloadURL()?.absoluteString else { return }
            
            print("Successfully uploaded post image:", imageUrl)
            
            self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
        }
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String) {
//        guard let postImage = selectedImage else { return }
//        guard let caption = textView.text else { return }
        guard let latitude = latitude else { return }
        guard let longitude = longitude else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let postId = UUID().uuidString
        
        let ref = Database.database().reference().child("posts").child(postId)
        let UesrRef = Database.database().reference().child("userPosts").child(uid)
        
        let values = ["imageUrl": imageUrl, "latitude": latitude, "longitude": longitude, "location": loc, "imageWidth": selectedImage.size.width, "imageHeight": selectedImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                self.sentButton.isEnabled = false
                print("Failed to save post to DB", err)
                return
            }
            
            print("Successfully saved post to DB")
            UesrRef.updateChildValues([postId: 1])
            
            self.dismiss(animated: true, completion: nil)
            
//            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.text = ""
        return label
    }()
    
    var selectedImage = UIImage()
    
    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let imageData = photo.fileDataRepresentation()
        print("sent photo...")
        print(latitude ?? "", longitude ?? "")
        
        let previewImage = UIImage(data: imageData!)
        guard let preview = previewImage else { return }
        selectedImage = preview
        
        let height:CGFloat = self.view.bounds.height
        let width:CGFloat = self.view.bounds.width
        
        let testView = UIView()
        testView.backgroundColor = .white
        view.addSubview(testView)
        testView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: width, height: height - 150)
        
        let previewImageView = UIImageView(image: selectedImage)
        previewImageView.contentMode = .scaleAspectFit
        previewImageView.clipsToBounds = true
            testView.addSubview(previewImageView)
            previewImageView.anchor(top: testView.topAnchor, left: testView.leftAnchor, bottom: testView.bottomAnchor, right: testView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        capturePhotoButton.isHidden = true
        pictureButton.isHidden = true
        pictureButton.isEnabled = false
        
        sentButton.isHidden = false
        self.sentButton.isEnabled = true
        
        updateClassifications(for: selectedImage)
        
    }
    
    let savedLabel = UILabel()
    
    fileprivate func judgeYabai() {
        
        savedLabel.text = "Oh, Now!!!"
        savedLabel.font = UIFont.boldSystemFont(ofSize: 18)
        savedLabel.textColor = .white
        savedLabel.numberOfLines = 0
        savedLabel.backgroundColor = UIColor(white: 0, alpha: 0.3)
        savedLabel.textAlignment = .center
        
        savedLabel.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        capturePhotoButton.isHidden = false
        sentButton.isHidden = true
        sentButton.isEnabled = false
        pictureButton.isHidden = false
        
        transitioningDelegate = self
        view.backgroundColor = .lightGray
        navigationItem.title = "Oh,Now !"
        
        setupCaptureSession()
        setupHUD()
        
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
    }
    
    let locationManager = CLLocationManager()
    var latitude: String?
    var longitude: String?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        latitude = "\(locValue.latitude)"
        longitude = "\(locValue.longitude)"
        
        let myGeocorder = CLGeocoder()
        let myLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        
        myGeocorder.reverseGeocodeLocation(myLocation, completionHandler: { (placemarks, error) -> Void in
            guard let pm = placemarks else { return }
            for placemark in pm {
                guard let adm = placemark.administrativeArea else { return }
                guard let loc = placemark.locality else { return }
                self.loc = "\(adm) \(loc)"
            }
        })
    }
    
    var loc = ""
    
    let customAnimationPresentor = CustomAnimationPresentor()
    let customAnimationDismisser = CustomAnimationDismisser()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationPresentor
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return customAnimationDismisser
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let output = AVCapturePhotoOutput()
    fileprivate func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        
        //1. setup inputs
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let err {
            print("Could not setup camera input:", err)
        }
        
        //2. setup outputs
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        //3. setup output preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        let x:CGFloat = self.view.bounds.origin.x
        let y:CGFloat = self.view.bounds.origin.y
        let width:CGFloat = self.view.bounds.width
        let height:CGFloat = self.view.bounds.height
        
        previewLayer.frame = CGRect(x: x, y: y, width: width, height: height-150)
        previewLayer.videoGravity = .resizeAspectFill
        
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    fileprivate func setupHUD() {
        view.addSubview(capturePhotoButton)
        capturePhotoButton.anchor(top: nil, left: nil, bottom: view.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 24, paddingRight: 0, width: 80, height: 80)
        capturePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: nil, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 30, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        dismissButton.centerYAnchor.constraint(equalTo: capturePhotoButton.centerYAnchor).isActive = true
        
        view.addSubview(sentButton)
        sentButton.anchor(top: nil, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 30, width: 50, height: 50)
        sentButton.centerYAnchor.constraint(equalTo: capturePhotoButton.centerYAnchor).isActive = true
        sentButton.isHidden = true
        
        view.addSubview(pictureButton)
        pictureButton.anchor(top: nil, left: nil, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 30, width: 50, height: 50)
        pictureButton.centerYAnchor.constraint(equalTo: capturePhotoButton.centerYAnchor).isActive = true
        pictureButton.isHidden = false
        pictureButton.isEnabled = true
        
        view.addSubview(label)
        label.anchor(top: nil, left: view.leftAnchor, bottom: capturePhotoButton.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 10, paddingRight: 0, width: 0, height: 20)
    }
}
