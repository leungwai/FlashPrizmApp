//
//  AccountsSettingsTableView.swift
//  FlashPrizm
//
//  Created by HowardWu on 3/26/23.
//

import UIKit

class AccountsSettingsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    let titles = ["Change Username", "Change Email", "Change Phone #", "Change Password", "Delete Account"]
    var subtitles = [FirebaseManager.shared.flashUser?.username ?? "nil", FirebaseManager.shared.flashUser?.email ?? "nil", FirebaseManager.shared.flashUser?.phoneNumber ?? "nil", "", ""]
    
    weak var functionDelegate: TableViewDelegate?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SettingsTableCellTableViewCell
        
        cell.titleLabel.text = titles[indexPath.row]
        cell.subtitleLabel.text = subtitles[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            updateValue(.username)
            tableView.deselectRow(at: indexPath, animated: true)
        case 1:
            updateValue(.email)
            tableView.deselectRow(at: indexPath, animated: true)
        case 2:
            updateValue(.phoneNumber)
            tableView.deselectRow(at: indexPath, animated: true)
        case 3:
            FirebaseManager.shared.updateUser(updateField: .password, newValue: "", completion: { (error: Error?) -> Void in
                self.functionDelegate?.popAlert(error?.localizedDescription ?? "No error description")
            })
            functionDelegate?.popAlert("Update password email sent!")
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            updateValue(.deleteUser)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func updateValue(_ updateField: updateType) {
        var type = ""
        switch updateField {
        case .email:
            type = "email"
        case .phoneNumber:
            type = "phone number"
        case .username:
            type = "username"
        default:
            type = ""
        }
        
        var alertController: UIAlertController
        
        if updateField == .deleteUser {
           alertController = UIAlertController(title: "Reauthenticate password" + type, message: nil, preferredStyle: .alert)
        } else {
            alertController = UIAlertController(title: "Enter new " + type, message: nil, preferredStyle: .alert)
        }

        // Add a text field to the alert controller
        alertController.addTextField { (textField) in
            textField.placeholder = "New " + type
            switch updateField {
            case .email:
                textField.keyboardType = .emailAddress
            case .phoneNumber:
                textField.keyboardType = .phonePad
            case .deleteUser:
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
                textField.keyboardType = .default
            default:
                textField.keyboardType = .default
            }
        }

        // Create the cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            // User cancelled the action
        }

        // Create the submit action
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (_) in
            // Get the text field's value
            guard let textField = alertController.textFields?.first, let enteredText = textField.text else {
                return
            }
            
            // Do something with the entered information
            print("Entered information: \(enteredText)")
            
            if updateField == .deleteUser {
                FirebaseManager.shared.reauthenticate(password: enteredText, completion: { (error: Error?) -> Void in
                    if let error = error {
                        self.functionDelegate?.popAlert(error.localizedDescription)
                    } else {
                        
                        let alertController2 = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete your account? This can not be undone.", preferredStyle: .actionSheet)

                        let deleteAction2 = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                            
                            FirebaseManager.shared.updateUser(updateField: .deleteUser, newValue: "", completion: { (error: Error?) -> Void in
                                self.functionDelegate?.popAlert(error?.localizedDescription ?? "No error description")
                            })
                        }

                        let cancelAction2 = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }

                        alertController2.addAction(deleteAction2)
                        alertController2.addAction(cancelAction2)

                        self.functionDelegate?.showAlertVC(alertController2)
                    }
                })
                return
            }
            
            FirebaseManager.shared.updateUser(updateField: updateField, newValue: enteredText, completion: { (error: Error?) -> Void in
                if let error = error {
                    self.functionDelegate?.popAlert(error.localizedDescription)
                } else {
                    self.functionDelegate?.updateView()
                }
            })
            

        }

        // Add the actions to the alert controller
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)

        // Present the alert controller
        functionDelegate?.showAlertVC(alertController)
    }

}
