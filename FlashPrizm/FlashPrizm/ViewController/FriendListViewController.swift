//
//  FriendListViewController.swift
//  FlashPrizm
//
//  Created by HowardWu on 4/17/23.
//

import UIKit

class FriendListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var navTitle: String!
    var users: [String]!
    var friends: [FlashUser] = []
    var follower: Bool!
    
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar()
//        let navItem = self.navigationItem
//        navItem.title = navTitle
        
        friendsCollectionView.backgroundColor = .clear
        friendsCollectionView.dataSource = self
        friendsCollectionView.delegate = self
        friendsCollectionView.register(UserCollectionViewCell.self, forCellWithReuseIdentifier: "user")
        
    }
    
    func setUpNavBar() {
        // changing the background color of the navigation color
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = Colors.green1

        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: Fonts.gilmerBold, size:20)!]

        let navBarButtonAppearance = UIBarButtonItemAppearance(style: .plain)

        navBarButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: Fonts.gilmerBold, size:17)!]
        navBarButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: Fonts.gilmerBold, size:17)!]
        navBarButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: Fonts.gilmerBold, size:17)!]
        navBarButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: Fonts.gilmerBold, size:17)!]

        navBarAppearance.buttonAppearance = navBarButtonAppearance
        navBarAppearance.backButtonAppearance = navBarButtonAppearance
        navBarAppearance.doneButtonAppearance = navBarButtonAppearance

        navigationController?.navigationBar.tintColor = .none
        navigationController?.navigationBar.tintColor = UIColor.white

        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        navigationItem.compactAppearance = navBarAppearance

        navigationItem.title = navTitle
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if follower! {
            users = FirebaseManager.shared.flashUser?.followers ?? []
        } else {
            users = FirebaseManager.shared.flashUser?.following ?? []
        }
        friends = []
        self.friendsCollectionView.reloadData()
        
        loadFriends()
    }
    
    func loadFriends() {
        
        let dispatchGroup = DispatchGroup()
        
        for user in users {
            dispatchGroup.enter()
            FirebaseManager.shared.db.collection("users").document(user).getDocument { snapshot, error in
                defer {
                    dispatchGroup.leave()
                }
                guard let snapshot = snapshot, snapshot.exists, let userData = snapshot.data() else {
                    return
                }
                
                DispatchQueue.main.async {
                    self.friends.append(FlashUser(data: userData))
                }
                
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.friendsCollectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "user", for: indexPath) as! UserCollectionViewCell
        
        cell.usernameLabel.text = ""
        cell.profilePicView.image = nil
        
        cell.backgroundColor = Colors.green2
        cell.layer.cornerRadius = 20
        
        cell.flashUser = self.friends[indexPath.row]
        cell.setUpSubviews()
        cell.updateUserInfoViews()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        return CGSize(width: width, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let friendVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Storyboard.friendInfoVC) as? FriendInfoViewController
        guard let friendVC = friendVC else {
            print("Unable to get Friend Info View Controller")
            return
        }
        
        friendVC.friendID = friends[indexPath.row].uid
        
        navigationController?.pushViewController(friendVC, animated: true)
        
        
    }
}
