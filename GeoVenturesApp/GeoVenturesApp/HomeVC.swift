

import UIKit
import CoreData
import Alamofire
import MapKit
import SwiftyJSON
import SDWebImage


class HomeVC: UIViewController {

    @IBOutlet var leftSlideView: UIView!
    @IBOutlet var rightSlideView: UIView!
    @IBOutlet var homeTableView: UITableView!
    @IBOutlet var leftBarButton: UIButton!
    @IBOutlet var rightBarButton: UIBarButtonItem!
    
    var leftTap = true
    var rightTap = true
    
    var lat  = ""
    var long = ""
    var messageServer = ""
    var id : String?
    var loginKey : String?
    var currentPage = 1
    var totalPage = 0
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var people: [NSManagedObject] = []
    
    var homeListTitlesForTableView = ["Vijaynagar", "Bhanwarkua", "Mhow", "Airen Height", "Palasia"]
    var homeListImagesForTableView = ["Vijaynagar", "Bhanwarkua", "Mhow", "Airen Height", "Palasia"]
    var homeListAddressForTableView = ["PU-125 near lal bagh", "14 Red Road", "78 Dwarka", "100 Near Hanaman Palace", "G/14 Holkar"]
    var homeListDataDict: Dictionary<String, Any>!
    
    var userSearchPost = [JSON]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        locManager.requestWhenInUseAuthorization()
        locManager.delegate = self
       
        
        homeTableView.estimatedRowHeight = 200
        homeTableView.rowHeight = UITableViewAutomaticDimension
        homeListDataDict = ["images":homeListImagesForTableView, "titles":homeListTitlesForTableView, "address":homeListAddressForTableView]
        loadData()
    }
 
    //-----------------------
    //MARK:- parsing data1  `
    //-----------------------
    
    
  func parseData()
    {
        if people.count != 0 {
            for manage in people {
                id = manage.value(forKeyPath: "id") as? String
                loginKey = manage.value(forKeyPath: "loginKey") as? String
            }
        }
        let parameters: Parameters = ["Id": id!, "loginKey": loginKey!, "userLat":lat, "userLong" : long, "fetchPage" : 1 , "perPage": 100] as [String:Any]
        if self.isConnectedToInternet(){
            self.showHud("")
            Alamofire.request(ConstantVC.userFindPost, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type" :"application/json"]).responseJSON(completionHandler: { (response) in
                debugPrint(response)
                let responseData = response.result.value as AnyObject
                print(responseData)
                
                if (response.result.value != nil) {
                    let response = JSON(response.result.value)
                    if response["status_code"].int ==  200{
                        
                        if let cp = response["data"]["current_page"].int{
                            self.currentPage = cp
                        }
                        
                        if let tp = response["data"]["total_pages"].int{
                            self.totalPage = tp
                        }
                        if let posts = response["data"]["posts"].array{
                            self.userSearchPost = posts;
                            self.homeTableView.reloadData()
                        }
                       
                        self.hideHUD()
                    }else {
                        self.hideHUD()
                        self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message:  response["message"].string!, CancelButtonTitle: "OK");
                    }
                    
                }else {
                    self.hideHUD()
                    self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: "Unable to fetch data", CancelButtonTitle: "OK");
                }
            })
          
        }
        else {
            self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: "Unable to fetch data", CancelButtonTitle: "Cancel")
        }
    }
    
   
    //--------------------
    //MARK:- Loading Data
    //--------------------
    
    
    func loadData() {
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
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                if let  currentLocation = locManager.location{
                    print(currentLocation.coordinate.latitude)
                    print(currentLocation.coordinate.longitude)
                    lat = String(currentLocation.coordinate.latitude)
                    long = String(currentLocation.coordinate.longitude)
                    self.parseData()
                }else{
                    //simulator testing
                    lat = String(22.7196)
                    long = String(75.8577)
                    self.parseData()
                }
            }
        }
        
        leftBarButton.isEnabled = true
        rightBarButton.isEnabled = true
        
    }
    
    //----------------
    //MARK:- Left Menu
    //----------------
    
    @IBAction func leftMenu(_ sender: Any) {
        if leftTap == true && rightTap == true{
            rightBarButton.isEnabled = false
            let  xPosition = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.leftSlideView.frame.origin.x = CGFloat(xPosition)
            })
            leftTap = false
        }else{
            rightBarButton.isEnabled = true
            let  xPosition = leftSlideView.frame.origin.x - leftSlideView.frame.size.width
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.leftSlideView.frame.origin.x = CGFloat(xPosition)
            })
            leftTap = true
        }
    }
    
    //------------------
    //MARK:- Right Menu
    //------------------
    
    @IBAction func rightMenu(_ sender: Any) {
        if  leftTap == true && rightTap == true{
            leftBarButton.isEnabled = false
            let  xPosition = rightSlideView.frame.origin.x - rightSlideView.frame.size.width
            UIView.animate(withDuration: 0.2, animations: {
                self.rightSlideView.frame.origin.x = CGFloat(xPosition)
            })
            rightTap = false
        }
        else if rightTap == false {
            leftBarButton.isEnabled = true
            let  xPosition = rightSlideView.frame.origin.x + rightSlideView.frame.size.width
            UIView.animate(withDuration: 0.2, animations: {
                self.rightSlideView.frame.origin.x = CGFloat(xPosition)
            })
            rightTap = true
        }
    }
    
    //--------------------
    //MARK:- logout action
    //--------------------
    
    @IBAction func logOut(_ sender: Any) {
        var id : String?
        print(people)
        var loginKey : String?
        if people.count != 0 {
            for manage in people {
                id = manage.value(forKeyPath:"id")  as? String
                loginKey = manage.value(forKeyPath:"loginKey")  as? String
            }
        }
        let parameters: Parameters = ["Id": id!, "loginKey": loginKey!] as [String:Any]
        if self.isConnectedToInternet(){
            self.showHud("")
            Alamofire.request(ConstantVC.logOut, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
                debugPrint(response)
                let responseData = response.result.value as AnyObject
                print(responseData)
                if (response.result.value != nil) {
                    self.hideHUD()
                    let messageServer = responseData["message"] ?? "Unable to log out"
                    let isSuccess = responseData["status_code"] as! Int
                    if (isSuccess == 200) {
                        let delegate = UIApplication.shared.delegate as! AppDelegate
                        let context = delegate.persistentContainer.viewContext
                        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
                        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                        do {
                            try context.execute(deleteRequest)
                            try context.save()
                        } catch {
                            print ("There was an error")
                        }
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if leftTap == false {
            let  xPosition = leftSlideView.frame.origin.x - leftSlideView.frame.size.width
            UIView.animate(withDuration: 0.2, animations: {
                self.leftSlideView.frame.origin.x = CGFloat(xPosition)
            })
            leftTap = true
        }
        if rightTap == false {
            let  xPosition = rightSlideView.frame.origin.x + rightSlideView.frame.size.width
            UIView.animate(withDuration: 0.2, animations: {
                self.rightSlideView.frame.origin.x = CGFloat(xPosition)
            })
            rightTap = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

//---------------------------
//MARK: Table Delegate Methods
//----------------------------

extension HomeVC:  UITableViewDataSource, UITableViewDelegate {
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userSearchPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.homeTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomePageTableViewCell
        cell.viewINcell.layer.cornerRadius = 4
        cell.viewINcell.layer.borderWidth = 1
        cell.viewINcell.clipsToBounds = true
        cell.viewINcell.layer.borderColor = UIColor.init(red: 0/255, green: 196/255, blue: 255/255, alpha: 1).cgColor
        cell.address.text =  userSearchPost[indexPath.row]["post_description"].string!
        
        cell.locationImage.sd_setShowActivityIndicatorView(true)
        cell.locationImage.sd_setIndicatorStyle(.gray)
        let imageURL = URL.init(string:  userSearchPost[indexPath.row]["post_media"].string!)
        cell.locationImage.sd_setImage(with: imageURL) { (image, error, cheche, url) in
            
        }
        cell.title.text = userSearchPost[indexPath.row]["post_title"].string!
        return cell
    }
//    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//        if currentPage != totalPage {
//                        self.showHud("")
//                        self.currentPage = currentPage + 1
//                        self.parseData()
//                        self.hideHUD()
//                    }else {
//                        self.hideHUD()
//                        self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: "No More data", CancelButtonTitle: "OK")
//                    }
//    }
//        if currentPage != totalPage {
//                    self.showHud("")
//                        self.currentPage = currentPage + 1
//                        self.parseData()
//                    self.hideHUD()
//                }
    
//
//     func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if currentPage != totalPage {
//            self.showHud("")
//            self.currentPage = currentPage + 1
//            self.parseData()
//            self.hideHUD()
//        }else {
//            self.hideHUD()
//            self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: "No More data", CancelButtonTitle: "OK")
//        }
//     }
    }

extension HomeVC: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            if let  currentLocation = locManager.location{
                print(currentLocation.coordinate.latitude)
                print(currentLocation.coordinate.longitude)
                lat = String(currentLocation.coordinate.latitude)
                long = String(currentLocation.coordinate.longitude)
                self.parseData()
            }else{
                lat = String(22.7196)
                long = String(75.8577)
            }
        }else{
            let alertController = UIAlertController (title: "Message", message: "Please enable your location service.", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Ok", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}


