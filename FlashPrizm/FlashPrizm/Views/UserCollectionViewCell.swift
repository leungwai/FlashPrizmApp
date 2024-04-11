//
//  UserCollectionViewItem.swift
//  FlashPrizm
//
//  Created by HowardWu on 4/23/23.
//

import Foundation
import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    
    var profilePicView: UIImageView!
    var usernameLabel: UILabel!
    var containerView: UIView! 
    var flashUser: FlashUser!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = self.bounds
    }
    
    func setUpSubviews() {
        
        // Create the container view
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up profile pic
        profilePicView = CircularImageView()
        profilePicView.backgroundColor = Colors.green1
        profilePicView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profilePicView.widthAnchor.constraint(equalToConstant: 60),
            profilePicView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Setup Username label
        usernameLabel = UILabel()
        usernameLabel.font = UIFont(name: Fonts.gilmerBold, size: 25)
        usernameLabel.textAlignment = .left
        usernameLabel.textColor = .white
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the image and label to the container view
        containerView.addSubview(profilePicView)
        containerView.addSubview(usernameLabel)
        
        // Add the container view to the content view
        contentView.addSubview(containerView)
        
        // Add constraints to the container view
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            profilePicView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            profilePicView.topAnchor.constraint(equalTo: containerView.topAnchor),
            profilePicView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            profilePicView.widthAnchor.constraint(equalTo: profilePicView.heightAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: profilePicView.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            usernameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
        
    }
    
    func updateUserInfoViews() {
        // Download profile image
        let profileImageRef = FirebaseManager.shared.storageRef.child("profile_images/\(self.flashUser.uid).jpg")
        
        profileImageRef.downloadURL { (url, error) in
            if let error = error {
                print("Error downloading profile image: \(error.localizedDescription)")
                self.profilePicView.image = UIImage(named: "DefaultAvatar")
            } else {
                if let url = url {
                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.profilePicView.image = image
                            }
                        }
                    }.resume()
                }
            }
        }
        
        // Put in username
        usernameLabel.text = "@" + flashUser.username
    }
    
}
