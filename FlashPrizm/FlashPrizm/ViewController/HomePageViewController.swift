//
//  ViewController.swift
//  FlashPrizm
//
//  Created by Cade on 2/10/23.
//

import UIKit
import Foundation

class PrizmSetButton: UIButton {
    var prizmSet: PrizmSet!
}

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var prizmSets = UITableView()
    var segControl = UISegmentedControl()
    var flashUser = FlashUser()
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if segControl.selectedSegmentIndex == 0 {
            if FirebaseManager.shared.byClass.keys.count == 0 {
                return nil
            }
            let sectionView = UIView()
            sectionView.clearAllSubviews()
            //let dropdown = UIImageView(frame: CGRect(x: 0, y: 7.5, width: 30, height: 30))
            //sectionView.addSubview(dropdown)
            //dropdown.image = UIImage(named: "dropdown")
            let label = UILabel(frame: CGRect(x: 20, y: 0, width: 0, height: 0))
            sectionView.addSubview(label)
            label.text = self.flashUser.classOrder[section]
            label.font = UIFont(name: Fonts.garetBook, size: 20)
            label.sizeToFit()
            
            /*let line = UIView(frame: CGRect(x: label.frame.width + dropdown.frame.width + 10,
                                            y: 13,
                                            width: view.frame.width - dropdown.frame.width - label.frame.width - 20, height: 1))
             */
            let line = UIView(frame: CGRect(x: label.frame.width + 30,
                                            y: 13,
                                            width: view.frame.width - label.frame.width - 50, height: 1))
            sectionView.addSubview(line)
            line.backgroundColor = Colors.black
            
            return sectionView
        } else if segControl.selectedSegmentIndex == 1 {
            if FirebaseManager.shared.starredSetsByClass.keys.count == 0 {
                return nil
            }
            
            let sectionView = UIView()
            sectionView.clearAllSubviews()
            //let dropdown = UIImageView(frame: CGRect(x: 0, y: 7.5, width: 30, height: 30))
            //sectionView.addSubview(dropdown)
            //dropdown.image = UIImage(named: "dropdown")
            let label = UILabel(frame: CGRect(x: 20, y: 0, width: 0, height: 0))
            sectionView.addSubview(label)
            label.text = FirebaseManager.shared.starredOrder[section]
            label.font = UIFont(name: Fonts.garetBook, size: 20)
            label.sizeToFit()
            
            /*let line = UIView(frame: CGRect(x: label.frame.width + dropdown.frame.width + 10,
                                            y: 13,
                                            width: view.frame.width - dropdown.frame.width - label.frame.width - 20, height: 1))
            */
            let line = UIView(frame: CGRect(x: label.frame.width + 30,
                                            y: 13,
                                            width: view.frame.width - label.frame.width - 50, height: 1))
            sectionView.addSubview(line)
            line.backgroundColor = Colors.black
            
            return sectionView
            
        } else {
            if FirebaseManager.shared.sharedSetsByClass.keys.count == 0 {
                return nil
            }
            
            let sectionView = UIView()
            sectionView.clearAllSubviews()
            //let dropdown = UIImageView(frame: CGRect(x: 0, y: 7.5, width: 30, height: 30))
            //sectionView.addSubview(dropdown)
            //dropdown.image = UIImage(named: "dropdown")
            let label = UILabel(frame: CGRect(x: 20, y: 0, width: 0, height: 0))
            sectionView.addSubview(label)
            label.text = FirebaseManager.shared.sharedOrder[section]
            label.font = UIFont(name: Fonts.garetBook, size: 20)
            label.sizeToFit()
            
            /*
            let line = UIView(frame: CGRect(x: label.frame.width + dropdown.frame.width + 10,
                                            y: 13,
                                            width: view.frame.width - dropdown.frame.width - label.frame.width - 20, height: 1))
             */
            let line = UIView(frame: CGRect(x: label.frame.width + 30,
                                            y: 13,
                                            width: view.frame.width - label.frame.width - 50, height: 1))
            sectionView.addSubview(line)
            line.backgroundColor = Colors.black
            
            return sectionView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if segControl.selectedSegmentIndex == 0 &&
            FirebaseManager.shared.byClass.keys.count == 0 ||
            segControl.selectedSegmentIndex == 1 &&
            FirebaseManager.shared.starredSetsByClass.keys.count == 0 ||
            segControl.selectedSegmentIndex == 2 &&
            FirebaseManager.shared.sharedSetsByClass.keys.count == 0 {
            return 0
        }
        return 40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if segControl.selectedSegmentIndex == 0 {
            if FirebaseManager.shared.byClass.keys.count > 0 {
                return FirebaseManager.shared.byClass.keys.count
            }
        } else if segControl.selectedSegmentIndex == 1 {
            if FirebaseManager.shared.starredSetsByClass.keys.count > 0 {
                return FirebaseManager.shared.starredSetsByClass.keys.count
            }
        } else {
            if FirebaseManager.shared.sharedSetsByClass.keys.count > 0 {
                return FirebaseManager.shared.sharedSetsByClass.keys.count
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segControl.selectedSegmentIndex == 0 {
            if FirebaseManager.shared.byClass.keys.count > 0 {
                return FirebaseManager.shared.byClass[self.flashUser.classOrder[section]]?.count ?? 0
            }
        } else if segControl.selectedSegmentIndex == 1 {
            if FirebaseManager.shared.starredSetsByClass.keys.count > 0 {
                return FirebaseManager.shared.starredSetsByClass[FirebaseManager.shared.starredOrder[section]]?.count ?? 0
            }
        } else {
            if FirebaseManager.shared.sharedSetsByClass.keys.count > 0 {
                return FirebaseManager.shared.sharedSetsByClass[FirebaseManager.shared.sharedOrder[section]]?.count ?? 0
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segControl.selectedSegmentIndex == 1 &&
            FirebaseManager.shared.starredSetsByClass.keys.count == 0 ||
            segControl.selectedSegmentIndex == 2 &&
            FirebaseManager.shared.sharedSetsByClass.keys.count == 0 {
            return 100.0
        }
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segControl.selectedSegmentIndex == 0 && FirebaseManager.shared.byClass.keys.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "prizmSet", for: indexPath)
            cell.clearAllSubviews()
            cell.backgroundColor = Colors.background
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let prizmSetButton = PrizmSetButton(frame: CGRect(x: 20, y: 5, width: view.frame.width - 40, height: 80))
            cell.addSubview(prizmSetButton)
            
            prizmSetButton.backgroundColor = UIColor.lightGray
            prizmSetButton.layer.cornerRadius = 16
            prizmSetButton.addLineDashedStroke(pattern: [8, 8], radius: 16, color: Colors.black.cgColor)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(pressedFAB))
            prizmSetButton.addGestureRecognizer(tap)
            
            let emptyLabel = UILabel()
            emptyLabel.text = "Looks a little empty in here"
            emptyLabel.font = UIFont(name: Fonts.garetBook, size: 20)
            emptyLabel.textColor = Colors.black
            emptyLabel.sizeToFit()
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            prizmSetButton.addSubview(emptyLabel)
            
            let createLabel = UILabel()
            createLabel.text = "Tap me to create a new PrizmSet!"
            createLabel.font = UIFont(name: Fonts.garetBook, size: 16)
            createLabel.textColor = Colors.black
            createLabel.sizeToFit()
            createLabel.translatesAutoresizingMaskIntoConstraints = false
            prizmSetButton.addSubview(createLabel)
        
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                createLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                emptyLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
                createLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 0)
            ])
            
            return cell
            
        } else if segControl.selectedSegmentIndex == 1 && FirebaseManager.shared.starredSetsByClass.keys.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "prizmSet", for: indexPath)
            cell.clearAllSubviews()
            cell.backgroundColor = Colors.background
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let prizmSetButton = PrizmSetButton(frame: CGRect(x: 20, y: 5, width: view.frame.width - 40, height: 100))
            cell.addSubview(prizmSetButton)
            
            prizmSetButton.backgroundColor = UIColor.lightGray
            prizmSetButton.layer.cornerRadius = 16
            prizmSetButton.addLineDashedStroke(pattern: [8, 8], radius: 16, color: Colors.black.cgColor)
            
            let emptyLabel = UILabel()
            emptyLabel.text = "Looks a little empty in here"
            emptyLabel.font = UIFont(name: Fonts.garetBook, size: 20)
            emptyLabel.textColor = Colors.black
            emptyLabel.sizeToFit()
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyLabel.textAlignment = .center
            prizmSetButton.addSubview(emptyLabel)
            
            let createLabel = UILabel()
            createLabel.text = "Tap on the star on any of your\nPrizm Sets to star it!"
            createLabel.numberOfLines = 0
            createLabel.font = UIFont(name: Fonts.garetBook, size: 16)
            createLabel.textColor = Colors.black
            createLabel.sizeToFit()
            createLabel.translatesAutoresizingMaskIntoConstraints = false
            createLabel.textAlignment = .center
            prizmSetButton.addSubview(createLabel)
        
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                createLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                emptyLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
                createLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 0)
            ])
            
            return cell
            
        } else if segControl.selectedSegmentIndex == 2 && FirebaseManager.shared.sharedSetsByClass.keys.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "prizmSet", for: indexPath)
            cell.clearAllSubviews()
            cell.backgroundColor = Colors.background
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let prizmSetButton = PrizmSetButton(frame: CGRect(x: 20, y: 5, width: view.frame.width - 40, height: 100))
            cell.addSubview(prizmSetButton)
            
            prizmSetButton.backgroundColor = UIColor.lightGray
            prizmSetButton.layer.cornerRadius = 16
            prizmSetButton.addLineDashedStroke(pattern: [8, 8], radius: 16, color: Colors.black.cgColor)
            
            let emptyLabel = UILabel()
            emptyLabel.text = "Looks a little empty in here"
            emptyLabel.font = UIFont(name: Fonts.garetBook, size: 20)
            emptyLabel.textColor = Colors.black
            emptyLabel.sizeToFit()
            emptyLabel.translatesAutoresizingMaskIntoConstraints = false
            emptyLabel.textAlignment = .center
            prizmSetButton.addSubview(emptyLabel)
            
            let createLabel = UILabel()
            createLabel.text = "Ask your Friendz to share\nPrizm Sets with you!"
            createLabel.numberOfLines = 0
            createLabel.font = UIFont(name: Fonts.garetBook, size: 16)
            createLabel.textColor = Colors.black
            createLabel.sizeToFit()
            createLabel.translatesAutoresizingMaskIntoConstraints = false
            createLabel.textAlignment = .center
            prizmSetButton.addSubview(createLabel)
        
            NSLayoutConstraint.activate([
                emptyLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                createLabel.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
                emptyLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
                createLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: 0)
            ])
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "prizmSet", for: indexPath)
        cell.clearAllSubviews()
        cell.backgroundColor = Colors.background
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let prizmSetButton = PrizmSetButton(frame: CGRect(x: 20, y: 5, width: view.frame.width - 40, height: 70))
        cell.addSubview(prizmSetButton)
        
        prizmSetButton.backgroundColor = Colors.green3
        prizmSetButton.layer.cornerRadius = 16
        prizmSetButton.dropShadow()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(goToViewVC))
        prizmSetButton.addGestureRecognizer(tap)
        
        let prizmSetName = UILabel(frame: CGRect(x: 25, y: prizmSetButton.frame.height / 2 - 12.5, width: 0, height: 0))
        prizmSetButton.addSubview(prizmSetName)
        prizmSetName.text = "Unable to get PrizmSet"
        prizmSetName.font = UIFont(name: Fonts.gilmerBold, size: 25)
        prizmSetName.textColor = Colors.white
        prizmSetName.sizeToFit()
        prizmSetName.lineBreakMode = .byTruncatingTail
        prizmSetName.translatesAutoresizingMaskIntoConstraints = false
        prizmSetName.textAlignment = .left
        
        var star = UIImageView()
        
        cell.addSubview(star)
        
        var currSet = PrizmSet()
        var currSection = ""
        
        if segControl.selectedSegmentIndex == 0 {
            let section = self.flashUser.classOrder[indexPath.section]
            guard let set = FirebaseManager.shared.byClass[section]?[indexPath.row] else {
                
                prizmSetButton.prizmSet = nil
                
                return cell
            }
            currSet = set
            currSection = section
        } else if segControl.selectedSegmentIndex == 1 {
            currSection = FirebaseManager.shared.starredOrder[indexPath.section]
            guard let set = FirebaseManager.shared.starredSetsByClass[currSection]?[indexPath.row] else {
                
                prizmSetButton.prizmSet = nil
                return cell
            }
            
            currSet = set
        } else {
            currSection = FirebaseManager.shared.sharedOrder[indexPath.section]
            guard let set = FirebaseManager.shared.sharedSetsByClass[currSection]?[indexPath.row] else {
                
                prizmSetButton.prizmSet = nil
                return cell
            }
            
            currSet = set
        }
        
        prizmSetButton.prizmSet = currSet
        prizmSetName.text = currSet.prizmName
        
        if FirebaseManager.shared.starredSets.keys.contains(currSet.id) {
            star = UIImageView(image: UIImage(systemName: "star.fill"))
            star.tintColor = UIColor.yellow
        } else {
            star = UIImageView(image: UIImage(systemName: "star"))
            star.tintColor = Colors.white
        }
        
        cell.addSubview(star)
        cell.bringSubviewToFront(star)
        star.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            star.heightAnchor.constraint(equalTo: cell.heightAnchor, constant: -50),
            star.widthAnchor.constraint(equalTo: star.heightAnchor, constant: 5),
            star.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -25),
            star.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            prizmSetName.heightAnchor.constraint(equalTo: cell.heightAnchor, constant: -5),
            prizmSetName.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 40)
        ])
        
        if currSet.ownerID != self.flashUser.uid {
            let sharedIcon = UIImageView(image: UIImage(named: "shared_white"))
            cell.addSubview(sharedIcon)
            sharedIcon.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                sharedIcon.trailingAnchor.constraint(equalTo: star.leadingAnchor),
                sharedIcon.centerYAnchor.constraint(equalTo: cell.centerYAnchor, constant: 2.5),
                sharedIcon.heightAnchor.constraint(equalToConstant: 40),
                sharedIcon.widthAnchor.constraint(equalToConstant: 40),
                prizmSetName.trailingAnchor.constraint(equalTo: sharedIcon.leadingAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                prizmSetName.trailingAnchor.constraint(equalTo: star.leadingAnchor)
            ])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let section = FirebaseManager.shared.flashUser?.classOrder[indexPath.section],
              let prizmSet = FirebaseManager.shared.byClass[section]?[indexPath.row] else {
            return nil
        }
        
        if segControl.selectedSegmentIndex == 0 && FirebaseManager.shared.byClass.keys.count == 0 {
            return nil
            
        } else if segControl.selectedSegmentIndex == 1 && FirebaseManager.shared.starredSetsByClass.keys.count == 0 {
            return nil
            
        } else if segControl.selectedSegmentIndex == 2 && FirebaseManager.shared.sharedSetsByClass.keys.count == 0 {
            return nil
        }
        
//        if prizmSet.ownerID != self.flashUser.uid {
//            let alert = UIAlertController(title: "Unable to Delete", message: "You cannot delete a Prizm Set that is shared with you (not your own)", preferredStyle: .alert)
//
//            let ok = UIAlertAction(title: "OK", style: .cancel)
//            alert.addAction(ok)
//
//            self.present(alert, animated: true)
//
//            return nil
//        }
        if prizmSet.ownerID != self.flashUser.uid {
            let deleteAction = UIContextualAction(style: .normal, title: "Remove") { action, source, completion in
                FirebaseManager.shared.deletePrizm(prizmID: prizmSet.id, shared: true) { success in
                    if success {
                        print("Successful removal")
                        tableView.reloadData()
                        completion(true)
                    }
                }
            }
            
            deleteAction.backgroundColor = UIColor.red
            
            
            let swipe = UISwipeActionsConfiguration(actions: [deleteAction])
            return swipe
        } else {
            let deleteAction = UIContextualAction(style: .normal, title: "Delete") { action, source, completion in
                FirebaseManager.shared.deletePrizm(prizmID: prizmSet.id, shared: false) { success in
                    if success {
                        print("Successful deletion")
                        tableView.reloadData()
                        completion(true)
                    }
                }
            }
            
            deleteAction.backgroundColor = UIColor.red
            
            
            let swipe = UISwipeActionsConfiguration(actions: [deleteAction])
            return swipe
        }
        
    }
    
    @objc func goToViewVC(gesture: UITapGestureRecognizer) {

        guard let prizmSetButton = gesture.view as? PrizmSetButton else {
                return
        }
        
        // Check if the tap was on the star UIImageView
        let touchPoint = gesture.location(in: prizmSetButton)
        
        if touchPoint.x >= prizmSetButton.frame.width - 40 && touchPoint.y < prizmSetButton.frame.height - 20 && touchPoint.y > 20 {
            // Toggle the star icon
            if FirebaseManager.shared.starredSets.keys.contains(prizmSetButton.prizmSet?.id ?? "") {
                FirebaseManager.shared.unstarSet(prizmSet: prizmSetButton.prizmSet)
            } else {
                FirebaseManager.shared.starSet(prizmSet: prizmSetButton.prizmSet)
            }
            prizmSets.reloadData()
        } else {
            
            print("Button Pressed")
            print(prizmSetButton.prizmSet ?? "No PrizmSet saved in button")
            
            // fetching username from Firebase
            FirebaseManager.shared.fetchUsername(userID: prizmSetButton.prizmSet.ownerID, completion: {
                (retrievedUsername: String?) -> Void in
                
                guard let username = retrievedUsername else {
                    return
                }
                
                let viewVC = PrizmSetViewViewController(prizmSet: prizmSetButton.prizmSet, prizmSetUsername: username)
                self.navigationController?.pushViewController(viewVC, animated: true)
                
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpComponents()
        
        FirebaseManager.shared.fetchData(FirebaseManager.shared.currentUser) { error in
            if let error = error {
                print("Error fetching data: \(error)")
            }
            
            guard let f = FirebaseManager.shared.flashUser else {
                return
            }
            
            self.flashUser = f
            
            print("viewDidLoad")
//            self.setUpComponents()
            self.setUpTableView()
            
            print("PRINTING PRIZMSETS")
            print(FirebaseManager.shared.prizmSets)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        FirebaseManager.shared.fetchData(FirebaseManager.shared.currentUser) { error in
            if let error = error {
                print("Error fetching data: \(error)")
            }
            
            guard let f = FirebaseManager.shared.flashUser else {
                return
            }
            
            self.flashUser = f
            
            print("viewWillAppear reload data")
            
            self.prizmSets.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        FirebaseManager.shared.fetchData(FirebaseManager.shared.currentUser) { error in
            if let error = error {
                print("Error fetching data: \(error)")
            }
            
            guard let f = FirebaseManager.shared.flashUser else {
                return
            }
            
            self.flashUser = f
            
            print("viewDidAppear reload data")
            
            self.prizmSets.reloadData()
        }
    }
    
    func setUpTableView() {
        prizmSets.dataSource = self
        prizmSets.delegate = self
        
        prizmSets.register(UITableViewCell.self, forCellReuseIdentifier: "prizmSet")
    }

    func setUpComponents() {
        // Set background color
        view.backgroundColor = Colors.background
        
        // Set up title
        let prizmLabel = UILabel()
        view.addSubview(prizmLabel)
        prizmLabel.font = UIFont(name: Fonts.gilmerBold, size: 50)
        prizmLabel.text = "PrizmSets"
        prizmLabel.textColor = Colors.black
        prizmLabel.sizeToFit()
        prizmLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            prizmLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            prizmLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
        
        // Set up segmented controller
        segControl = UISegmentedControl(items: ["All", "Starred", "Shared"])
        view.addSubview(segControl)
        segControl.selectedSegmentIndex = 0
        segControl.selectedSegmentTintColor = Colors.green1
        segControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        segControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segControl.leadingAnchor.constraint(equalTo: prizmLabel.leadingAnchor),
            segControl.topAnchor.constraint(equalTo: prizmLabel.bottomAnchor, constant: 10),
            segControl.widthAnchor.constraint(equalToConstant: view.frame.width - 50),
            segControl.heightAnchor.constraint(equalToConstant: 20)
        ])
        segControl.addTarget(self, action: #selector(segmentedValueChanged(_ :)), for: .valueChanged)
        
        // Set up table
        view.addSubview(prizmSets)
        prizmSets.separatorStyle = .none
        prizmSets.translatesAutoresizingMaskIntoConstraints = false
        prizmSets.backgroundColor = Colors.background
        NSLayoutConstraint.activate([
            prizmSets.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            prizmSets.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            prizmSets.topAnchor.constraint(equalTo: segControl.bottomAnchor, constant: 10),
            prizmSets.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Set up FAB
        let floatingButton = UIButton(frame: CGRect(x: 0, y: 0, width: 77, height: 77))
        view.addSubview(floatingButton)
        view.bringSubviewToFront(floatingButton)
        floatingButton.backgroundColor = Colors.green2
        floatingButton.setTitle("+", for: .normal)
        floatingButton.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 50)
        floatingButton.layer.cornerRadius = 40
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.dropShadow()
        floatingButton.accessibilityLabel = "addFAB"
        NSLayoutConstraint.activate([
            floatingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            floatingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            floatingButton.widthAnchor.constraint(equalToConstant: 77),
            floatingButton.heightAnchor.constraint(equalToConstant: 77)
        ])
        floatingButton.addTarget(self, action: #selector(pressedFAB), for: .touchUpInside)
    }
    
    @objc func pressedFAB() {
        let creationVC = PrizmSetCreationViewController()
        self.navigationController?.pushViewController(creationVC, animated: true)
    }

    @objc func segmentedValueChanged(_ sender: UISegmentedControl) {
        prizmSets.reloadData()
    }
}

