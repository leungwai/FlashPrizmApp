//
//  UserInfoView.swift
//  FlashPrizm
//
//  Created by Cade Edney on 3/24/23.
//

import Foundation
import UIKit

class UserInfoView: UIView, UIImagePickerControllerDelegate {
    
    var profilePicView: UIImageView!
    var numSetsView: UIView!
    var numFollowersView: UIView!
    var numFollowingView: UIView!
    var numSetsLabel: UILabel!
    var numFollowersLabel: UILabel!
    var numFollowingLabel: UILabel!
    var uid: String!
    var flashUser: FlashUser!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpSubviews()
    }
    
    init(uid: String, frame: CGRect) {
        super.init(frame: frame)
        self.uid = uid
        setUpSubviews()
        fetchUserData()
    }
    
    init(user: FlashUser, frame: CGRect) {
        super.init(frame: frame)
        self.flashUser = user
        setUpSubviews()
        inputUserData()
    }
    
    func setUpSubviews() {
        backgroundColor = .clear
        
        // Set up profile pic
        profilePicView = CircularImageView()
        profilePicView.backgroundColor = Colors.green1
        addSubview(profilePicView)
        profilePicView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profilePicView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            profilePicView.heightAnchor.constraint(equalToConstant: 107),
            profilePicView.widthAnchor.constraint(equalToConstant: 107)
        ])
        
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
        
        // Set up number of prizm sets
        numSetsView = UIView()
        addSubview(numSetsView)
        numSetsView.layer.cornerRadius = 10
        numSetsView.backgroundColor = Colors.green4
        numSetsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numSetsView.leadingAnchor.constraint(equalTo: profilePicView.trailingAnchor, constant: 15),
            numSetsView.heightAnchor.constraint(equalToConstant: 107),
            numSetsView.widthAnchor.constraint(equalToConstant: 107)
        ])
        
        // Set up inner of number of prizm sets
        let setsCaption = UILabel(frame: .zero)
        setsCaption.text = "Public\nPrizmSets"
        setsCaption.font = UIFont(name: Fonts.garetBook, size: 12)
        setsCaption.textAlignment = .center
        setsCaption.numberOfLines = 0
        setsCaption.sizeToFit()
        setsCaption.textColor = Colors.white
        numSetsView.addSubview(setsCaption)
        setsCaption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            setsCaption.centerXAnchor.constraint(equalTo: numSetsView.centerXAnchor),
            setsCaption.bottomAnchor.constraint(equalTo: numSetsView.bottomAnchor, constant: -20)
        ])
        
        numSetsLabel = UILabel()
        numSetsLabel.font = UIFont(name: Fonts.gilmerBold, size: 25)
        numSetsLabel.text = "0"
        numSetsLabel.textAlignment = .center
        numSetsLabel.sizeToFit()
        numSetsLabel.textColor = Colors.white
        numSetsView.addSubview(numSetsLabel)
        numSetsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numSetsLabel.centerXAnchor.constraint(equalTo: numSetsView.centerXAnchor),
            numSetsLabel.topAnchor.constraint(equalTo: numSetsView.topAnchor, constant: 20)
        ])
        
        // Set up followers
        numFollowersView = UIView(frame: .zero)
        addSubview(numFollowersView)
        numFollowersView.layer.cornerRadius = 10
        numFollowersView.backgroundColor = Colors.green2
        numFollowersView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numFollowersView.leadingAnchor.constraint(equalTo: numSetsView.trailingAnchor, constant: 15),
            numFollowersView.topAnchor.constraint(equalTo: numSetsView.topAnchor),
            numFollowersView.heightAnchor.constraint(equalToConstant: 51),
            numFollowersView.widthAnchor.constraint(equalToConstant: 97)
        ])
        
        // Set up inners of followers
        let followersCaption = UILabel()
        followersCaption.text = "Followers"
        followersCaption.font = UIFont(name: Fonts.garetBook, size: 12)
        followersCaption.textAlignment = .center
        followersCaption.sizeToFit()
        followersCaption.textColor = Colors.white
        numFollowersView.addSubview(followersCaption)
        followersCaption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            followersCaption.centerXAnchor.constraint(equalTo: numFollowersView.centerXAnchor),
            followersCaption.bottomAnchor.constraint(equalTo: numFollowersView.bottomAnchor, constant: -5)
        ])
        
        numFollowersLabel = UILabel()
        numFollowersLabel.font = UIFont(name: Fonts.gilmerBold, size: 25)
        numFollowersLabel.text = "0"
        numFollowersLabel.textAlignment = .center
        numFollowersLabel.sizeToFit()
        numFollowersLabel.textColor = Colors.white
        numFollowersLabel.translatesAutoresizingMaskIntoConstraints = false
        numFollowersView.addSubview(numFollowersLabel)
        NSLayoutConstraint.activate([
            numFollowersLabel.centerXAnchor.constraint(equalTo: numFollowersView.centerXAnchor),
            numFollowersLabel.topAnchor.constraint(equalTo: numFollowersView.topAnchor, constant: 5)
        ])
        
        // Set up following
        numFollowingView = UIView(frame: .zero)
        addSubview(numFollowingView)
        numFollowingView.layer.cornerRadius = 10
        numFollowingView.backgroundColor = Colors.green1
        numFollowingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numFollowingView.leadingAnchor.constraint(equalTo: numSetsView.trailingAnchor, constant: 15),
            numFollowingView.bottomAnchor.constraint(equalTo: numSetsView.bottomAnchor),
            numFollowingView.heightAnchor.constraint(equalToConstant: 51),
            numFollowingView.widthAnchor.constraint(equalToConstant: 97)
        ])
        
        let followingCaption = UILabel()
        followingCaption.text = "Following"
        followingCaption.font = UIFont(name: Fonts.garetBook, size: 12)
        followingCaption.textAlignment = .center
        followingCaption.sizeToFit()
        followingCaption.textColor = Colors.white
        numFollowingView.addSubview(followingCaption)
        followingCaption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            followingCaption.centerXAnchor.constraint(equalTo: numFollowingView.centerXAnchor),
            followingCaption.bottomAnchor.constraint(equalTo: numFollowingView.bottomAnchor, constant: -5)
        ])
        
        numFollowingLabel = UILabel()
        numFollowingLabel.font = UIFont(name: Fonts.gilmerBold, size: 25)
        numFollowingLabel.text = "0"
        numFollowingLabel.textAlignment = .center
        numFollowingLabel.textColor = Colors.white
        numFollowingLabel.sizeToFit()
        numFollowingLabel.translatesAutoresizingMaskIntoConstraints = false
        numFollowingView.addSubview(numFollowingLabel)
        NSLayoutConstraint.activate([
            numFollowingLabel.centerXAnchor.constraint(equalTo: numFollowingView.centerXAnchor),
            numFollowingLabel.topAnchor.constraint(equalTo: numFollowingView.topAnchor, constant: 5)
        ])
    }
    
    func fetchUserData() {
        FirebaseManager.shared.fetchFriendData(uid: self.uid) { user, error in
            guard let user = user, error == nil else {
                print("No user to read data (friend info)")
                return
            }
            
            print(user.prizmSets)
            
            self.numSetsLabel.text = "\(user.prizmSets.count)"
            self.numFollowersLabel.text = "\(user.followers.count)"
            self.numFollowingLabel.text = "\(user.following.count)"
        }
    }
    
    func inputUserData() {
        guard let user = flashUser else {
            print("No user to read data")
            return
        }
        numSetsLabel.text = "\(user.prizmSets.count)"
        numFollowersLabel.text = "\(user.followers.count)"
        numFollowingLabel.text = "\(user.following.count)"
    }
}
