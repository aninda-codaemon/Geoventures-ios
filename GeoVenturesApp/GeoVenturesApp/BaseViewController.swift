//
//  BaseVCViewController.swift
//  GeoVenturesApp
//
//  Created by Cano-n on 14/12/17.
//  Copyright © 2017 Cano-n. All rights reserved.
//

import Foundation
import MBProgressHUD
import Alamofire

extension UIViewController {
    typealias AlertViewCompletionBlockVoid = () -> Void;
    
    func showAlertViewWithTitle(title:String, Message msgText: String ,CancelButtonTitle  buttonTitle:String){
        
        let alertContoller: UIAlertController = UIAlertController(title: title, message: msgText, preferredStyle:.alert)
        let alertAction : UIAlertAction = UIAlertAction(title: buttonTitle, style: .cancel) { _ in
            alertContoller.dismiss(animated: true, completion: nil)
        }
        alertContoller.addAction(alertAction)
        
        self.present(alertContoller, animated: true, completion: nil)
    }
    
    
    
    //
    //     //-----------------------------------
    //    //MARK:- show alertView Without Action
    //   //-------------------------------------
    //
    //    func showAlertViewWithoutButtons( title: String, Message msgText: String, Duration time: DispatchTime, completionHandler : @escaping AlertViewCompletionBlockVoid)
    //    {
    //        let alertViewController: UIAlertController = UIAlertController(title: title, message: msgText, preferredStyle: UIAlertControllerStyle.alert);
    //
    //        self.present(alertViewController, animated: true)
    //        {
    //            DispatchQueue.main.asyncAfter(deadline: time, execute:
    //                {
    //                    alertViewController.dismiss(animated: true, completion:
    //                        {
    //                            completionHandler()
    //
    //                    })
    //
    //            })
    //
    //
    //        }
    //    }
    
    //---------------------
    //MARK:- MBProgress Hud
    //---------------------
    
    func showHud(_ message: String) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = message
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
        if UIApplication.shared.isIgnoringInteractionEvents{
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    //--------------------
    //MARK:- Connectivity
    //--------------------
    func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
}

//------------------------------
//MARK: String Trim and validity
//------------------------------

extension String {
    
    func trimWithWhiteSpaceAndNewLines() -> String {
        return  self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    
    func isValidEmail() -> Bool {
        
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0 {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return  returnValue
    }
    
}

