//
//  AllFollowersViewController.swift
//  FlashPrizm
//
//  Created by Michelle Kwan on 3/19/23.
//

import UIKit

class AllFollowersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var followers = UITableView()
    var user = "user"
    var numFollowers = 5 //something like user.friends.count
    //var followersArray =
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numFollowers
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "followerCell", for: indexPath)
        cell.backgroundColor = Colors.background
    
        //set up view for follower
        let cellView = UIView(frame: CGRect(x: 20, y:5, width: view.frame.width - 40, height: 60))
        cell.addSubview(cellView)
        cellView.backgroundColor = Colors.green2
        cellView.layer.cornerRadius = 16
        cellView.dropShadow()
        cellView.clipsToBounds = true
        
        //follower's username
        //let followerName = UILabel(frame: CGRect(x: view.frame.width / 4 - 20, y: cellView.frame.height / 2 - 30, width: cellView.frame.width, height: cellView.frame.height))
        let followerName = UILabel(frame: CGRect(x: 20, y: cellView.frame.height / 2 - 30, width: cellView.frame.width, height: cellView.frame.height))
        cellView.addSubview(followerName)
        let multipleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: Fonts.gilmerBold, size: 20) as Any,
        ]
        let name = NSAttributedString(string: "@follower\(indexPath.row)", attributes: multipleAttributes)
        followerName.attributedText = name
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
        
    }
    
    func setUpTableView(){
        view.addSubview(followers)
        followers.separatorStyle = .none
        followers.translatesAutoresizingMaskIntoConstraints = false
        followers.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        followers.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        followers.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        followers.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        followers.delegate = self
        followers.dataSource = self
        followers.register(UITableViewCell.self, forCellReuseIdentifier: "followerCell")
        followers.backgroundColor = Colors.background
    }
    
    func setUpNavBar() {
        // changing the background color of the navigation color
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = Colors.green1

        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: Fonts.gilmerBold, size:20)!]

        navigationController?.navigationBar.tintColor = .none
        navigationController?.navigationBar.tintColor = UIColor.white

        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
        navigationItem.compactAppearance = navBarAppearance

        navigationItem.title = "All Followers"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        setUpTableView()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
