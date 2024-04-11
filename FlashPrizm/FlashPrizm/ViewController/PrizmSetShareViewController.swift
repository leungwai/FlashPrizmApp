//
//  PrizmSetShareViewController.swift
//  FlashPrizm
//
//  Created by Leung Wai Liu on 4/4/23.
//

import Foundation
import UIKit

class UsernameButton: UIButton {
    var username: String!
    var uid: String!
    var profileImage: UIImage!
}

class PrizmSetShareViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    var prizmSet: PrizmSet!
    
    var currentTerm:Int = 0
    
    var prizmSetOwnerID:String!
    var prizmSetID: String!
    var prizmSetClass: String!
    
    let searchBar = UISearchBar()
    var taskForSearching: DispatchWorkItem?
 
    var searchUsernameResults:[String] = []
    var searchUIDResults:[String] = []
    var searchProfileImageResults:[UIImage] = []
    
    var friendzFollowingUIDInitial:[String] = []
    var friendzFollowingUsername:[String] = []
    var friendzFollowingUID:[String] = []
    var friendzFollowingProfilePicture:[UIImage] = []
    
    var toAddUsernameList:[String] = []
    var toAddUIDList:[String] = []
    var toAddProfileImageList:[UIImage] = []
    
    // scrollView
    let scrollView = UIScrollView()
    let scrollContentView = UIView()
    var scrollContentViewWithSearchHeightAnchor:NSLayoutConstraint!
    var scrollContentViewNoSearchHeightAnchor:NSLayoutConstraint!
    var scrollContentViewNoFriendzWithSearchHeightAnchor:NSLayoutConstraint!
    var scrollContentViewNoFriendzNoSearchHeightAnchor:NSLayoutConstraint!
    
    // searchResultsView constraints
    let searchResultsView = UITableView()
    var showHeightAnchor:NSLayoutConstraint!
    var hideHeightAnchor:NSLayoutConstraint!
    
    let followersView = UITableView()
    var showFollowersHeightAnchor:NSLayoutConstraint!
    var hideFollowersHeightAnchor:NSLayoutConstraint!
    
    let toAddListView = UITableView()
    var showToAddListViewHeightAnchor:NSLayoutConstraint!
    var hideToAddListViewHeightAnchor:NSLayoutConstraint!
    
    let noFollowersView = UILabel()
    var showNoFollowersViewHeightAnchor:NSLayoutConstraint!
    var hideNoFollowersViewHeightAnchor:NSLayoutConstraint!
    
    let noAddListView = UILabel()
    var showNoAddListViewHeightAnchor:NSLayoutConstraint!
    var hideNoAddListViewHeightAnchor:NSLayoutConstraint!
    
    let scrollViewContentWithSearchHeight = 1150 as CGFloat
    let scrollViewContentNoSearchHeight = 950 as CGFloat
    let scrollViewContentNoFriendzWithSearchHeight = 950 as CGFloat
    let scrollViewContentNoFriendzNoSearchHeight = 750 as CGFloat
   
    
    convenience init(prizmSet: PrizmSet!) {
        self.init()
        self.prizmSet = prizmSet
        self.prizmSetOwnerID = prizmSet.ownerID
        self.prizmSetID = prizmSet.id
        self.prizmSetClass = prizmSet.className
    }
    
    override func viewDidLoad() {
        // Ensuring that the data is present
        print("INSIDE SHARE VC")
        print(prizmSet ?? "No prizmSet found")
        
        // setting the background color of the view
        view.backgroundColor = Colors.background
        
        // initializing the nav bar
        setUpNavBar()
        
        // setting up Table Views
        setUpTableView()
        
        // retrieving Friend Information
        setUpFriendzInformation()
        
        // initalizing the components of the header bar
        // setUpComponents()
        
        searchResultsView.isHidden = true
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

        navigationItem.title = "Share PrizmSet"
        
        if prizmSet.ownerID == FirebaseManager.shared.currentUser!.uid {
            if toAddUIDList.count != 0 {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareAction))
            }
            
        }
        
        
        
    }
    
    func setUpTableView() {
    
        searchResultsView.separatorStyle = .none
        followersView.separatorStyle = .none
        toAddListView.separatorStyle = .none
        
        searchResultsView.delegate = self
        followersView.delegate = self
        toAddListView.delegate = self
        
        searchResultsView.dataSource = self
        followersView.dataSource = self
        toAddListView.dataSource = self

        searchResultsView.register(UITableViewCell.self, forCellReuseIdentifier: "resultCell")
        followersView.register(UITableViewCell.self, forCellReuseIdentifier: "followerCell")
        toAddListView.register(UITableViewCell.self, forCellReuseIdentifier: "toAddCell")
        
        // retrieving friendz data
        friendzFollowingUIDInitial = FirebaseManager.shared.flashUser?.following ?? []
        
    }
    
    func setUpFriendzInformation() {
        if friendzFollowingUIDInitial.count == 0 {
            return
        }
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        FirebaseManager.shared.fetchSetOfFollowerzData(uids: friendzFollowingUIDInitial) { error, incomingUIDs, incomingUsernames, incomingProfilePictures in
            
            guard incomingUIDs != nil, incomingUsernames != nil, incomingProfilePictures != nil else {
                print("This user has no Following Friendz found")
                return
            }
            
            self.friendzFollowingUID = incomingUIDs ?? []
            self.friendzFollowingUsername = incomingUsernames ?? []
            self.friendzFollowingProfilePicture = incomingProfilePictures ?? []
            
            
            print("GOT ALL FRIEND DATA")
            print(self.friendzFollowingUID)
            print(self.friendzFollowingUsername)
            print(self.friendzFollowingProfilePicture)
            print("ENTERING MAIN ASYNC")
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            print("REFRESHING FOLLOWRES VIEW AFTER RETRIEVING IT")
            self.followersView.reloadData()
            UIView.animate(withDuration: 0.3) {
                self.setUpComponents()
            }
        }
    }
    
    func setUpComponents() {
        // scroll view to allow the page to scroll
        view.addSubview(scrollView)
        scrollView.delegate = self
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        
        // SCROLL CONTENT VIEW
        scrollView.addSubview(scrollContentView)
        
        let scrollContentGuide = scrollView.contentLayoutGuide
        let scrollFrameGuide = scrollView.frameLayoutGuide
        
        scrollContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollContentView.leadingAnchor.constraint(equalTo: scrollContentGuide.leadingAnchor).isActive = true
        scrollContentView.trailingAnchor.constraint(equalTo: scrollContentGuide.trailingAnchor).isActive = true
        scrollContentView.topAnchor.constraint(equalTo: scrollContentGuide.topAnchor).isActive = true
        scrollContentView.bottomAnchor.constraint(equalTo: scrollContentGuide.bottomAnchor).isActive = true
    
        // vertical scrolling
        scrollContentView.leadingAnchor.constraint(equalTo: scrollFrameGuide.leadingAnchor).isActive = true
        scrollContentView.trailingAnchor.constraint(equalTo: scrollFrameGuide.trailingAnchor).isActive = true
        
        
        scrollContentViewNoSearchHeightAnchor = scrollContentView.heightAnchor.constraint(equalToConstant: scrollViewContentNoSearchHeight)
        scrollContentViewWithSearchHeightAnchor = scrollContentView.heightAnchor.constraint(equalToConstant: scrollViewContentWithSearchHeight)
        
        scrollContentViewNoFriendzNoSearchHeightAnchor = scrollContentView.heightAnchor.constraint(equalToConstant: scrollViewContentNoFriendzNoSearchHeight)
        scrollContentViewNoFriendzWithSearchHeightAnchor = scrollContentView.heightAnchor.constraint(equalToConstant: scrollViewContentNoFriendzWithSearchHeight)
        
        if friendzFollowingUID.count == 0 {
            scrollContentViewNoFriendzNoSearchHeightAnchor.isActive = true
        } else {
            scrollContentViewNoSearchHeightAnchor.isActive = true
        }
        
        // header bar boundaries
        let headerBarView = UIView()
        scrollContentView.addSubview(headerBarView)
        
        headerBarView.translatesAutoresizingMaskIntoConstraints = false
        headerBarView.heightAnchor.constraint(equalToConstant: 115).isActive = true
        headerBarView.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 20).isActive = true
        headerBarView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20).isActive = true
        headerBarView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20).isActive = true
        
        
        // category that PrizmSet belongs in
        let shareName = UILabel()
        headerBarView.addSubview(shareName)
        shareName.font = UIFont(name: Fonts.gilmerBold, size: 18)
        shareName.text = "Share"
        shareName.sizeToFit()
        
        shareName.translatesAutoresizingMaskIntoConstraints = false
        shareName.topAnchor.constraint(equalTo: headerBarView.topAnchor, constant: 25).isActive = true
        
        let prizmSetName = UILabel()
        headerBarView.addSubview(prizmSetName)
        prizmSetName.font = UIFont(name: Fonts.gilmerBold, size: 35)
        prizmSetName.text = prizmSet.prizmName
        prizmSetName.sizeToFit()
        
        prizmSetName.translatesAutoresizingMaskIntoConstraints = false
        prizmSetName.topAnchor.constraint(equalTo: shareName.bottomAnchor, constant: 10).isActive = true
        
        let toName = UILabel()
        headerBarView.addSubview(toName)
        toName.font = UIFont(name: Fonts.gilmerBold, size: 18)
        toName.text = "to:"
        toName.sizeToFit()
        
        toName.translatesAutoresizingMaskIntoConstraints = false
        toName.topAnchor.constraint(equalTo: prizmSetName.bottomAnchor, constant: 10).isActive = true
        
        //search bar to search for followers
        scrollContentView.addSubview(searchBar)
        searchBar.delegate = self
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        searchBar.topAnchor.constraint(equalTo: headerBarView.bottomAnchor, constant: 10).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 10).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -10).isActive = true
        
        searchBar.searchBarStyle = UISearchBar.Style.minimal
        searchBar.autocapitalizationType = .none
        searchBar.layer.cornerRadius = 10

        searchBar.searchTextField.font = UIFont(name: Fonts.garetBook, size: 15)
        
        let searchBarBackgroundImage = generateBackgroundForSearchBar(color: UIColor.white, size: CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width - 40, height: 45)).roundedCorner(radius: 10)
        searchBar.setSearchFieldBackgroundImage(searchBarBackgroundImage, for: .normal)
        
        // shadow
        searchBar.layer.shadowColor = UIColor.gray.cgColor
        searchBar.layer.shadowOpacity = 0.75
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        // Search Results View
        scrollContentView.addSubview(searchResultsView)
        searchResultsView.translatesAutoresizingMaskIntoConstraints = false
        
        showHeightAnchor = searchResultsView.heightAnchor.constraint(equalToConstant: 200)
        hideHeightAnchor = searchResultsView.heightAnchor.constraint(equalToConstant: 0)
        
        hideHeightAnchor.isActive = true
        
        searchResultsView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10).isActive = true
        searchResultsView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20).isActive = true
        searchResultsView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20).isActive = true
        
        searchResultsView.backgroundColor = UIColor.white
        searchResultsView.layer.cornerRadius = 12

        searchResultsView.clipsToBounds = false
        // shadow
        searchResultsView.layer.shadowColor = UIColor.gray.cgColor
        searchResultsView.layer.shadowOpacity = 1
        searchResultsView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        // Followers list to add from
        let followersHeaderView = UIView()
        scrollContentView.addSubview(followersHeaderView)
        
        followersHeaderView.translatesAutoresizingMaskIntoConstraints = false
        followersHeaderView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        followersHeaderView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20).isActive = true
        followersHeaderView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20).isActive = true
        followersHeaderView.topAnchor.constraint(equalTo: searchResultsView.bottomAnchor, constant: 20).isActive = true
        
        let followersLabel = UILabel(frame: CGRect(x: 5, y: 0, width: 0, height: 0))
        followersHeaderView.addSubview(followersLabel)
        followersLabel.text = "Add from Friendz"
        followersLabel.font = UIFont(name: Fonts.garetBook, size: 20)
        followersLabel.sizeToFit()
        
        let followersLabelLine = UIView(frame: CGRect(x: followersLabel.frame.width + 10, y: 13, width: view.safeAreaLayoutGuide.layoutFrame.width - followersLabel.frame.width - 45, height: 1))
        print("SAFE WIDTH \(followersLabel.frame.width)")
        followersHeaderView.addSubview(followersLabelLine)
        followersLabelLine.backgroundColor = Colors.black
        
        // No Followers View
        scrollContentView.addSubview(noFollowersView)
        noFollowersView.translatesAutoresizingMaskIntoConstraints = false
        noFollowersView.topAnchor.constraint(equalTo: followersHeaderView.bottomAnchor, constant: 5).isActive = true
        noFollowersView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20).isActive = true
        noFollowersView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20).isActive = true
        
        hideNoFollowersViewHeightAnchor = noFollowersView.heightAnchor.constraint(equalToConstant: 0)
        showNoFollowersViewHeightAnchor = noFollowersView.heightAnchor.constraint(equalToConstant: 100)
        
        print("FRIENDS FOLLOWING COUNT \(friendzFollowingUsername.count)")
        if (friendzFollowingUsername.count == 0) {
            showNoFollowersViewHeightAnchor.isActive = true
        } else {
            hideNoFollowersViewHeightAnchor.isActive = true
        }
        
        noFollowersView.backgroundColor = Colors.background
        noFollowersView.layer.cornerRadius = 12
        
        noFollowersView.font = UIFont(name: Fonts.garetBook, size: 20)
        noFollowersView.text = "No Friendz to add with :("
        noFollowersView.textAlignment = .center
        
        // Followers View
        scrollContentView.addSubview(followersView)
        followersView.translatesAutoresizingMaskIntoConstraints = false
        
        followersView.topAnchor.constraint(equalTo: noFollowersView.bottomAnchor, constant: 5).isActive = true
        followersView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20).isActive = true
        followersView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20).isActive = true
        
        hideFollowersHeightAnchor = followersView.heightAnchor.constraint(equalToConstant: 0)
        showFollowersHeightAnchor = followersView.heightAnchor.constraint(equalToConstant: 300)
        
        if (friendzFollowingUsername.count == 0) {
            hideFollowersHeightAnchor.isActive = true
        } else {
            showFollowersHeightAnchor.isActive = true
        }
        
        followersView.backgroundColor = Colors.background
        followersView.layer.cornerRadius = 12
        
        // Followers list to add from
        let toAddListHeaderView = UIView()
        scrollContentView.addSubview(toAddListHeaderView)
        
        toAddListHeaderView.translatesAutoresizingMaskIntoConstraints = false
        toAddListHeaderView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        toAddListHeaderView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20).isActive = true
        toAddListHeaderView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20).isActive = true
        toAddListHeaderView.topAnchor.constraint(equalTo: followersView.bottomAnchor, constant: 20).isActive = true
        
        let toAddListLabel = UILabel(frame: CGRect(x: 5, y: 0, width: 0, height: 0))
        toAddListHeaderView.addSubview(toAddListLabel)
        toAddListLabel.text = "To Add List"
        toAddListLabel.font = UIFont(name: Fonts.garetBook, size: 20)
        toAddListLabel.sizeToFit()
        
        let toAddListLine = UIView(frame: CGRect(x: toAddListLabel.frame.width + 10, y: 13, width: view.safeAreaLayoutGuide.layoutFrame.width - toAddListLabel.frame.width - 45, height: 1))
        print("SAFE WIDTH TOADDLISTLABEL \(toAddListLabel.frame.width)")
        toAddListHeaderView.addSubview(toAddListLine)
        toAddListLine.backgroundColor = Colors.black
        
        // No Add List View
        scrollContentView.addSubview(noAddListView)
        noAddListView.translatesAutoresizingMaskIntoConstraints = false
        
        noAddListView.topAnchor.constraint(equalTo: toAddListHeaderView.bottomAnchor, constant: 5).isActive = true
        noAddListView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20).isActive = true
        noAddListView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20).isActive = true
        
        hideNoAddListViewHeightAnchor = noAddListView.heightAnchor.constraint(equalToConstant: 0)
        showNoAddListViewHeightAnchor = noAddListView.heightAnchor.constraint(equalToConstant: 100)
        
        showNoAddListViewHeightAnchor.isActive = true
        
        noAddListView.backgroundColor = Colors.background
        noAddListView.layer.cornerRadius = 12
        
        noAddListView.font = UIFont(name: Fonts.garetBook, size: 20)
        noAddListView.text = "No one added yet"
        noAddListView.textAlignment = .center
        
        // To Add List View
        scrollContentView.addSubview(toAddListView)
        toAddListView.translatesAutoresizingMaskIntoConstraints = false
        
        toAddListView.topAnchor.constraint(equalTo: noAddListView.bottomAnchor, constant: 5).isActive = true
        toAddListView.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 20).isActive = true
        toAddListView.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -20).isActive = true
        
        hideToAddListViewHeightAnchor = toAddListView.heightAnchor.constraint(equalToConstant: 0)
        showToAddListViewHeightAnchor = toAddListView.heightAnchor.constraint(equalToConstant: 300)
        
        hideToAddListViewHeightAnchor.isActive = true
        
        toAddListView.backgroundColor = Colors.background
        toAddListView.layer.cornerRadius = 12
  
    }
    
    // generating the appropriate background for the search bar
    func generateBackgroundForSearchBar(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return image
        
    }
    
    // TABLE VIEW SETUP
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.searchResultsView {
            if indexPath.row == searchUsernameResults.count - 1 {
                return 90
            } else {
                return 75
            }
        } else {
            // for friendz and to add list views
            return 75
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchResultsView {
            return searchUsernameResults.count
        } else if tableView == self.followersView {
            return friendzFollowingUsername.count
        } else {
            return toAddUsernameList.count
        }
     
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.searchResultsView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.clearAllSubviews()
            
            print("DOING INDEX PATH ROW \(indexPath.row)")
            let cellView = UIView(frame: CGRect(x: 15, y:15, width: searchResultsView.frame.width-30, height: 60))
            cell.addSubview(cellView)
            cellView.backgroundColor = Colors.green2
            cellView.layer.cornerRadius = 10
            cellView.dropShadow()
            cellView.clipsToBounds = true
            
            // profile picture view
            let profilePictureView = UIImageView(frame: CGRect(x: 15, y: 10, width: 40, height: 40))
            cellView.addSubview(profilePictureView)
            profilePictureView.layer.cornerRadius = 20
            profilePictureView.dropShadow()
            profilePictureView.clipsToBounds = true
            profilePictureView.backgroundColor = UIColor.white
            profilePictureView.image = searchProfileImageResults[indexPath.row]
                
            //follower's username
            let followerName = UILabel(frame: CGRect(x: 70, y: cellView.frame.height / 2 - 30, width: cellView.frame.width, height: cellView.frame.height))
            cellView.addSubview(followerName)
            followerName.textColor = UIColor.white
            followerName.font = UIFont(name: Fonts.gilmerBold, size: 20)
            followerName.text = searchUsernameResults[indexPath.row]
            
            // add to list button
            let addButton = UsernameButton(frame: CGRect(x: cellView.frame.width - 80, y: 15, width: 65, height: 30))
            cellView.addSubview(addButton)
            addButton.username = searchUsernameResults[indexPath.row]
            addButton.uid = searchUIDResults[indexPath.row]
            addButton.profileImage = searchProfileImageResults[indexPath.row]
            
            if toAddUIDList.contains(searchUIDResults[indexPath.row]) {
                addButton.backgroundColor = UIColor.blue
                addButton.setTitle("Added", for: .normal)
                addButton.setTitleColor(UIColor.white, for: .normal)
                addButton.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 15)
            } else {
                addButton.backgroundColor = UIColor.white
                addButton.setTitle("Add", for: .normal)
                addButton.setTitleColor(Colors.green2, for: .normal)
                addButton.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 15)
                addButton.addTarget(self, action: #selector(addToList), for: .touchUpInside)
            }
            
            
            addButton.layer.cornerRadius = 15
            addButton.dropShadow()
            
            return cell
            
        } else if tableView == self.followersView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "followerCell", for: indexPath)
            cell.backgroundColor = Colors.background
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.clearAllSubviews()
            
            let cellView = UIView(frame: CGRect(x: 0, y:0, width: followersView.frame.width, height: 60))
            cell.addSubview(cellView)
            cellView.backgroundColor = Colors.green2
            cellView.layer.cornerRadius = 10
            cellView.dropShadow()
            cellView.clipsToBounds = true
            
            // profile picture view
            let profilePictureView = UIImageView(frame: CGRect(x: 15, y: 10, width: 40, height: 40))
            cellView.addSubview(profilePictureView)
            profilePictureView.layer.cornerRadius = 20
            profilePictureView.dropShadow()
            profilePictureView.clipsToBounds = true
            profilePictureView.backgroundColor = UIColor.white
            profilePictureView.image = friendzFollowingProfilePicture[indexPath.row]
            
            
            //follower's username
            let followerName = UILabel(frame: CGRect(x: 70, y: cellView.frame.height / 2 - 30, width: cellView.frame.width, height: cellView.frame.height))
            cellView.addSubview(followerName)
            followerName.textColor = UIColor.white
            followerName.font = UIFont(name: Fonts.gilmerBold, size: 20)
            followerName.text = friendzFollowingUsername[indexPath.row]
            
            // add to list button
            let addButton = UsernameButton(frame: CGRect(x: cellView.frame.width - 80, y: 15, width: 65, height: 30))
            cellView.addSubview(addButton)
            addButton.username = friendzFollowingUsername[indexPath.row]
            addButton.uid = friendzFollowingUID[indexPath.row]
            addButton.profileImage = friendzFollowingProfilePicture[indexPath.row]
            
            if toAddUIDList.contains(friendzFollowingUID[indexPath.row]) {
                addButton.backgroundColor = UIColor.blue
                addButton.setTitle("Added", for: .normal)
                addButton.setTitleColor(UIColor.white, for: .normal)
                addButton.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 15)
            } else {
                addButton.backgroundColor = UIColor.white
                addButton.setTitle("Add", for: .normal)
                addButton.setTitleColor(Colors.green2, for: .normal)
                addButton.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 15)
                addButton.addTarget(self, action: #selector(addToList), for: .touchUpInside)
            }
            
            addButton.layer.cornerRadius = 15
            addButton.dropShadow()
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "toAddCell", for: indexPath)
            cell.backgroundColor = Colors.background
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.clearAllSubviews()
            
            let cellView = UIView(frame: CGRect(x: 0, y:0, width: followersView.frame.width, height: 60))
            cell.addSubview(cellView)
            cellView.backgroundColor = Colors.green2
            cellView.layer.cornerRadius = 10
            cellView.dropShadow()
            cellView.clipsToBounds = true
            
            // profile picture view
            let profilePictureView = UIImageView(frame: CGRect(x: 15, y: 10, width: 40, height: 40))
            cellView.addSubview(profilePictureView)
            profilePictureView.layer.cornerRadius = 20
            profilePictureView.dropShadow()
            profilePictureView.clipsToBounds = true
            profilePictureView.backgroundColor = UIColor.white
            profilePictureView.image = toAddProfileImageList[indexPath.row]
            
            
            //follower's username
            let followerName = UILabel(frame: CGRect(x: 70, y: cellView.frame.height / 2 - 30, width: cellView.frame.width, height: cellView.frame.height))
            cellView.addSubview(followerName)
            followerName.textColor = UIColor.white
            followerName.font = UIFont(name: Fonts.gilmerBold, size: 20)
            followerName.text = toAddUsernameList[indexPath.row]
            
            // remove from list button
            let removeButton = UsernameButton(frame: CGRect(x: cellView.frame.width - 100, y: 15, width: 85, height: 30))
            cellView.addSubview(removeButton)
            removeButton.uid = toAddUIDList[indexPath.row]
            removeButton.username = toAddUsernameList[indexPath.row]
            removeButton.profileImage = toAddProfileImageList[indexPath.row]
            
            removeButton.backgroundColor = UIColor.red
            removeButton.setTitle("Remove", for: .normal)
            removeButton.setTitleColor(UIColor.white, for: .normal)
            removeButton.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 15)
            removeButton.addTarget(self, action: #selector(removeFromList), for: .touchUpInside)
            
            removeButton.layer.cornerRadius = 15
            removeButton.dropShadow()
            
            return cell
        }
        

    }
    func show() {
        hideHeightAnchor.isActive = false
        showHeightAnchor.isActive = true
        searchResultsView.isHidden = false
        
        if friendzFollowingUID.count == 0 {
            scrollContentViewNoFriendzNoSearchHeightAnchor.isActive = false
            scrollContentViewNoFriendzWithSearchHeightAnchor.isActive = true
        } else {
            scrollContentViewNoSearchHeightAnchor.isActive = false
            scrollContentViewWithSearchHeightAnchor.isActive = true
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func hide() {
        showHeightAnchor.isActive = false
        hideHeightAnchor.isActive = true
        searchResultsView.isHidden = true
        
        if friendzFollowingUID.count == 0 {
            scrollContentViewNoFriendzWithSearchHeightAnchor.isActive = false
            scrollContentViewNoFriendzNoSearchHeightAnchor.isActive = true
        } else {
            scrollContentViewWithSearchHeightAnchor.isActive = false
            scrollContentViewNoSearchHeightAnchor.isActive = true
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // SEARCH BAR SETUP
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("SEARCH BAR TEXT DID BEGIN EDITING")
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
        if searchResultsView.isHidden == true {
            show()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("SEARCH BAR CANCEL BUTTON CLICKED")
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        if searchResultsView.isHidden == false {
            hide()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("QUERYING FOR USERNAMES WITH QUERY: \(searchText)")
        queryUsernames(queryValue: searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("SEARCH BAR TEXT DID END EDITING")
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        if searchResultsView.isHidden == false {
            hide()
        }
        
    }
    
    func retrieveData(queryValue: String, dispatchGroup: DispatchGroup) {
        self.searchUIDResults.removeAll()
        self.searchUsernameResults.removeAll()
        self.searchProfileImageResults.removeAll()
        
      
        FirebaseManager.shared.searchUsernames(query: queryValue) { error, incomingUIDs, incomingUsernames, incomingProfilePictures in
            
            guard incomingUIDs != nil, incomingUsernames != nil,  incomingProfilePictures != nil else {
                print("No search results")
                return
            }
            
            self.searchUIDResults = incomingUIDs ?? []
            self.searchUsernameResults = incomingUsernames ?? []
            self.searchProfileImageResults = incomingProfilePictures ?? []
                
            print("GOT THE STUFF IN SHARE VC")
            print(self.searchUIDResults)
            print(self.searchUsernameResults)
            print("ENTERING MAIN ASYNC?")
            dispatchGroup.leave()
                
        }
    }
    
    
    
    func queryUsernames(queryValue: String) {
        if queryValue != "" {
            taskForSearching?.cancel()
            
            let task = DispatchWorkItem {
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                
                self.retrieveData(queryValue: queryValue, dispatchGroup: dispatchGroup)
                
                dispatchGroup.notify(queue: .main) {
                    print("DONE SEARCHING, IN DISPATCH ASYNC")
                    print(self.searchUIDResults)
                    print(self.searchUsernameResults)
                    print("DONE SEARCHING FOR QUERY \(queryValue), reloading data")
                    self.searchResultsView.reloadData()
                }
            }
            
            
            self.taskForSearching = task
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: task)
        }
    }
    
    @objc func addToList(sender: UsernameButton) {
        print("Add to list function")
        
        if toAddUIDList.contains(sender.uid) {
            print("user already added to list, no need to add again")
            return
        }
        
        toAddUIDList.append(sender.uid)
        toAddUsernameList.append(sender.username)
        toAddProfileImageList.append(sender.profileImage)
        
        if toAddUIDList.count != 0 {
            showNoAddListViewHeightAnchor.isActive = false
            hideNoAddListViewHeightAnchor.isActive = true
            
            hideToAddListViewHeightAnchor.isActive = false
            showToAddListViewHeightAnchor.isActive = true
            
            if prizmSet.ownerID == FirebaseManager.shared.currentUser!.uid {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareAction))
            }
        }
        
        sender.backgroundColor = UIColor.blue
        sender.setTitle("Added", for: .normal)
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 15)
        
        followersView.reloadData()
        toAddListView.reloadData()
    }
    
    @objc func removeFromList(sender: UsernameButton) {
        print("Remove from list function")
        
        if let index = toAddUIDList.firstIndex(of: sender.uid) {
            toAddUIDList.remove(at: index)
            toAddUsernameList.remove(at: index)
            toAddProfileImageList.remove(at: index)
        }
        
        if toAddUIDList.count == 0 {
            showToAddListViewHeightAnchor.isActive = false
            hideToAddListViewHeightAnchor.isActive = true
            
            hideNoAddListViewHeightAnchor.isActive = false
            showNoAddListViewHeightAnchor.isActive = true
            
            if prizmSet.ownerID == FirebaseManager.shared.currentUser!.uid {
                navigationItem.rightBarButtonItem = .none
            }
        }
        
        searchResultsView.reloadData()
        followersView.reloadData()
        toAddListView.reloadData()
        
    }
    
 
    @objc func shareAction() {
        if toAddUIDList.count == 0 {
            print("CANNOT ADD - Nothing to add yet")
        }
        
        FirebaseManager.shared.sharePrizm(prizmID: prizmSetID, prizmClassName: prizmSetClass, shareWithIDs: toAddUIDList) { error in
            
            if let error = error {
                let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
                alert.message = error.localizedDescription
                alert.addAction(UIAlertAction(title: "ok", style: .default))
                self.present(alert,animated: true)
                print("ERROR, MADE IT IN HERE?")
                return
            }
            
            print("MADE IT OUT HERE")
            self.navigationController?.popViewController(animated: true)
        }

    }
}
