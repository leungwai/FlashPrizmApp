//
//  ResetViewController.swift
//  FlashPrizm
//
//  Created by HowardWu on 2/10/23.
//

import UIKit

class ResetViewController: UIViewController {
    
    // Outlets for text fields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendEmailButton: UIButton!
    
    // Local variables to store user inputs
    var email: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //UI elements
        setUpNavBar()
//        sendEmailButton.titleLabel?.font = UIFont(name: "Gilmer Bold", size: 25)
        
        // Setup dismissing the keyboard when the user taps elsewhere
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
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
        
        self.navigationController?.navigationBar.tintColor = .none
        self.navigationController?.navigationBar.tintColor = Colors.green4!
        
        self.navigationItem.standardAppearance = navBarAppearance
        self.navigationItem.scrollEdgeAppearance = navBarAppearance
        self.navigationItem.compactAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
        
    }
    
    @objc func cancelAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Dismiss keyboard when user taps outside
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
    }
    
    // Functions to update local variables with user input
    @IBAction func editEmail(_ sender: UITextField) {
        email = sender.text ?? ""
    }
    
    // Reset password function
    @IBAction func sendEmailButton(_ sender: Any) {
        if email == "" {
            let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
            alert.message = "Please fill out all input fields!"
            alert.addAction(UIAlertAction(title: "ok", style: .default))
            self.present(alert,animated: true)
        } else {
            
            FirebaseManager.shared.resetPassword(email: email, completion:  {
                (error: Error?) -> Void in
                guard let error = error else {
                    let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
                    alert.message = "Email sent!"
                    alert.addAction(UIAlertAction(title: "ok", style: .default, handler: {_ in
                        self.dismiss(animated: true)
                    }))
                    self.present(alert,animated: true)
                    return
                }
                
                let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
                alert.message = error.localizedDescription
                alert.addAction(UIAlertAction(title: "ok", style: .default, handler: {_ in
                    self.dismiss(animated: true)
                }))
                self.present(alert,animated: true)
            })
            
        }
        
    }
    
}
