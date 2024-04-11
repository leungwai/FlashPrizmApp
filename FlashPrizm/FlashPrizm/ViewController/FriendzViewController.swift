//
//  FriendzViewController.swift
//  FlashPrizm
//
//  Created by Cade Edney on 3/12/23.
//

import Foundation
import UIKit

class FriendzViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let friendVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Storyboard.friendInfoVC) as? FriendInfoViewController
        guard let friendVC = friendVC else {
            print("Unable to get Friend Info View Controller")
            return
        }
        
        if collectionView == self.invites && user.invites.count > 0 {
            friendVC.friendID = user.invites[indexPath.row]
        } else if collectionView == self.discovers {
            friendVC.friendID = self.discoversList[indexPath.row]
        } else {
            return
        }
        navigationController?.pushViewController(friendVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 180, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let user = user else {
            print("No user for collection data (count)")
            return 0
        }
        
        if collectionView == self.invites && user.invites.count > 0 {
            return user.invites.count
        } else if collectionView == self.discovers {
            return discoversList.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let user = user else {
            print("No user for collection data (cell)")
            return UICollectionViewCell()
        }
        
        if collectionView == self.invites && user.invites.count > 0 {
            let inviteID = user.invites[indexPath.row]
            
            let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: "friendCell", for: indexPath)
            cellView.clearAllSubviews()
            cellView.backgroundColor = Colors.green3
            cellView.layer.cornerRadius = 16
            cellView.dropShadow()
            cellView.clearAllSubviews()
            
            let avatar = CircularImageView(image: UIImage(named: "DefaultAvatarWhite"))
            avatar.translatesAutoresizingMaskIntoConstraints = false
            cellView.addSubview(avatar)
            
            NSLayoutConstraint.activate([
                avatar.heightAnchor.constraint(equalTo: cellView.heightAnchor, multiplier: 2.0 / 3),
                avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor),
                avatar.centerXAnchor.constraint(equalTo: cellView.centerXAnchor),
                avatar.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 10)
            ])
            
            let profileImageRef = FirebaseManager.shared.storageRef.child("profile_images/\(inviteID).jpg")
            
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting avatar for \(inviteID): \(error.localizedDescription)")
                } else {
                    if let url = url {
                        URLSession.shared.dataTask(with: url) { data, response, e in
                            if let data = data, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    avatar.image = image
                                }
                            }
                        }.resume()
                    }
                }
            }
            
            FirebaseManager.shared.fetchUsername(userID: inviteID) { username in
                let title = UILabel(frame: CGRect(x: 20, y: cellView.frame.height / 2 - 12, width: 0, height: 0))
                cellView.addSubview(title)
                guard let username = username else {
                    print("Unable to get username")
                    return
                }
                title.text = username
                title.font = UIFont(name: Fonts.gilmerBold, size: 20)
                title.textColor = UIColor.white
                title.sizeToFit()
                title.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    title.centerXAnchor.constraint(equalTo: cellView.centerXAnchor),
                    title.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 10)
                ])
                
            }
            
            return cellView
        } else if collectionView == self.invites && user.invites.count == 0 {
            let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: "friendCell", for: indexPath)
            cellView.clearAllSubviews()
            cellView.backgroundColor = UIColor.lightGray
            cellView.layer.cornerRadius = 16
            cellView.addLineDashedStroke(pattern: [8, 8], radius: 16, color: Colors.black.cgColor)
            cellView.dropShadow()
            
            let avatar = CircularImageView(image: UIImage(named: "DefaultAvatarWhite"))
            avatar.translatesAutoresizingMaskIntoConstraints = false
            cellView.addSubview(avatar)
            
            let noLabel = UILabel()
            noLabel.text = "No Invites"
            noLabel.font = UIFont(name: Fonts.gilmerBold, size: 20)
            noLabel.textAlignment = .center
            noLabel.numberOfLines = 0
            noLabel.translatesAutoresizingMaskIntoConstraints = false
            noLabel.textColor = Colors.white
            noLabel.sizeToFit()
            cellView.addSubview(noLabel)
            
            NSLayoutConstraint.activate([
                avatar.heightAnchor.constraint(equalTo: cellView.heightAnchor, multiplier: 2.0 / 3),
                avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor),
                avatar.centerXAnchor.constraint(equalTo: cellView.centerXAnchor),
                avatar.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 10),
                noLabel.centerXAnchor.constraint(equalTo: cellView.centerXAnchor),
                noLabel.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 10)
            ])
            
            return cellView
        } else if collectionView == self.discovers {
            let discoverID = discoversList[indexPath.row]
            
            let cellView = collectionView.dequeueReusableCell(withReuseIdentifier: "discoverCell", for: indexPath)
            cellView.clearAllSubviews()
            cellView.backgroundColor = Colors.green3
            cellView.layer.cornerRadius = 16
            cellView.dropShadow()
            cellView.clearAllSubviews()
            
            let avatar = CircularImageView(image: UIImage(named: "DefaultAvatarWhite"))
            avatar.translatesAutoresizingMaskIntoConstraints = false
            cellView.addSubview(avatar)
            
            NSLayoutConstraint.activate([
                avatar.heightAnchor.constraint(equalTo: cellView.heightAnchor, multiplier: 2.0 / 3),
                avatar.widthAnchor.constraint(equalTo: avatar.heightAnchor),
                avatar.centerXAnchor.constraint(equalTo: cellView.centerXAnchor),
                avatar.topAnchor.constraint(equalTo: cellView.topAnchor, constant: 10)
            ])
            
            let profileImageRef = FirebaseManager.shared.storageRef.child("profile_images/\(discoverID).jpg")
            
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting avatar for \(discoverID): \(error.localizedDescription)")
                } else {
                    if let url = url {
                        URLSession.shared.dataTask(with: url) { data, response, e in
                            if let data = data, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    avatar.image = image
                                }
                            }
                        }.resume()
                    }
                }
            }
            
            FirebaseManager.shared.fetchUsername(userID: discoversList[indexPath.row]) { username in
                let title = UILabel(frame: CGRect(x: 20, y: cellView.frame.height / 2 - 12, width: 0, height: 0))
                cellView.addSubview(title)
                guard let username = username else {
                    print("Unable to get username")
                    return
                }
                title.text = username
                title.font = UIFont(name: Fonts.gilmerBold, size: 20)
                title.textColor = UIColor.white
                title.sizeToFit()
                title.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    title.centerXAnchor.constraint(equalTo: cellView.centerXAnchor),
                    title.topAnchor.constraint(equalTo: avatar.bottomAnchor, constant: 10)
                ])
            }
            return cellView
        }
        return UICollectionViewCell()
    }
    
    var invites: UICollectionView? = nil
    var discovers: UICollectionView? = nil
    var discoversList: [String] = []
    var user: FlashUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let user = FirebaseManager.shared.flashUser else {
            print("No user for friend data")
            return
        }
        
        self.user = user
        setUpComponents()
        setUpCollectionViews()
        FirebaseManager.shared.fetchRandomUsers(numUsers: 5) { error, uids in
            guard let uids = uids, error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            
            self.discoversList = uids
            
            self.invites?.reloadData()
            self.discovers?.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseManager.shared.fetchUser { flashUser, error in
            guard let flashUser = flashUser, error == nil else {
                print("No current user for friends")
                return
            }
            self.user = flashUser
            self.setUpComponents()
            self.setUpCollectionViews()
            self.invites?.reloadData()
            self.discovers?.reloadData()
        }
    }
    
    func setUpCollectionViews() {
        
        guard invites != nil else {
            print("invites unavailable")
            return
        }
        invites?.delegate = self
        invites?.dataSource = self
        invites?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "friendCell")
        guard discovers != nil else {
            print("discovers unavailable")
            return
        }
        discovers?.delegate = self
        discovers?.dataSource = self
        discovers?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "discoverCell")
    }
    
    func setUpComponents() {
        view.clearAllSubviews()
        
        // Set up background
        view.backgroundColor = Colors.background
        
        // Set up Friendz Label
        let friendzLabel = UILabel()
        view.addSubview(friendzLabel)
        friendzLabel.font = UIFont(name: Fonts.gilmerBold, size: 50)
        friendzLabel.text = "Friendz"
        friendzLabel.textColor = Colors.black
        friendzLabel.sizeToFit()
        friendzLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            friendzLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            friendzLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
        
        // Set up invites section
        let inviteHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        //let dropdown = UIImageView(frame: CGRect(x: 0, y: 7.5, width: 30, height: 30))
        //inviteHeaderView.addSubview(dropdown)
        //dropdown.image = UIImage(named: "dropdown")
        let inviteLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 0, height: 0))
        inviteHeaderView.addSubview(inviteLabel)
        inviteLabel.text = "Invites"
        inviteLabel.font = UIFont(name: Fonts.garetBook, size: 20)
        inviteLabel.sizeToFit()
        
        //let line = UIView(frame: CGRect(x: inviteLabel.frame.width + dropdown.frame.width + 10, y: 13, width: view.frame.width - dropdown.frame.width - inviteLabel.frame.width - 20, height: 1))
        let line = UIView(frame: CGRect(x: inviteLabel.frame.width + 30, y: 13, width: view.frame.width - inviteLabel.frame.width - 50, height: 1))
        inviteHeaderView.addSubview(line)
        line.backgroundColor = Colors.black
        
        inviteHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inviteHeaderView)
        NSLayoutConstraint.activate([
            inviteHeaderView.topAnchor.constraint(equalTo: friendzLabel.bottomAnchor, constant: 47)
        ])
        
        // Set up invites
        let inviteLayout = UICollectionViewFlowLayout()
        inviteLayout.scrollDirection = .horizontal
        invites = UICollectionView(frame: view.frame, collectionViewLayout: inviteLayout)
        guard let invites = invites else {
            print("Uh oh")
            return
        }
        view.addSubview(invites)
        invites.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            invites.heightAnchor.constraint(equalToConstant: 180),
            invites.topAnchor.constraint(equalTo: inviteHeaderView.bottomAnchor, constant: 50),
            invites.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        invites.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        invites.backgroundColor = .clear
        
        // Set up discover section
        let discoverHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        //let discoverDropdown = UIImageView(frame: CGRect(x: 0, y: 7.5, width: 30, height: 30))
        //discoverHeaderView.addSubview(discoverDropdown)
        //discoverDropdown.image = UIImage(named: "dropdown")
        let discoverLabel = UILabel(frame: CGRect(x: 20, y: 0, width: 0, height: 0))
        discoverHeaderView.addSubview(discoverLabel)
        discoverLabel.text = "Discover"
        discoverLabel.font = UIFont(name: Fonts.garetBook, size: 20)
        discoverLabel.sizeToFit()
        
        //let discoverLine = UIView(frame: CGRect(x: discoverLabel.frame.width + discoverDropdown.frame.width + 10, y: 13, width: view.frame.width - discoverDropdown.frame.width - discoverLabel.frame.width - 20, height: 1))
        let discoverLine = UIView(frame: CGRect(x: discoverLabel.frame.width + 30, y: 13, width: view.frame.width - discoverLabel.frame.width - 50, height: 1))
        discoverHeaderView.addSubview(discoverLine)
        discoverLine.backgroundColor = Colors.black
        
        discoverHeaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(discoverHeaderView)
        NSLayoutConstraint.activate([
            discoverHeaderView.topAnchor.constraint(equalTo: invites.bottomAnchor, constant: 47)
        ])
        
        // Set up discovers
        let discoverLayout = UICollectionViewFlowLayout()
        discoverLayout.scrollDirection = .horizontal
        discovers = UICollectionView(frame: view.frame, collectionViewLayout: discoverLayout)
        guard let discovers = discovers else {
            print("Uh oh")
            return
        }
        view.addSubview(discovers)
        discovers.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            discovers.heightAnchor.constraint(equalToConstant: 180),
            discovers.topAnchor.constraint(equalTo: discoverHeaderView.bottomAnchor, constant: 50),
            discovers.widthAnchor.constraint(equalToConstant: view.frame.width)
        ])
        discovers.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        discovers.backgroundColor = .clear
    }
}
