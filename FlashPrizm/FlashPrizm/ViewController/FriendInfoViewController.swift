//
//  FriendInfoViewController.swift
//  FlashPrizm
//
//  Created by Cade Edney on 3/19/23.
//

import Foundation
import UIKit
import Firebase

class FriendInfoViewController: UIViewController {
    var friendID = ""
    var friendName = ""
    var friendUser: FlashUser!
    var prizmSetsTable = UITableView()
    var followButton = UIButton()
        
    override func viewDidLoad() {
        getFriendData { friend in
            self.friendUser = friend
            self.setUpComponents()
            self.setUpTableView()
            self.prizmSetsTable.reloadData()
        }
    }
    
    func viewReload() {
        getFriendData { friend in
            self.friendUser = friend
            self.view.clearAllSubviews()
            self.setUpComponents()
        }
    }
    
    func getFriendData(completion: @escaping (FlashUser?) -> Void) {
        FirebaseManager.shared.fetchFriendData(uid: self.friendID) { user, error in
            guard let user = user, error == nil else {
                print("No user (aaa)")
                completion(nil)
                return
            }
            completion(user)
        }
    }
    
    func setUpComponents() {
        guard let user = friendUser else {
            print("No user")
            return
        }
        friendName = user.username
        
        // Set up background
        view.backgroundColor = Colors.background
        
        // Set up username
        let nameLabel = UILabel()
        view.addSubview(nameLabel)
        nameLabel.font = UIFont(name: Fonts.gilmerBold, size: 50)
        nameLabel.text = friendName
        nameLabel.textColor = Colors.black
        nameLabel.sizeToFit()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            nameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
        
        // Set up User Info
        let userInfo = UserInfoView(user: user, frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 3))
        view.addSubview(userInfo)
        userInfo.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userInfo.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            userInfo.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 47),
            userInfo.bottomAnchor.constraint(equalTo: userInfo.topAnchor, constant: 110)
        ])
        
        // Set up Follow Button
        followButton = UIButton()
        view.addSubview(followButton)
        
        var followConfiguration = UIButton.Configuration.filled()
        followConfiguration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 30, bottom: 5, trailing: 30)
        if FirebaseManager.shared.isFollowing(otherID: friendID) {
            followConfiguration.baseBackgroundColor = Colors.gray
            followConfiguration.attributedTitle = AttributedString("Unfollow", attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont(name: Fonts.gilmerBold, size: 20)!,
                NSAttributedString.Key.foregroundColor: Colors.white as Any,
                NSAttributedString.Key.backgroundColor: UIColor.clear as Any
            ]))
        } else {
            followConfiguration.baseBackgroundColor = Colors.green2
            followConfiguration.attributedTitle = AttributedString("Follow", attributes: AttributeContainer([
                NSAttributedString.Key.font: UIFont(name: Fonts.gilmerBold, size: 20)!,
                NSAttributedString.Key.foregroundColor: Colors.white as Any,
                NSAttributedString.Key.backgroundColor: UIColor.clear as Any
            ]))
        }
        
        followButton.configuration = followConfiguration
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.layer.cornerRadius = 15
        NSLayoutConstraint.activate([
            followButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            followButton.topAnchor.constraint(equalTo: userInfo.bottomAnchor, constant: 20),
            followButton.leadingAnchor.constraint(equalTo: userInfo.leadingAnchor),
            followButton.trailingAnchor.constraint(equalTo: userInfo.trailingAnchor)
        ])
        followButton.addTarget(self, action: #selector(followPressed), for: .touchUpInside)
        
        // Set up PrizmSets label
        let prizmSetsHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        let dropdown = UIImageView(frame: CGRect(x: 0, y: 7.5, width: 30, height: 30))
        prizmSetsHeaderView.addSubview(dropdown)
        dropdown.image = UIImage(named: "dropdown")
        let prizmSetsLabel = UILabel(frame: CGRect(x: 35, y: 0, width: 0, height: 0))
        prizmSetsHeaderView.addSubview(prizmSetsLabel)
        prizmSetsLabel.text = "Public PrizmSets"
        prizmSetsLabel.font = UIFont(name: Fonts.garetBook, size: 20)
        prizmSetsLabel.sizeToFit()
        
        let line = UIView(frame: CGRect(x: prizmSetsLabel.frame.width + dropdown.frame.width + 10, y: 13, width: view.frame.width - dropdown.frame.width - prizmSetsLabel.frame.width - 20, height: 1))
        prizmSetsHeaderView.addSubview(line)
        line.backgroundColor = Colors.black
        
        prizmSetsHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(prizmSetsHeaderView)
        NSLayoutConstraint.activate([
            prizmSetsHeaderView.topAnchor.constraint(equalTo: followButton.bottomAnchor, constant: 25),
            prizmSetsHeaderView.bottomAnchor.constraint(equalTo: prizmSetsHeaderView.topAnchor, constant: 30)
        ])
        
        // Table View
        view.addSubview(prizmSetsTable)
        prizmSetsTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            prizmSetsTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            prizmSetsTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            prizmSetsTable.topAnchor.constraint(equalTo: prizmSetsHeaderView.bottomAnchor, constant: 25),
            prizmSetsTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        prizmSetsTable.backgroundColor = Colors.background
        prizmSetsTable.separatorStyle = .none
    }
    
    @objc func followPressed(sender: UIButton) {
        if FirebaseManager.shared.isFollowing(otherID: friendID) {
            FirebaseManager.shared.unfollowUser(other: friendUser)
            FirebaseManager.shared.fetchData { error in
                if let error = error {
                    print(error)
                }
                self.viewReload()
            }
        } else {
            FirebaseManager.shared.followUser(other: friendUser)
            FirebaseManager.shared.fetchData { error in
                if let error = error {
                    print(error)
                }
                self.viewReload()
            }
        }
    }
}


extension FriendInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func setUpTableView() {
        prizmSetsTable.dataSource = self
        prizmSetsTable.delegate = self
        prizmSetsTable.register(UITableViewCell.self, forCellReuseIdentifier: "friendPrizmSet")
        prizmSetsTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendUser.prizmSets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendPrizmSet", for: indexPath)
        FirebaseManager.shared.fetchPrizms(prizmIds: friendUser.prizmSets) { sets, error in
            guard let sets = sets, error == nil else {
                print("Could not get sets")
                return
            }
            
            cell.backgroundColor = Colors.background
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let prizmSetButton = UIButton(frame: CGRect(x: 20, y: 5, width: self.view.frame.width - 40, height: 50))
            cell.addSubview(prizmSetButton)
            prizmSetButton.backgroundColor = Colors.green3
            prizmSetButton.layer.cornerRadius = 16
            prizmSetButton.dropShadow()
            
            let prizmSetName = UILabel(frame: CGRect(x: 30, y: prizmSetButton.frame.height / 2 - 12.5, width: 0, height: 0))
            prizmSetButton.addSubview(prizmSetName)
            prizmSetName.text = sets[indexPath.row].prizmName
            prizmSetName.font = UIFont(name: Fonts.gilmerBold, size: 25)
            prizmSetName.textColor = Colors.white
            prizmSetName.sizeToFit()
        }
        
        return cell
    }
}
