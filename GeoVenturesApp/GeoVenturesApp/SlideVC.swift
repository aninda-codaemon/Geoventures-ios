//
//  SlideVC.swift
//  GeoVenturesApp
//
//  Created by Cano-n on 20/12/17.
//  Copyright © 2017 Cano-n. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
import MapKit

class SlideVC: UIViewController {
    
    @IBOutlet var labelDesc: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var titleField: UITextField!
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var postBtn: UIButton!
    @IBOutlet var imageOutlet: UIImageView!
    
    var people: [NSManagedObject] = []

    var lat  = ""
    var long = ""
    var mediaID = 0
    
    var imageData:Data?
    var id : String?
    var loginKey : String?
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var tit = ""
    var descrip = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleField.text = title
        self.titleField.setLeftPaddingPoints(10.0)
        self.titleField.setRightPaddingPoints(10.0)
    
        self.descriptionTextView.text = descrip
        if !self.descriptionTextView.text.isEmpty {
            self.labelDesc.isHidden = true
        }else{
            self.labelDesc.isHidden = false
        }
        self.titleField.autocorrectionType = .no
        self.descriptionTextView.autocorrectionType = .no
        
        locManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            if let  currentLocation = locManager.location{
                print(currentLocation.coordinate.latitude)
                print(currentLocation.coordinate.longitude)
                lat = String(currentLocation.coordinate.latitude)
                long = String(currentLocation.coordinate.longitude)
            }else{
                lat = String(22.7196)
                long = String(75.8577)
            }
        }
        viewConfig()
    }
    
    
    private func viewConfig() {
        DispatchQueue.main.async {
            self.imageOutlet.image = UIImage(data:self.imageData! as Data)
            self.titleField.delegate = self
            self.descriptionTextView.delegate = self
            print("latitude is\(self.lat), longitude is \(self.long)")
        }
    }
    
    //----------------------
    //MARK:- loading data
    //----------------------
    
    
    override func viewWillAppear(_ animated: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        for manage in people {
            id = manage.value(forKeyPath: "id") as? String
            loginKey = manage.value(forKeyPath: "loginKey") as? String
        }
        
        print("Id is \(id ?? ""),loginKey is \(loginKey ?? "")")
    }
    
    
    //----------------------------------
    //MARK:- Podt or confirming the data
    //----------------------------------
    
    
    
    @IBAction func postData(_ sender: Any) {
        if mediaID != 0 {
            if people.count != 0 {
                for manage in people {
                    id = manage.value(forKeyPath: "id") as? String
                    loginKey = manage.value(forKeyPath: "loginKey") as? String
                }
            }
            let parameters: Parameters = ["Id": id!, "loginKey": loginKey!, "mediaId":mediaID] as [String:Any]
            
            if self.isConnectedToInternet(){
                self.showHud("")
                Alamofire.request(ConstantVC.saveInstaPost, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
                    debugPrint(response)
                    let responseData = response.result.value as AnyObject
                    print(responseData)
                    if (response.result.value != nil) {
                        self.hideHUD()
                        let messageServer = responseData["message"] ?? "Unable to fetch data"
                        let isSuccess = responseData["status_code"] as! Int
                        if (isSuccess == 200) {
                            self.hideHUD()
                            let alertController = UIAlertController(title: ConstantVC.alertViewTitle, message: messageServer as? String, preferredStyle: .alert)
                            let logOut = UIAlertAction(title: "OK", style: .default) { (action) in
                                self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(logOut)
                            self.present(alertController, animated: true)
                        }
                        else {
                            self.hideHUD()
                            let alertController = UIAlertController(title: ConstantVC.alertViewTitle, message: messageServer as? String, preferredStyle: .alert)
                            let logOut = UIAlertAction(title: "OK", style: .default) { (action) in
                                self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(logOut)
                            self.present(alertController, animated: true)
                            
                        }
                    }
                    else {
                        self.hideHUD()
                        self.dismiss(animated: true, completion: nil)
                        self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: InternetConnection.lost.rawValue, CancelButtonTitle: "OK")
                    }
                })
            }
            else {
                self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: InternetConnection.lost.rawValue, CancelButtonTitle: "Cancel")
            }
        }
        else {
            if titleField.text == "" {
                 self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: "Please fill the title field", CancelButtonTitle: "OK")
            }else if descriptionTextView.text == "" {
                self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: "Please fill the Description field", CancelButtonTitle: "OK")
            }
           else if self.isConnectedToInternet(){
                self.showHud("")
            let parameters = [
                "postLng": long, "postLat": lat, "Id":id!, "loginKey":loginKey!, "postTitle" : titleField.text!, "postDescription" : descriptionTextView.text!, "postType": "I"] as [String : Any]
            
            MultiPart(ConstantVC.userManualPost, params: parameters, Success: { (response) in
                debugPrint(response)
            }, Failure: { (error) in
                debugPrint(error)
            })
            } else {
                self.hideHUD()
                self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: InternetConnection.lost.rawValue, CancelButtonTitle: "Cancel")
            }
            
      }
    }
    
    
    //---------------------------
    //MARK:- multipartForm Data
    //---------------------------
    
    
    func MultiPart(_ endpoint:String, params: [String : Any]?, Success:@escaping (DataResponse<Any>) -> (), Failure:@escaping (Error) -> ()){
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in params! {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
            multipartFormData.append(self.imageData!, withName: "postMedia",fileName: "postMedia.jpeg", mimeType: "image/jpeg")
            
        }, to: endpoint,method: .post, headers: nil)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                upload.responseJSON(completionHandler: { (response) in
                    debugPrint(response)
                    let responseData = response.result.value as AnyObject
                    print(responseData)
                    if (response.result.value != nil) {
                        self.hideHUD()
                        let messageServer = responseData["message"] ?? "Unable to fetch data"
                        let isSuccess = responseData["status_code"] as! Int
                        if (isSuccess == 200) {
                            self.hideHUD()
                            let alertController = UIAlertController(title: ConstantVC.alertViewTitle, message: messageServer as? String, preferredStyle: .alert)
                            let logOut = UIAlertAction(title: "OK", style: .default) { (action) in
                                self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(logOut)
                            self.present(alertController, animated: true)
                            
                           
                        }
                        else {
                            self.hideHUD()
                            self.dismiss(animated: true, completion: nil)
                            let alertController = UIAlertController(title: ConstantVC.alertViewTitle, message: messageServer as? String, preferredStyle: .alert)
                            let logOut = UIAlertAction(title: "OK", style: .default) { (action) in
                                self.dismiss(animated: true, completion: nil)
                            }
                            alertController.addAction(logOut)
                            self.present(alertController, animated: true)
                            
                        }
                    }
                    else {
                        self.hideHUD()
                        self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: InternetConnection.lost.rawValue, CancelButtonTitle: "OK");
                    }
                })
                
            case .failure(let encodingError):
                print(encodingError)
                Failure(encodingError)
            }
        }
        
    }
    
    
    
    @IBAction func cancelPost(_ sender: Any) {
        //        let hmvc = AddPostViewController()
        //        hmvc.removeChildVC(viewController: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SlideVC: UITextFieldDelegate, UITextViewDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.labelDesc.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.descriptionTextView.text.isEmpty
        {
            self.labelDesc.isHidden = false
        }
        else{
            self.labelDesc.isHidden = true
        }
    }
}
