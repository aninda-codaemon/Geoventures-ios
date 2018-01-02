

import UIKit

class AddPostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var galleryButton: UIButton!
    var imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    @IBAction func cameraOption(_ sender: Any) {
       if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }else{
            self.showAlertViewWithTitle(title: "Warning", Message: "Camera is not available", CancelButtonTitle: "Ok")
        }
       
    }
  
    @IBAction func galleryOption(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
       
        let data = UIImageJPEGRepresentation(selectedImage, 0.1)
        let post = self.storyboard?.instantiateViewController(withIdentifier: "post") as! SlideVC
        post.imageData = data
        dismiss(animated: true, completion: nil)
        present(post, animated: true, completion: nil)
        
        // addChildVC(viewController: sideMenuViewVC, nvc: self.navigationController!);
        //  let sideMenuViewVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "post") as! SlideVC
        //
        //        sideMenuViewVC.userProfileData = self.userProfileData
        //        sideMenuViewVC.view.frame.width = ConstantVC.screenWidth * 0.9
        //        sideMenuViewVC.view.frame.height = ConstantVC.screenHeight * 0.9
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        print("Hello")
    }

}



//------------------------------------------------
//MARK:- For Child ViewController
//------------------------------------------------

extension AddPostViewController {
    internal func addChildVC(viewController: UIViewController, nvc: UINavigationController)
    {
        let child = viewController
        let navigationController = nvc
        navigationController.addChildViewController(child)
        child.view.frame = (navigationController.view?.bounds)!
        navigationController.view?.addSubview(child.view)
        child.view.alpha = 0.0
        child.beginAppearanceTransition(true, animated: true)
        UIView.animate(withDuration: 0, delay: 0.0, options: .curveEaseIn, animations: {(_: Void) -> Void in
            child.view.alpha = 1.0
        }, completion: {(_ finished: Bool) -> Void in
            child.endAppearanceTransition()
            child.didMove(toParentViewController: navigationController)
        })
    }
    
    
    internal func removeChildVC(viewController: UIViewController)
    {
        let child = viewController
        child.willMove(toParentViewController: nil)
        child.beginAppearanceTransition(false, animated: true)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations: {(_: Void) -> Void in
            child.view.alpha = 0.5
        }, completion: {(_ finished: Bool) -> Void in
            child.endAppearanceTransition()
            child.view.removeFromSuperview()
            child.removeFromParentViewController()
        })
    }
}

