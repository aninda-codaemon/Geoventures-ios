//
//  ConstantVC.swift
//  GeoVenturesApp
//
//  Created by Cano-n on 18/12/17.
//  Copyright © 2017 Cano-n. All rights reserved.
//

import UIKit
import Alamofire
class ConstantVC: UIViewController {
    
    //http://52.87.171.80/geotracker/api/poc/user-search-post
    //------------------------------------------------
    //MARK:- API Related Variables and Methods
    //------------------------------------------------
    static let baseURL = "http://52.87.171.80/geotracker"
    static let logIn = "\(ConstantVC.baseURL)/api/poc/user-login"
    static let logOut = "\(ConstantVC.baseURL)/api/poc/user-logout"
    static let setRadius = "\(ConstantVC.baseURL)/api/poc/user-set-radius"
    static let userManualPost = "\(ConstantVC.baseURL)/api/poc/user-post-add"
    static let userParseInsta =  "\(ConstantVC.baseURL)/api/poc/user-insta-post-parse"
    static let saveInstaPost =  "\(ConstantVC.baseURL)/api/poc/user-save-insta-post"
    static let userFindPost =  "\(ConstantVC.baseURL)/api/poc/user-search-post"
    //------------------------------------------------
    //MARK:- Alert View Title
    //------------------------------------------------
    
    static let alertViewTitle = "Message"
    
    
    //------------------------------------------------
    //MARK:- Screen Size
    //------------------------------------------------
    static let screenSize:CGSize = UIScreen.main.bounds.size;
    static let screenWidth:CGFloat = screenSize.width;
    static let screenHeight:CGFloat = screenSize.height;
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//------------------------------------------------
//MARK:- InternetConnection Messages
//------------------------------------------------
enum InternetConnection: String
{
    case lost = "The internet connection appears to be offline."
}


