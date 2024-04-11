//
//  LoginViewController.swift
//  FlashPrizm
//
//  Created by HowardWu on 2/10/23.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // Outlets for text fields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var backButton: UINavigationItem!
    
    
    // Local variables to store user inputs
    var email: String = ""
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //UI elements
        setUpNavBar()
        //        loginButton.titleLabel?.font = UIFont(name: "Gilmer Bold", size: 25)
        //        forgotPasswordButton.titleLabel?.font = UIFont(name: "Gilmer Bold", size: 20)
        //        forgotPasswordButton.tintColor = Colors.Green4
        //        backButton.titleView?.tintColor = Colors.Green4
        // Setup dismissing the keyboard when the user taps elsewhere
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func setUpNavBar() {
        // changing the background color of the navigation color
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        
        let navBarButtonAppearance = UIBarButtonItemAppearance(style: .plain)
        
        navBarButtonAppearance.normal.titleTextAttributes = [.foregroundColor: Colors.green4!, .font: UIFont(name: Fonts.gilmerBold, size:17)!]
        navBarButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: Colors.green4!, .font: UIFont(name: Fonts.gilmerBold, size:17)!]
        navBarButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: Colors.green4!, .font: UIFont(name: Fonts.gilmerBold, size:17)!]
        navBarButtonAppearance.focused.titleTextAttributes = [.foregroundColor: Colors.green4!, .font: UIFont(name: Fonts.gilmerBold, size:17)!]
        
        navBarAppearance.buttonAppearance = navBarButtonAppearance
        navBarAppearance.backButtonAppearance = navBarButtonAppearance
        navBarAppearance.doneButtonAppearance = navBarButtonAppearance
        
        navigationController?.navigationBar.tintColor = .none
        navigationController?.navigationBar.tintColor = Colors.green4!
        
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        navigationItem.compactAppearance = navBarAppearance
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let email = emailTextField.text, !email.isEmpty {
//            if isValidEmail(email) {
//                // Valid email address
//            } else {
//                // Invalid email address
//                let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
//                alert.message = "Invalid email address!"
//                alert.addAction(UIAlertAction(title: "ok", style: .default))
//                self.present(alert,animated: true)
//            }
//        } else {
//            // Empty text field
//        }
//        return false
//    }
    
    func isValidEmail(_ email: String) -> Bool {
        // Regular expression pattern to match email addresses
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        // Create a regular expression object from the pattern
        guard let emailRegexObject = try? NSRegularExpression(pattern: emailRegex) else {
            return false
        }
        
        // Use the regular expression to find matches in the email address
        let emailRange = NSRange(location: 0, length: email.utf16.count)
        let matches = emailRegexObject.matches(in: email, options: [], range: emailRange)
        
        // If there is exactly one match that spans the entire email address, it is valid
        return matches.count == 1 && matches[0].range == emailRange
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        return true
    }
    
    // Dismiss keyboard when user taps outside
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // Functions to update local variables with user input
    @IBAction func editEmail(_ sender: UITextField) {
        email = sender.text ?? ""
    }
    
    @IBAction func editPassword(_ sender: UITextField) {
        password = sender.text ?? ""
    }
    
    // Log in function
    @IBAction func loginButton(_ sender: Any) {
        if email == "" || password == "" {
            let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
            alert.message = "Please fill out all input fields!"
            alert.addAction(UIAlertAction(title: "ok", style: .default))
            self.present(alert,animated: true)
        } else {
            
            FirebaseManager.shared.logIn(email: email, password: password, completion: {
                (error: Error?) -> Void in
                
                guard let error = error else {
                    return
                }
                
                let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
                alert.message = error.localizedDescription
                alert.addAction(UIAlertAction(title: "ok", style: .default))
                self.present(alert,animated: true)
            })
            
        }
    }
    
}
