//
//  SettingsAndProfileViewController.swift
//  FlashPrizm
//
//  Created by HowardWu on 3/19/23.
//

import UIKit

class SettingsAndProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var accountSettingsTableView: AccountsSettingsTableView!
    @IBOutlet weak var appSettingsTableView: AppSettingsTableView!
    
    @IBOutlet weak var publicPrizmsetButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    
    @IBOutlet weak var accountSettingsTableContainerView: UIView!
    @IBOutlet weak var appSettingsTableContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        usernameLabel.text = "@" + (FirebaseManager.shared.flashUser?.username ?? "nil")
        profilePictureView.backgroundColor = Colors.green1
        
        
        // Add tap gesture recognizer to profilePictureView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))
        profilePictureView.isUserInteractionEnabled = true
        profilePictureView.addGestureRecognizer(tapGestureRecognizer)
        
        
        // Set up settings tables
        setUpTableView(containerView: accountSettingsTableContainerView, tableView: accountSettingsTableView)
        setUpTableView(containerView: appSettingsTableContainerView, tableView: appSettingsTableView)
        
        accountSettingsTableView.functionDelegate = self
        appSettingsTableView.functionDelegate = self
        
        // Set up buttons with Firebase data
        setUpStatButtons()
        
        
        // Download profile image
        let profileImageRef = FirebaseManager.shared.storageRef.child("profile_images/\(FirebaseManager.shared.currentUser!.uid).jpg")
        
        profileImageRef.downloadURL { (url, error) in
            if let error = error {
                print("Error downloading profile image: \(error.localizedDescription)")
                self.profilePictureView.image = UIImage(named: "DefaultAvatar")
            } else {
                if let url = url {
                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                self.profilePictureView.image = image
                            }
                        }
                    }.resume()
                }
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateNumbers()
    }
    
    @IBAction func followersButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "FriendListViewController") as! FriendListViewController
        destinationVC.navTitle = "All Followers"
        destinationVC.follower = true
//        destinationVC.users = FirebaseManager.shared.flashUser?.followers ?? []
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func followingButtonTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "FriendListViewController") as! FriendListViewController
        destinationVC.navTitle = "All Following"
        destinationVC.follower = false
//        destinationVC.users = FirebaseManager.shared.flashUser?.following ?? []
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func setUpStatButtons() {
        publicPrizmsetButton.setTitle("", for: .normal)
        followingButton.setTitle("", for: .normal)
        followersButton.setTitle("", for: .normal)
        
        // Set up inner of number of prizm sets
        let setsCaption = UILabel(frame: .zero)
        setsCaption.text = "Public\nPrizmSets"
        setsCaption.font = UIFont(name: Fonts.garetBook, size: 12)
        setsCaption.textAlignment = .center
        setsCaption.numberOfLines = 0
        setsCaption.sizeToFit()
        setsCaption.textColor = Colors.white
        publicPrizmsetButton.addSubview(setsCaption)
        setsCaption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            setsCaption.centerXAnchor.constraint(equalTo: publicPrizmsetButton.centerXAnchor),
            setsCaption.bottomAnchor.constraint(equalTo: publicPrizmsetButton.bottomAnchor, constant: -20)
        ])
        
        let numSetsLabel = UILabel()
        numSetsLabel.font = UIFont(name: Fonts.gilmerBold, size: 25)
        numSetsLabel.text = "\(FirebaseManager.shared.flashUser?.prizmSets.count ?? 0)"
        numSetsLabel.textAlignment = .center
        numSetsLabel.sizeToFit()
        numSetsLabel.textColor = Colors.white
        publicPrizmsetButton.addSubview(numSetsLabel)
        numSetsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numSetsLabel.centerXAnchor.constraint(equalTo: publicPrizmsetButton.centerXAnchor),
            numSetsLabel.topAnchor.constraint(equalTo: publicPrizmsetButton.topAnchor, constant: 20)
        ])
        
        // Set up inners of followers
        let followersCaption = UILabel()
        followersCaption.text = "Followers"
        followersCaption.font = UIFont(name: Fonts.garetBook, size: 12)
        followersCaption.textAlignment = .center
        followersCaption.sizeToFit()
        followersCaption.textColor = Colors.white
        followersButton.addSubview(followersCaption)
        followersCaption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            followersCaption.centerXAnchor.constraint(equalTo: followersButton.centerXAnchor),
            followersCaption.bottomAnchor.constraint(equalTo: followersButton.bottomAnchor, constant: -5)
        ])
        
        let numFollowersLabel = UILabel()
        numFollowersLabel.font = UIFont(name: Fonts.gilmerBold, size: 25)
        numFollowersLabel.text = "\(FirebaseManager.shared.flashUser?.followers.count ?? 0)"
        numFollowersLabel.textAlignment = .center
        numFollowersLabel.sizeToFit()
        numFollowersLabel.textColor = Colors.white
        numFollowersLabel.translatesAutoresizingMaskIntoConstraints = false
        followersButton.addSubview(numFollowersLabel)
        NSLayoutConstraint.activate([
            numFollowersLabel.centerXAnchor.constraint(equalTo: followersButton.centerXAnchor),
            numFollowersLabel.topAnchor.constraint(equalTo: followersButton.topAnchor, constant: 5)
        ])
        
        // Set up inners of following
        let followingCaption = UILabel()
        followingCaption.text = "Following"
        followingCaption.font = UIFont(name: Fonts.garetBook, size: 12)
        followingCaption.textAlignment = .center
        followingCaption.sizeToFit()
        followingCaption.textColor = Colors.white
        followingButton.addSubview(followingCaption)
        followingCaption.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            followingCaption.centerXAnchor.constraint(equalTo: followingButton.centerXAnchor),
            followingCaption.bottomAnchor.constraint(equalTo: followingButton.bottomAnchor, constant: -5)
        ])
        
        let numFollowingLabel = UILabel()
        numFollowingLabel.font = UIFont(name: Fonts.gilmerBold, size: 25)
        numFollowingLabel.text = "\(FirebaseManager.shared.flashUser?.following.count ?? 0)"
        numFollowingLabel.textAlignment = .center
        numFollowingLabel.textColor = Colors.white
        numFollowingLabel.sizeToFit()
        numFollowingLabel.translatesAutoresizingMaskIntoConstraints = false
        followingButton.addSubview(numFollowingLabel)
        NSLayoutConstraint.activate([
            numFollowingLabel.centerXAnchor.constraint(equalTo: followingButton.centerXAnchor),
            numFollowingLabel.topAnchor.constraint(equalTo: followingButton.topAnchor, constant: 5)
        ])
        
        publicPrizmsetButton.sizeToFit()
        followingButton.sizeToFit()
        followersButton.sizeToFit()
    }
    
    func updateNumbers() {
        let numFollowersLabel = followersButton.subviews[2] as! UILabel
        numFollowersLabel.text = "\(FirebaseManager.shared.flashUser?.followers.count ?? 0)"
        
        let numFollowingLabel = followingButton.subviews[2] as! UILabel
        numFollowingLabel.text = "\(FirebaseManager.shared.flashUser?.following.count ?? 0)"
        
    }
    
    func setUpTableView(containerView: UIView, tableView: UITableView) {
        
        containerView.backgroundColor = Colors.green2
        containerView.layer.borderColor = UIColor.gray.cgColor
        containerView.layer.borderWidth = 0
        containerView.layer.cornerRadius = 20
        
        tableView.frame = containerView.bounds
        
        tableView.register(SettingsTableCellTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = (tableView.self as! UITableViewDataSource)
        tableView.backgroundColor = Colors.green2
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .lightGray
        
        tableView.delegate = (tableView as! UITableViewDelegate)
//        tableView.isScrollEnabled = false
    }
    
    // Implement UIImagePickerControllerDelegate methods to handle user's image selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Get the selected image from the info dictionary
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        // Upload the selected image to Firebase Storage
        let profileImageRef = FirebaseManager.shared.storageRef.child("profile_images/\(FirebaseManager.shared.currentUser!.uid).jpg")
        
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let uploadTask = profileImageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading profile image: \(error.localizedDescription)")
            } else {
                print("Profile image uploaded successfully")
            }
        }
        
        // Observe the upload progress and print the progress percentage
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload progress: \(percentComplete)%")
        }
        
        dismiss(animated: true, completion: nil)
        
        // Update the profile image view with the selected image
        profilePictureView.image = selectedImage
    }
    
    // Implement UIImagePickerControllerDelegate method to handle user's image selection cancellation
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func changeProfilePicture() {
        // Present UIImagePickerController to allow user to select a profile picture
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
}


extension SettingsAndProfileViewController: TableViewDelegate {
    
    func popAlert(_ message: String) {
        let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func showAlertVC(_ viewController: UIAlertController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func updateView() {
        viewDidLoad()
        accountSettingsTableView.subtitles = [FirebaseManager.shared.flashUser?.username ?? "undefined", FirebaseManager.shared.flashUser?.email ?? "undefined", FirebaseManager.shared.flashUser?.phoneNumber ?? "undefined", "", ""]
        accountSettingsTableView.reloadData()
    }
    
}
