//
//  ViewController.swift
//  Tesseract_Demo
//
//  Created by Abhishek Dwivedi on 14/06/16.
//  Copyright © 2016 Abhishek Dwivedi. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController,UITextViewDelegate,
                            UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scannedDataTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //Action for Photos
    //Opens Photo Library and allows user to select an image from the library.
    @IBAction func photosTapped(sender: AnyObject) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        self.presentViewController(imagePicker,
            animated: true,
            completion: nil)
    }
    
    //Action for Camera button
    //Opens the camera and allows user to take a picture from the camera
    @IBAction func cameraTapped(sender: AnyObject) {
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .Camera
            self.presentViewController(imagePicker,
                animated: true,
                completion: nil)
        }
        else {
            
            //Display an alert if camera isn't available
            let alert = UIAlertController(title: "Sorry!", message: "Can't access camera at the moment", preferredStyle: .Alert)
            let dismissButton = UIAlertAction(title: "Okay", style: .Cancel, handler: {
                (alert : UIAlertAction!) -> Void in
            print("Sorry, your device does not support this feature")
            })
            
            alert.addAction(dismissButton)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //Delegate method for image picker
    //Passes the selected photo to scaleImage() and then passes the scaled image to performImageRecognition()
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        let scaledImage = scaleImage(selectedPhoto, maxDimension: 640)
        
        activityIndicator.startAnimating()
        
        dismissViewControllerAnimated(true, completion: {
            self.performImageRecognition(scaledImage)
        })
    }
    
    //Performs the image recognition using Tesseract APIs
    func performImageRecognition(image: UIImage) {
        let tesseract = G8Tesseract()
        tesseract.language = "eng"
        tesseract.engineMode = .TesseractCubeCombined
        tesseract.pageSegmentationMode = .Auto
        tesseract.maximumRecognitionTime = 60.0
        tesseract.image = image.g8_blackAndWhite()
        tesseract.recognize()
        print(tesseract.recognizedText)
        scannedDataTextView.text = tesseract.recognizedText
        scannedDataTextView.editable = true
        
        activityIndicator.stopAnimating()
    }
    
    //Reduces the size of the image without affecting the aspect ratio
    func scaleImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        
        var scaledSize = CGSizeMake(maxDimension, maxDimension)
        var scaleFactor:CGFloat
        
        if image.size.width > image.size.height {
            scaleFactor = image.size.height / image.size.width
            scaledSize.width = maxDimension
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            scaleFactor = image.size.width / image.size.height
            scaledSize.height = maxDimension
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        image.drawInRect(CGRectMake(0, 0, scaledSize.width, scaledSize.height))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

