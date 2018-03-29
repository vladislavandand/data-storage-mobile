//
//  LoginViewController.swift
//  data_storage_mobile
//
//  Created by Vladislav Andreev on 28.02.2018.
//  Copyright © 2018 Vladislav Andreev. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var authFormView: RoundUIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "authBackground"))
        //scrollView.contentSize = self.view.frame.size
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        let austronautImageView = UIImageView(image: #imageLiteral(resourceName: "austronaut"))
        austronautImageView.contentMode = .scaleAspectFit
        let width: CGFloat = 100.0
        let y = authFormView.frame.minY - width - 50
        let austronautFrame = CGRect(x: -width, y: y, width: width, height: width)
        austronautImageView.frame = austronautFrame
        self.scrollView.addSubview(austronautImageView)
        
        //To infinity and beyond!
        UIView.animate(withDuration: 60, delay: 0, options: .curveLinear, animations: {
            austronautImageView.frame = CGRect(x: self.view.frame.width + width, y: y, width: width, height: width)
        }) { (success) in
            if success {
                print("austronaut finish travelling")
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginButtonAction(_ sender: UIButton) {
        
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        self.loginButton.titleLabel?.text = "ПОДОЖДИТЕ"
        
        DataStorageClient.shared.auth(username: username!, password: password!) { (result) in
            switch result {
                case .success(let success,let meta):
                    
                    self.healthCheck(completion: { (success) in
                        if success {
                            DispatchQueue.main.async {
                                print("LOGIN SUCCESS!")
                                self.loginButton.titleLabel?.text = "ПОДОЖДИТЕ"
                                self.performSegue(withIdentifier: "showExplorer", sender: nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                print("wrong email or password")
                                self.loginButton.titleLabel?.text = "ВОЙТИ"
                                self.usernameTextField.text = ""
                                self.passwordTextField.text = ""
                                self.authFormView.shake()
                            }
                        }
                    })
                
                case .failure(let err):
                    DispatchQueue.main.async {
                        print("wrong email or password")
                        self.loginButton.titleLabel?.text = "ВОЙТИ"
                        self.usernameTextField.text = ""
                        self.passwordTextField.text = ""
                        self.authFormView.shake()
                    }
            }
        }
    }
    
    func healthCheck(completion: @escaping (Bool) -> ())  {
        DataStorageClient.shared.healthCheck { (result) in
            switch result {
                case .success(let success,let meta):
                    if success {
                        print("LOGIN SUCCESS")
                        completion(true)
                    } else {
                        completion(false)
                        DispatchQueue.main.async {
                            self.authFormView.shake()
                        }
                    }
                
                case .failure(let err):
                    print("LOGIN FAIL! \(err) \n)")
                    completion(false)
            }
        }
    }
    
    
    
    //MARK: - Gestures
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        view.endEditing(true)
        
    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        if touch.view is UIButton {
//            let button = touch.view as! UIButton
//            button.sendActions(for: .touchUpInside)
//        }
//
//        return true
//
//    }
    
    //MARK: - Keyboard
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let authFormY = authFormView.frame.origin.y
            let padding: CGFloat = 20.0
            let y = keyboardSize.height - authFormY + padding
            print("offset - \(y)")
            setupOffsetForScrollView(y: y)
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        setupOffsetForScrollView(y: 0)
        
    }
    
    func setupOffsetForScrollView(y: CGFloat) {
        let offset = CGPoint(x: scrollView.contentOffset.x, y: y)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            self.scrollView.contentOffset = offset
        })
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        view.endEditing(true)
        
    }
    
}

