

import UIKit
import CoreData
import Alamofire

class SetRadiusViewController: UIViewController {
   
    @IBOutlet var saveButton: UIBarButtonItem!
    var people: [NSManagedObject] = []
    @IBOutlet var stepSlider: StepSlider!
    var initialSlide = 0
    
    var id : String?
    var loginKey : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        stepSlider.labels = ["1km", "2km", "3km", "4km", "5km"]
        sliderConfig()
        saveButton.isEnabled = false
    }
    
    private func sliderConfig()
    {
        var radius : String?
        if people.count != 0 {
            for manage in people
            {
                print(manage)
                radius = manage.value(forKeyPath: "radius") as? String
                id = manage.value(forKeyPath: "id") as? String
                loginKey = manage.value(forKeyPath: "loginKey") as? String
            }
            stepSlider.index = UInt(radius!)!
        }
        initialSlide = Int(stepSlider.index)
    }
    
    //------------------------
    //MARK:- changes on slider
    //------------------------
    
    @IBAction func cahnged(_ sender: Any) {
        if stepSlider.index != initialSlide
        {
            saveButton.isEnabled = true
        }
        if stepSlider.index == initialSlide
        {
            saveButton.isEnabled = false
        }
    }
    
    //------------------------------
    //MARK:- Save the updated radius
    //------------------------------
    
    
    @IBAction func save(_ sender: Any) {
        var radius = ""
        
        let rad = String(stepSlider.index)
        if rad == "0" {
            radius = "1km"
        }else if rad == "1" {
            radius = "2km"
        }else if rad == "2" {
            radius = "3km"
        }else if rad == "3" {
            radius = "4km"
        }else if rad == "4" {
            radius = "5km"
        }
       
        let parameters: Parameters = ["Id": id! , "loginKey": loginKey!, "userRadius":radius] as [String:Any]
        
        if self.isConnectedToInternet(){
            self.showHud("")
            
            Alamofire.request(ConstantVC.setRadius, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
                debugPrint(response)
                let responseData = response.result.value as AnyObject
                print(responseData)
                if (response.result.value != nil) {
                    self.hideHUD()
                    let messageServer = responseData["message"] ?? "Unable to set radius"
                    let isSuccess = responseData["status_code"] as! Int
                    if (isSuccess == 200) {
                        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                            return
                        }
                        let managedContext = appDelegate.persistentContainer.viewContext
                        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
                        do {
                            self.people = try managedContext.fetch(fetchRequest)
                        } catch let error as NSError {
                            print("Could not fetch. \(error), \(error.userInfo)")
                        }
                        for manage in self.people {
                            manage.setValue(rad, forKey: "radius")
                        }
                        do {
                            try managedContext.save()
                            print("Data is Saved Safely")
                            self.initialSlide = Int(self.stepSlider.index)
                            self.saveButton.isEnabled = false
                        } catch let error as NSError {
                            print("Could not save. \(error), \(error.userInfo)")
                        }
                        self.hideHUD()
                        self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: messageServer as! String , CancelButtonTitle: "OK")
                    }
                    else {
                        self.hideHUD()
                        self.showAlertViewWithTitle(title: ConstantVC.alertViewTitle, Message: messageServer as! String, CancelButtonTitle: "OK");
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
        print("hello")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
