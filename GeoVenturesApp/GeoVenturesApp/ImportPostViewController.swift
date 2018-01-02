

import UIKit
import CoreData
import Alamofire
import MapKit

class ImportPostViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var buttonImport: UIButton!
    @IBOutlet var textField: UITextField!
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation! 
    
    var people: [NSManagedObject] = []
    var id : String?
    var loginKey : String?
    var lat  = ""
    var long = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInialConfigurtion()
        locManager.requestWhenInUseAuthorization()
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            if let  currentLocation = locManager.location{
                print(currentLocation.coordinate.latitude)
                print(currentLocation.coordinate.longitude)
                lat = String(self.currentLocation.coordinate.latitude)
                long = String(self.currentLocation.coordinate.longitude)
            }else{
                lat = String(22.7196)
                long = String(75.8577)
            }
        }
        textField.delegate = self
    }
    
    private func setupInialConfigurtion() {
        DispatchQueue.main.async {
            self.textField.autocorrectionType = .no
            self.textField.layer.borderColor = UIColor.init(red: 0/255, green: 196/255, blue: 255/255, alpha: 1).cgColor
            self.textField.layer.borderWidth = 0.5
            self.textField.layer.cornerRadius = 0.5
            
            let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 10, height: 45))
            self.textField.leftView = view
            self.textField.leftViewMode = .always
            
            self.buttonImport.layer.cornerRadius = 2
            self.buttonImport.clipsToBounds = true
        }
    }
    
    @IBAction func importAction(_ sender: Any) {
        if people.count != 0 {
            for manage in people {
                id = manage.value(forKeyPath: "id") as? String
                loginKey = manage.value(forKeyPath: "loginKey") as? String
            }
        }
        let url = textField.text
        
        let parameters: Parameters = ["Id": id!, "loginKey": loginKey!, "postShareURL":url!] as [String:Any]
        
        if self.isConnectedToInternet() {
            self.showHud("")
            Alamofire.request(ConstantVC.userParseInsta, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
                debugPrint(response)
                let responseData = response.result.value as AnyObject
                print(responseData)
                if (response.result.value != nil) {
                    self.hideHUD()
                    let messageServer = responseData["message"] ?? "Unable to fetch data"
                    let isSuccess = responseData["status_code"] as! Int
                    if (isSuccess == 200) {
                        
                        let title = ((responseData["data"]  as? [String:Any] )?["media_info"] as? [String:Any])?["post_title"] ?? ""
                        let desc = ((responseData["data"]  as? [String:Any] )?["media_info"] as? [String:Any])?["post_description"] ?? ""
                        let imgurl = ((responseData["data"]  as? [String:Any] )?["media_info"] as? [String:Any])?["post_media"] ?? ""
                        let mediaId = (responseData["data"] as? [String:Any])?["media_id"] ?? ""
                        let surl = NSURL(string:imgurl as! String  )
                        let thumbnail = NSData(contentsOf : surl! as URL)
                        let post = self.storyboard?.instantiateViewController(withIdentifier: "post") as! SlideVC
                        post.mediaID = (mediaId as? Int) ?? 0
                        post.imageData = thumbnail as? Data
                        post.title = (title   as? String) ?? ""
                        post.descrip = (desc as? String) ?? ""
                        self.hideHUD()
                        self.present(post, animated: true, completion: nil)
             
                    }
                    else {
                        self.hideHUD()
                        
                        self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: messageServer as! String, CancelButtonTitle: "OK")
                    }
                }
                else {
                    self.hideHUD()
                    self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: InternetConnection.lost.rawValue, CancelButtonTitle: "OK");
                }
            })
        }
        else {
            self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: InternetConnection.lost.rawValue, CancelButtonTitle: "Cancel")
        }
    }
    
    //--------------------
    //MARK:- Loading Data
    //--------------------
    
    override func viewWillAppear(_ animated: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        do {
            people = try managedContext.fetch(fetchRequest)
            print(people)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//        if people.count != 0 {
//            for manage in people {
//                id = manage.value(forKeyPath: "id") as? String
//                loginKey = manage.value(forKeyPath: "loginKey") as? String
//            }
//        }
//
//        let parameters: Parameters = ["Id": id!, "loginKey": loginKey!, "userLat":lat, "userLong" : long] as [String:Any]
//
//        if self.isConnectedToInternet() {
//            self.showHud("")
//            Alamofire.request(ConstantVC.userFindPost, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
//                debugPrint(response)
//                let responseData = response.result.value as AnyObject
//                print(responseData)
//                if (response.result.value != nil) {
//                    self.hideHUD()
//                    let messageServer = responseData["message"] ?? "Unable to fetch data"
//                    let isSuccess = responseData["status_code"] as! Int
//                    if (isSuccess == 200) {
//
//                       print(responseData)
//                        self.hideHUD()
//
//                    }
//                    else {
//                        self.hideHUD()
//
//                        self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: messageServer as! String, CancelButtonTitle: "OK");
//                    }
//                }
//                else {
//                    self.hideHUD()
//                    self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: InternetConnection.lost.rawValue, CancelButtonTitle: "OK");
//                }
//            })
//        }
//        else {
//            self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: InternetConnection.lost.rawValue, CancelButtonTitle: "Cancel")
//        }
//    }
    
    //-------------------------
    //MARK:- textfield delegate
    //-------------------------
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.resignFirstResponder()
   
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
