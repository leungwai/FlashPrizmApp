//
//  SearchViewController.swift
//  FlashPrizm
//
//  Created by Leung Wai Liu on 4/25/23.
//

import Foundation
import UIKit

class SearchPrizmSetButton: UIButton {
    var prizmSet: PrizmSet!
}

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    let searchBar = UISearchBar()
    let searchResultsView = UITableView()
    var taskForSearching: DispatchWorkItem?
    
    var searchResults:[PrizmSet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpComponents()
        setUpTableData()
    }
    
    func setUpComponents() {
        // Set background color
        view.backgroundColor = Colors.background
        
        // Set up title
        let prizmLabel = UILabel()
        view.addSubview(prizmLabel)
        prizmLabel.font = UIFont(name: Fonts.gilmerBold, size: 50)
        prizmLabel.text = "Search"
        prizmLabel.textColor = Colors.black
        prizmLabel.sizeToFit()
        prizmLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            prizmLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            prizmLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
        
        // Set up search bar
        view.addSubview(searchBar)
        searchBar.delegate = self
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.heightAnchor.constraint(equalToConstant: 50).isActive = true
        searchBar.topAnchor.constraint(equalTo: prizmLabel.bottomAnchor, constant: 10).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10).isActive = true
        
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
        view.addSubview(searchResultsView)
        searchResultsView.backgroundColor = Colors.background
        searchResultsView.translatesAutoresizingMaskIntoConstraints = false
        
        searchResultsView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10).isActive = true
        searchResultsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        searchResultsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        searchResultsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        
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
    
    func setUpTableData() {
        searchResultsView.separatorStyle = .none
        searchResultsView.delegate = self
        searchResultsView.dataSource = self
        
        searchResultsView.register(UITableViewCell.self, forCellReuseIdentifier: "resultCell")
        
        searchResultsView.register(UITableViewCell.self, forCellReuseIdentifier: "noMoreResultCell")
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == searchResults.count {
            return 70
        }
        return 230
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == searchResults.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noMoreResultCell", for: indexPath)
            
            cell.backgroundColor = Colors.background
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.clearAllSubviews()
            
            let dotsLabel = UILabel()
            dotsLabel.translatesAutoresizingMaskIntoConstraints = false
            
            dotsLabel.textColor = UIColor.black
            dotsLabel.font = UIFont(name: Fonts.garetBook, size: 20)
            dotsLabel.text = "..."
            dotsLabel.textAlignment = .center
            
            let noMoreResultLabel = UILabel()
            noMoreResultLabel.translatesAutoresizingMaskIntoConstraints = false
            
            noMoreResultLabel.textColor = UIColor.black
            noMoreResultLabel.font = UIFont(name: Fonts.garetBook, size: 20)
            
            if searchResults.count == 0 {
                noMoreResultLabel.text = "No Results"
            }
            else {
                noMoreResultLabel.text = "No More Results"
            }
            
            noMoreResultLabel.textAlignment = .center
            
            // Vertical Stack for the UILabels
            let textStack = UIStackView(arrangedSubviews: [dotsLabel, noMoreResultLabel])
            cell.addSubview(textStack)
            
            textStack.translatesAutoresizingMaskIntoConstraints = false
            textStack.topAnchor.constraint(equalTo: cell.topAnchor, constant: 0).isActive = true
            textStack.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -20).isActive = true
            textStack.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 0).isActive = true
            textStack.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 0).isActive = true
            
            textStack.axis = .vertical
            textStack.distribution = .fillEqually
            textStack.spacing = 10
            
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath)
            
            cell.backgroundColor = Colors.background
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            cell.clearAllSubviews()
            
            let cellView = UIView(frame: CGRect(x: 20, y:0, width: searchResultsView.frame.width-40, height: 210))
            cell.addSubview(cellView)
            cellView.backgroundColor = Colors.green2
            cellView.layer.cornerRadius = 15
            
            // shadow
            cellView.layer.shadowColor = UIColor.gray.cgColor
            cellView.layer.shadowOpacity = 1
            cellView.layer.shadowOffset = CGSize(width: 0, height: 5)
            
            
            // prizmSetTitle
            let prizmSetTitle = UILabel(frame: CGRect(x: 20, y: 10, width: cellView.frame.width - 30, height: 30))
            cellView.addSubview(prizmSetTitle)
            prizmSetTitle.textColor = UIColor.white
            prizmSetTitle.font = UIFont(name: Fonts.gilmerBold, size: 20)
            prizmSetTitle.text = searchResults[indexPath.row].prizmName
            
            //white line underneath title
            let introPath = UIBezierPath()
            introPath.move(to: CGPoint(x: 20, y: 40))
            introPath.addLine(to: CGPoint(x: cellView.frame.width, y: 40))
            let introShapeLayer = CAShapeLayer()
            introShapeLayer.path = introPath.cgPath
            introShapeLayer.strokeColor = UIColor.white.cgColor
            introShapeLayer.lineWidth = 2.0
            cellView.layer.addSublayer(introShapeLayer)
            
            let termView = UIView(frame: CGRect(x: 20, y:50, width: cellView.frame.width - 40, height: 100))
            cellView.addSubview(termView)
            termView.backgroundColor = Colors.lightGray
            termView.layer.cornerRadius = 15
            termView.dropShadow()
            
            // shadow
            termView.layer.shadowColor = UIColor.black.cgColor
            termView.layer.shadowOpacity = 0.25
            termView.layer.shadowOffset = CGSize(width: 0, height: 5)
            
            // term title
            let prizmTermTitle = UILabel(frame: CGRect(x: 15, y: 10, width: termView.frame.width - 30, height: 20))
            termView.addSubview(prizmTermTitle)
            prizmTermTitle.textColor = UIColor.black
            prizmTermTitle.font = UIFont(name: Fonts.garetBook, size: 15)
            prizmTermTitle.text = searchResults[indexPath.row].content.first?.key
            
            //white line underneath title
            let termPath = UIBezierPath()
            termPath.move(to: CGPoint(x: 15, y: 35))
            termPath.addLine(to: CGPoint(x: termView.frame.width, y: 35))
            let termShapeLayer = CAShapeLayer()
            termShapeLayer.path = termPath.cgPath
            termShapeLayer.strokeColor = UIColor.gray.cgColor
            termShapeLayer.lineWidth = 1.0
            termView.layer.addSublayer(termShapeLayer)
            
            let triangle = UIImageView(frame: CGRect(x: 10, y: 50, width: 25, height: 25))
            termView.addSubview(triangle)
            triangle.image = UIImage(named: "rotatedtriangle")
            
            // side title
            let termDetail = UILabel()
            termView.addSubview(termDetail)
            //UILabel(frame: CGRect(x: 40, y: 40, width: termView.frame.width - 55, height: 55))
            
            termDetail.translatesAutoresizingMaskIntoConstraints = false
            termDetail.leadingAnchor.constraint(equalTo: termView.leadingAnchor, constant: 35).isActive = true
            termDetail.trailingAnchor.constraint(equalTo: termView.trailingAnchor, constant: -15).isActive = true
            termDetail.topAnchor.constraint(equalTo: termView.topAnchor, constant: 40).isActive = true
            termDetail.heightAnchor.constraint(lessThanOrEqualToConstant: 55).isActive = true
            
            termDetail.numberOfLines = 0
            termDetail.textColor = UIColor.black
            termDetail.font = UIFont(name: Fonts.garetBook, size: 15)
            termDetail.text = searchResults[indexPath.row].content.first?.value[0] as? String
            termDetail.sizeToFit()
            
            // View PrizmSet Button
            let viewPrizmSetButton = SearchPrizmSetButton(frame: CGRect(x: cellView.frame.width - 220, y: 160, width: 200, height: 40))
            cellView.addSubview(viewPrizmSetButton)
            
            viewPrizmSetButton.prizmSet = searchResults[indexPath.row]
            
            viewPrizmSetButton.backgroundColor = Colors.green1
            viewPrizmSetButton.layer.cornerRadius = 15
            viewPrizmSetButton.addTarget(self, action: #selector(goToPrizmSet), for: .touchUpInside)
            
            // shadow
            viewPrizmSetButton.layer.shadowColor = UIColor.black.cgColor
            viewPrizmSetButton.layer.shadowOpacity = 0.25
            viewPrizmSetButton.layer.shadowOffset = CGSize(width: 0, height: 5)
            
            // viewPrizmSetButton Title
            let buttonTitle = UILabel(frame: CGRect(x: 10, y: 0, width: 150, height: 40))
            viewPrizmSetButton.addSubview(buttonTitle)
            buttonTitle.textColor = UIColor.white
            buttonTitle.font = UIFont(name: Fonts.gilmerBold, size: 15)
            buttonTitle.text = "View this PrizmSet"
            buttonTitle.textAlignment = .center
            
            let invertedColor = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
            
            // button arrow
            let arrow = UIImageView(frame: CGRect(x: viewPrizmSetButton.frame.width - 40, y: 10, width: 30, height: 20))
            viewPrizmSetButton.addSubview(arrow)
            arrow.image =  UIImage(systemName: "arrow.right", withConfiguration: invertedColor)?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
            
            return cell
        }
    }
    
    // SEARCH BAR SETUP
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print("SEARCH BAR TEXT DID BEGIN EDITING")
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print("SEARCH BAR CANCEL BUTTON CLICKED")
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("QUERYING FOR PRIZMSETS WITH QUERY: \(searchText)")
        queryPrizmSets(queryValue: searchText)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print("SEARCH BAR TEXT DID END EDITING")
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    
    func retrieveData(queryValue: String, dispatchGroup: DispatchGroup) {
        self.searchResults.removeAll()
        
        FirebaseManager.shared.queryPrizms(queryValue: queryValue) { incomingPrizmSets, error in
            
            guard incomingPrizmSets != nil else {
                print("No search results")
                return
            }
            
            self.searchResults = incomingPrizmSets ?? []
                
            print("GOT THE STUFF IN SEARCH VC")
            print(self.searchResults)
            print("ENTERING MAIN ASYNC?")
            dispatchGroup.leave()
        }
        
    }
    
    func queryPrizmSets(queryValue: String) {
        if queryValue != "" {
            taskForSearching?.cancel()
            
            let task = DispatchWorkItem {
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                
                self.retrieveData(queryValue: queryValue, dispatchGroup: dispatchGroup)
                
                dispatchGroup.notify(queue: .main) {
                    print("DONE SEARCHING, IN DISPATCH ASYNC")
                    print(self.searchResults)
                    print("DONE SEARCHING FOR QUERY \(queryValue), reloading data")
                    self.searchResultsView.reloadData()
                }
            }
            
            
            self.taskForSearching = task
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75, execute: task)
        }
    }
    
    @objc func goToPrizmSet(sender: PrizmSetButton) {
        print("Button Pressed")
        print(sender.prizmSet ?? "No PrizmSet saved in button")
        
        // fetching username from Firebase
        FirebaseManager.shared.fetchUsername(userID: sender.prizmSet.ownerID, completion: {
            (retrievedUsername: String?) -> Void in
            
            guard let username = retrievedUsername else {
                return
            }
            
            let viewVC = PrizmSetViewViewController(prizmSet: sender.prizmSet, prizmSetUsername: username)
            self.navigationController?.pushViewController(viewVC, animated: true)
            
        })
        
    }
}

