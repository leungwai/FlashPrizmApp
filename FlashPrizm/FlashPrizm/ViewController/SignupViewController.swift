//
//  SignupViewController.swift
//  FlashPrizm
//
//  Created by HowardWu on 2/10/23.
//

import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate {

    // Outlets for text fields
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    // Outlets for constraints
    @IBOutlet weak var passwordTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneNumberBottomConstraint: NSLayoutConstraint!
    
    // Local variables to store user inputs
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var phoneNumber: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //UI elements
        setUpNavBar()
//        createAccountButton.titleLabel?.font = UIFont(name: "Gilmer Bold", size: 25)
        
        // Setup dismissing the keyboard when the user taps elsewhere
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        // Setup textfield delegates
        passwordTextField.delegate = self
        phoneNumberTextField.delegate = self
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
    
    // Dismiss keyboard when user taps outside
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        phoneNumberTextField.resignFirstResponder()
    }

    // Functions to update local variables with user input
    @IBAction func editUsername(_ sender: UITextField) {
        username = sender.text ?? ""
    }
    
    @IBAction func editEmail(_ sender: UITextField) {
        email = sender.text ?? ""
    }
    
    @IBAction func editPassword(_ sender: UITextField) {
        password = sender.text ?? ""
    }
    
    @IBAction func editPhoneNumber(_ sender: UITextField) {
        phoneNumber = sender.text ?? ""
    }
    
    // Create user account function
    @IBAction func createAccountButton(_ sender: Any) {
        // Getting rid of leading or trailing whitespaces
        username = username.trimmingCharacters(in: .whitespaces)
        email = email.trimmingCharacters(in: .whitespaces)
        password = password.trimmingCharacters(in: .whitespaces)
        phoneNumber = phoneNumber.trimmingCharacters(in: .whitespaces)
        
        if !validateFields() {
            let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
            alert.message = "Please fill out all input fields!"
            alert.addAction(UIAlertAction(title: "ok", style: .default))
            self.present(alert,animated: true)
        } else {
            FirebaseManager.shared.signUp(email: email, password: password, username: username, phoneNumber: phoneNumber, completion: { (error: Error?) -> Void in
                
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passwordTextField {
            passwordTopConstraint.constant = -400
            phoneNumberTopConstraint.constant = 460
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else if textField == phoneNumberTextField {
            phoneNumberTopConstraint.constant = -480
            phoneNumberBottomConstraint.constant = 510
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        passwordTopConstraint.constant = 30
        phoneNumberTopConstraint.constant = 30
        phoneNumberBottomConstraint.constant = 40
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func validateFields() -> Bool {
        if username == "" || email == "" || password == "" || phoneNumber == "" {
            return false
        }
        let range = NSRange(location: 0, length: phoneNumber.utf16.count)
        let phoneRegex = try! NSRegularExpression(pattern: "(\\+\\d{1,2}\\s?)?1?\\-?\\.?\\s?\\(?\\d{3}\\)?[\\s.-]?\\d{3}[\\s.-]?\\d{4}")
        return phoneRegex.firstMatch(in: phoneNumber, range: range) != nil
    }
}
