
import UIKit
import Alamofire
import MBProgressHUD
import CoreData

public struct Serialisationkeys {
    static let id = "id"
    static let name = "name"
    static let email = "email"
    static let contact = "contact"
    static let radius = "radius"
    static let loginKey = "loginKey"
}
class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var logoImage: UIImageView!
    
    var people: [NSManagedObject] = []
    
    //MARK:- UIView life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    private func initialSetup(){
        DispatchQueue.main.async {
            self.passwordTextField.delegate = self
            self.emailTextField.delegate = self
            self.emailTextField.placeholder = "Email"
            self.passwordTextField.placeholder = "Password"
            self.loginButton.layer.cornerRadius = 3.0
            self.emailTextField.autocorrectionType = .no
            self.passwordTextField.autocorrectionType = .no
            self.logoImage.layer.cornerRadius = 4.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
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
        if people.count != 0 {
            let login = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! UINavigationController
            self.present(login, animated: true, completion: nil)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        if emailTextField.text == "" {
            self.showAlertViewWithTitle(title: "Information Required", Message: "please enter your Email", CancelButtonTitle: "OK")
        }else if !self.emailTextField.text!.isValidEmail()  {
            self.showAlertViewWithTitle(title: "Information Required", Message: "Please enter a valid email address.", CancelButtonTitle: "OK");
        }else if passwordTextField.text == "" {
            self.showAlertViewWithTitle(title: "Information Required", Message: "please enter your Password", CancelButtonTitle: "OK")
        }else {
            
            let email = self.emailTextField.text!.trimWithWhiteSpaceAndNewLines()
            let password = self.passwordTextField.text!
            
            let parameters: Parameters = ["userId": email, "userPassword": password] as [String:Any];
            
            if self.isConnectedToInternet() {
                self.showHud("")
                
                Alamofire.request(ConstantVC.logIn, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
                    debugPrint(response)
                    let responseData = response.result.value as AnyObject
                    print(responseData)
                    if (response.result.value != nil) {
                        self.hideHUD()
                        let messageServer = responseData["message"] ?? "Unable to fetch request"
                        let isSuccess = responseData["status_code"] as! Int
                        
                        if (isSuccess == 200) {
                            let id = ((responseData["data"]  as? [String:Any])?["user"] as? [String:Any])?["id"] ?? ""
                            let name = ((responseData["data"]  as? [String:Any] )?["user"] as? [String:Any])?["name"] as! String
                            let email = ((responseData["data"]  as? [String:Any] )?["user"] as? [String:Any])?["email"] ?? ""
                            let contact = ((responseData["data"]  as? [String:Any] )?["user"] as? [String:Any])?["contact_no"] ?? ""
                            var radius = ((responseData["data"]  as? [String:Any] )?["user"] as? [String:Any])?["radius"] ?? ""
                            let loginKey = ((responseData["data"]  as? [String:Any] )?["user"] as? [String:Any])?["login_key"] ?? ""
                            
                            // Configure radius
                           
                            let rad = radius as? String
                            if rad == "1" {
                                radius = "0"
                            }else if rad == "2" {
                                radius = "1"
                            }else if rad == "3" {
                                radius = "2"
                            }else if rad == "4" {
                                radius = "3"
                            }else if rad == "5" {
                                radius = "4"
                            }
                            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                                return
                            }
                            let managedContext = appDelegate.persistentContainer.viewContext
                            let entity = NSEntityDescription.entity(forEntityName: "Person",
                                                                    in: managedContext)!
                            let person = NSManagedObject(entity: entity,
                                                         insertInto: managedContext)
                            //Insert Value below this
                            person.setValue(id, forKeyPath: Serialisationkeys.id)
                            person.setValue(name, forKeyPath: Serialisationkeys.name)
                            person.setValue(email, forKeyPath: Serialisationkeys.email)
                            person.setValue(contact, forKeyPath: Serialisationkeys.contact)
                            person.setValue(radius, forKeyPath: Serialisationkeys.radius)
                            person.setValue(loginKey, forKeyPath: Serialisationkeys.loginKey)
                            do {
                                try managedContext.save()
                                print("Data is Saved Safely")
                            } catch let error as NSError {
                                print("Could not save. \(error), \(error.userInfo)")
                            }
                            let home = self.storyboard?.instantiateViewController(withIdentifier: "nav") as! UINavigationController
                            self.present(home, animated: true, completion: nil)
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
    }
   
    
     //------------------------
    //MARK:- textdield delegate
   //--------------------------
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
                return true
    }
   
    //--------------------------
    //MARK:- textfield to return
    //--------------------------
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
}
