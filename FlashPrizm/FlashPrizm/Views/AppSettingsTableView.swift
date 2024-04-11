//
//  AppSettingsTableView.swift
//  FlashPrizm
//
//  Created by HowardWu on 3/26/23.
//

import UIKit

class AppSettingsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    let titles = ["Change Language", "Notifications", "Log Out"]
    let subtitles = ["English", "Daily", ""]
    
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
            functionDelegate?.popAlert("No alternate language available yet!")
            tableView.deselectRow(at: indexPath, animated: true)
        case 1:
            functionDelegate?.popAlert("No notification setup yet!")
            tableView.deselectRow(at: indexPath, animated: true)
        default:
            FirebaseManager.shared.logOut()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

protocol TableViewDelegate: AnyObject {
    func popAlert(_ message: String)
    func showAlertVC(_ viewController: UIAlertController)
    func updateView()
}
