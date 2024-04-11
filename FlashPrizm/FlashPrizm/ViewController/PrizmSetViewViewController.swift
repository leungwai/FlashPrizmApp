//
//  PrizmSetViewViewController.swift
//  FlashPrizm
//
//  Created by Leung Wai Liu on 3/19/23.
//

import Foundation
import UIKit


class PrizmSetViewViewController: UIViewController {
    
    var prizmSet: PrizmSet!
    
    var currentTerm:Int = 0
    
    var prizmSetUsername:String!
    
    var prizmTermTitles: [String] = []
    var prizmTermSides:[[String]] = []
    var prizmTermProgresses:[Int] = []
    var prizmOrder: [String] = []
    
    // UI elements
    let progressBar = UIProgressView()
    let progressTopText = UILabel()
    let progressText = UILabel()
    let sideView = UILabel()
    
    
    convenience init(prizmSet: PrizmSet!, prizmSetUsername: String) {
        self.init()
        self.prizmSet = prizmSet
        self.prizmSetUsername = prizmSetUsername
        self.prizmOrder = prizmSet.prizmOrder
        // adding all the prizmTerm titles and sides in separate arrays
        for termTitle in self.prizmOrder {
            prizmTermTitles.append(termTitle)
            prizmTermSides.append(prizmSet.content[termTitle] ?? [])
            prizmTermProgresses.append(-1)
        }
        print(prizmTermSides)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensuring that the data is present
        print("INSIDE VIEW VC")
        print(prizmSet ?? "No prizmSet found")
        
        // setting the background color of the view
        view.backgroundColor = Colors.background
        
        // initializing the nav bar
        setUpNavBar()
        
        // initalizing the components of the header bar
        setUpComponents()
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

        navigationItem.title = "View PrizmSet"
        
        if prizmSet.ownerID == FirebaseManager.shared.currentUser!.uid {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editAction))
        }
        
        
    }
    
    @objc func editAction() {
        print("Edit button pressed")
        
        let editVC = PrizmSetEditViewController(prizmSet: self.prizmSet)
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    func setUpComponents() {
        
        // HEADER BAR
        
        // header bar boundaries
        let headerBarView = UIView()
        view.addSubview(headerBarView)
        
        headerBarView.translatesAutoresizingMaskIntoConstraints = false
        //headerBarView.heightAnchor.constraint(equalToConstant: 165).isActive = true
        headerBarView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 5).isActive = true
        headerBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        headerBarView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        headerBarView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        // category that PrizmSet belongs in
        let categoryName = UILabel()
        headerBarView.addSubview(categoryName)
        categoryName.font = UIFont(name: Fonts.gilmerBold, size: 18)
        categoryName.text = prizmSet.className
        categoryName.sizeToFit()
        
        categoryName.translatesAutoresizingMaskIntoConstraints = false
        categoryName.topAnchor.constraint(equalTo: headerBarView.topAnchor, constant: 25).isActive = true
        
        let prizmSetName = UILabel()
        headerBarView.addSubview(prizmSetName)
        prizmSetName.font = UIFont(name: Fonts.gilmerBold, size: 35)
        prizmSetName.text = prizmSet.prizmName
        prizmSetName.sizeToFit()
        
        prizmSetName.translatesAutoresizingMaskIntoConstraints = false
        prizmSetName.topAnchor.constraint(equalTo: categoryName.bottomAnchor, constant: 10).isActive = true
        
        // additionalInfo view that holds who it is created by and the share button
        let additionalInfo = UIView()
        headerBarView.addSubview(additionalInfo)
        //additionalInfo.backgroundColor = UIColor.green
        
        additionalInfo.translatesAutoresizingMaskIntoConstraints = false

        //additionalInfo.heightAnchor.constraint(equalToConstant: 35).isActive = true
        additionalInfo.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.height / 10) - 20).isActive = true
        

        additionalInfo.leadingAnchor.constraint(equalTo: headerBarView.leadingAnchor, constant: 0).isActive = true
        additionalInfo.trailingAnchor.constraint(equalTo: headerBarView.trailingAnchor, constant: 0).isActive = true
        additionalInfo.topAnchor.constraint(equalTo: prizmSetName.bottomAnchor, constant: 15).isActive = true
        
        
        // creatorInfoView for the creatorview boxes
        let creatorInfoView = UIView()
        additionalInfo.addSubview(creatorInfoView)
        
        //creatorInfoView.backgroundColor = UIColor.orange
        
        creatorInfoView.translatesAutoresizingMaskIntoConstraints = false
        creatorInfoView.topAnchor.constraint(equalTo: additionalInfo.topAnchor, constant: 0).isActive = true
        creatorInfoView.bottomAnchor.constraint(equalTo: additionalInfo.bottomAnchor, constant: 0).isActive = true
        creatorInfoView.leadingAnchor.constraint(equalTo: additionalInfo.leadingAnchor, constant: 0).isActive = true
        creatorInfoView.widthAnchor.constraint(equalToConstant: 200).isActive = true

        
        let createdByHeading = UILabel()
        creatorInfoView.addSubview(createdByHeading)
        createdByHeading.font = UIFont(name: Fonts.gilmerBold, size: 15)
        createdByHeading.text = "Created by:"
        createdByHeading.sizeToFit()
        
        createdByHeading.translatesAutoresizingMaskIntoConstraints = false
        createdByHeading.topAnchor.constraint(equalTo: creatorInfoView.topAnchor, constant: 0).isActive = true
        
        let creatorName = UILabel()
        creatorInfoView.addSubview(creatorName)
        creatorName.font = UIFont(name: Fonts.garetBook, size: 15)
        creatorName.text = self.prizmSetUsername
        creatorName.sizeToFit()
        
        creatorName.translatesAutoresizingMaskIntoConstraints = false
        creatorName.topAnchor.constraint(equalTo: createdByHeading.bottomAnchor, constant: 3).isActive = true
        creatorName.leadingAnchor.constraint(equalTo: creatorInfoView.leadingAnchor, constant: 0).isActive = true
        creatorName.trailingAnchor.constraint(equalTo: creatorInfoView.trailingAnchor, constant: 0).isActive = true
        
        if prizmSet.ownerID == FirebaseManager.shared.currentUser!.uid {
            let shareButton = UIButton()
            additionalInfo.addSubview(shareButton)
            
            shareButton.translatesAutoresizingMaskIntoConstraints = false
            shareButton.heightAnchor.constraint(equalToConstant: categoryName.frame.height * 1.5).isActive = true
            shareButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            shareButton.trailingAnchor.constraint(equalTo: additionalInfo.trailingAnchor, constant: 0).isActive = true
            //shareButton.bottomAnchor.constraint(equalTo: additionalInfo.bottomAnchor, constant: 0).isActive = true
            
            additionalInfo.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - shareButton.frame.width - 20).isActive = true
            //additionalInfo.layer.borderWidth = 5
            //additionalInfo.layer.borderColor = CGColor(gray: 20, alpha: 10)
            
            shareButton.backgroundColor = Colors.green3
            shareButton.layer.cornerRadius = 15
            shareButton.setTitle("Share", for: .normal)
            shareButton.titleLabel?.textColor = UIColor.white
            shareButton.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 12)
            shareButton.addTarget(self, action: #selector(shareAction), for: .touchUpInside)
        }
        
    
        //white line underneath title
        let headerBarBoundary = UIView()
        headerBarView.addSubview(headerBarBoundary)
        
        headerBarBoundary.translatesAutoresizingMaskIntoConstraints = false
        headerBarBoundary.heightAnchor.constraint(equalToConstant: 3).isActive = true
        //headerBarBoundary.bottomAnchor.constraint(equalTo: headerBarView.bottomAnchor, constant: 0).isActive = true
        //headerBarBoundary.leadingAnchor.constraint(equalTo: headerBarView.leadingAnchor, constant: 0).isActive = true
        //headerBarBoundary.trailingAnchor.constraint(equalTo: headerBarView.trailingAnchor, constant: 0).isActive = true
        headerBarBoundary.bottomAnchor.constraint(equalTo: additionalInfo.bottomAnchor, constant: 0).isActive = true
        headerBarBoundary.leadingAnchor.constraint(equalTo: additionalInfo.leadingAnchor, constant: 0).isActive = true
        headerBarBoundary.trailingAnchor.constraint(equalTo: additionalInfo.trailingAnchor, constant: 0).isActive = true
        
        headerBarBoundary.backgroundColor = UIColor.black
        headerBarBoundary.layer.cornerRadius = 1.5
        
        // PROGRESS TEXT WITHIN PRIZM
        view.addSubview(progressTopText)
        
        progressTopText.translatesAutoresizingMaskIntoConstraints = false
        progressTopText.font = UIFont(name: Fonts.garetBook, size: 20)
        progressTopText.text = "\(prizmTermProgresses[currentTerm] + 1) / \(prizmTermSides[currentTerm].count)"
        progressTopText.textAlignment = .center
        progressTopText.sizeToFit()
        
        progressTopText.translatesAutoresizingMaskIntoConstraints = false
        progressTopText.heightAnchor.constraint(equalToConstant: 15).isActive = true
        progressTopText.topAnchor.constraint(equalTo: headerBarBoundary.bottomAnchor, constant: 20).isActive = true
        progressTopText.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        progressTopText.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        
        
        // PROGRESS BAR
        view.addSubview(progressBar)
        
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.heightAnchor.constraint(equalToConstant: 15).isActive = true
        progressBar.topAnchor.constraint(equalTo: progressTopText.bottomAnchor, constant: 10).isActive = true
        progressBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        progressBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        progressBar.layer.cornerRadius = 7.5
        progressBar.clipsToBounds = true
        progressBar.trackTintColor = Colors.lightGray
        progressBar.progressTintColor = Colors.green2
        progressBar.setProgress(Float(prizmTermProgresses[currentTerm] + 1)/Float(prizmTermSides[currentTerm].count), animated: false)
        
        // PREVIOUS SIDE BUTTON
        let previousSideButton = UIButton()
        view.addSubview(previousSideButton)
        
        previousSideButton.translatesAutoresizingMaskIntoConstraints = false
        previousSideButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        previousSideButton.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 20).isActive = true
        previousSideButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        previousSideButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        previousSideButton.backgroundColor = Colors.background
        previousSideButton.layer.cornerRadius = 10
        previousSideButton.addTarget(self, action: #selector(previousSideAction), for: .touchUpInside)
        
        let upDownInvertedColor = UIImage.SymbolConfiguration(pointSize: 28, weight: .bold)
        
        let upArrowImage = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: upDownInvertedColor)?.withTintColor(Colors.green3!, renderingMode: .alwaysOriginal)
        previousSideButton.setImage(upArrowImage, for: .normal)
        
        
        // INDEX CARD VIEW
        view.addSubview(sideView)
        
        sideView.translatesAutoresizingMaskIntoConstraints = false
        //sideView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        sideView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 5 + 20).isActive = true
        sideView.topAnchor.constraint(equalTo: previousSideButton.bottomAnchor, constant: 5).isActive = true
        sideView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        sideView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        updateSideView()
        
        // NEXT SIDE BUTTON
        let nextSideButton = UIButton()
        view.addSubview(nextSideButton)
        
        nextSideButton.translatesAutoresizingMaskIntoConstraints = false
        nextSideButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        nextSideButton.topAnchor.constraint(equalTo: sideView.bottomAnchor, constant: 5).isActive = true
        nextSideButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        nextSideButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        nextSideButton.backgroundColor = Colors.background
        nextSideButton.layer.cornerRadius = 10
        nextSideButton.addTarget(self, action: #selector(nextSideAction), for: .touchUpInside)
        
        let downArrowImage = UIImage(systemName: "arrow.down.circle.fill", withConfiguration: upDownInvertedColor)?.withTintColor(Colors.green3!, renderingMode: .alwaysOriginal)
        nextSideButton.setImage(downArrowImage, for: .normal)
        
        // PREVIOUS TERM BUTTON
        let previousTermButton = UIButton()
        
        previousTermButton.translatesAutoresizingMaskIntoConstraints = false
        
        previousTermButton.backgroundColor = Colors.green3
        previousTermButton.layer.cornerRadius = 10
        previousTermButton.addTarget(self, action: #selector(previousTermAction), for: .touchUpInside)
        
        let leftRightInvertedColor = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        
        let leftArrowImage = UIImage(systemName: "arrowshape.turn.up.backward.circle.fill", withConfiguration: leftRightInvertedColor)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        previousTermButton.setImage(leftArrowImage, for: .normal)
        previousTermButton.setTitle("  Prev", for: .normal)
        previousTermButton.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 15)
        
        // PROGRESS TEXT WITHIN PRIZM SET
        progressText.translatesAutoresizingMaskIntoConstraints = false
        progressText.font = UIFont(name: Fonts.garetBook, size: 20)
        progressText.text = "\(currentTerm + 1) / \(prizmTermTitles.count)"
        progressText.textAlignment = .center
        progressText.sizeToFit()
        
        // NEXT TERM BUTTON
        let nextTermButton = UIButton()
        
        nextTermButton.translatesAutoresizingMaskIntoConstraints = false
        
        nextTermButton.backgroundColor = Colors.green3
        nextTermButton.layer.cornerRadius = 10
        
        let rightArrowImage = UIImage(systemName: "arrowshape.turn.up.right.circle.fill", withConfiguration: leftRightInvertedColor)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        nextTermButton.setImage(rightArrowImage, for: .normal)
        nextTermButton.setTitle("  Next", for: .normal)
        nextTermButton.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 15)
        nextTermButton.addTarget(self, action: #selector(nextTermAction), for: .touchUpInside)
        
        // HORIZONTAL STACK VIEW TO HOLD THE BUTTONS
        let termStack = UIStackView(arrangedSubviews: [previousTermButton, progressText, nextTermButton])
        view.addSubview(termStack)
        
        termStack.translatesAutoresizingMaskIntoConstraints = false
        termStack.heightAnchor.constraint(equalToConstant: 40).isActive = true
        termStack.topAnchor.constraint(equalTo: nextSideButton.bottomAnchor, constant: 15).isActive = true
        termStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        termStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        //termStack.trailingAnchor.constraint(equalTo: tabBarController.tabBar.topAnchor, constant: -20).isActive = true
        
        termStack.axis = .horizontal
        termStack.distribution = .fillEqually
        termStack.spacing = 10
 
    }
    
    func updateSideView() {
        let currentSide = prizmTermProgresses[currentTerm]
        
        if currentSide == -1 {
            sideView.backgroundColor = Colors.green2
            sideView.font = UIFont(name: Fonts.gilmerBold, size: 25)
            sideView.text = prizmTermTitles[currentTerm]
            sideView.textColor = UIColor.white
        } else {
            sideView.backgroundColor = Colors.lightGray
            sideView.font = UIFont(name: Fonts.garetBook, size: 20)
            sideView.text = prizmTermSides[currentTerm][currentSide]
            sideView.textColor = Colors.green4
        }
        
        sideView.textAlignment = .center
        sideView.layer.cornerRadius = 20
        sideView.clipsToBounds = true
        
    }
    
    @objc func previousSideAction() {
        let currentSide = prizmTermProgresses[currentTerm]
        
        if currentSide > -1 {
            prizmTermProgresses[currentTerm] -= 1
            
            updateSideView()
            progressBar.setProgress(Float(prizmTermProgresses[currentTerm] + 1)/Float(prizmTermSides[currentTerm].count), animated: true)
            progressTopText.text = "\(prizmTermProgresses[currentTerm] + 1) / \(prizmTermSides[currentTerm].count)"
        }
        
    }
    
    @objc func nextSideAction() {
        let currentSide = prizmTermProgresses[currentTerm]
        
        if currentSide < prizmTermSides[currentTerm].count - 1 {
            prizmTermProgresses[currentTerm] += 1
            
            updateSideView()
            progressBar.setProgress(Float(prizmTermProgresses[currentTerm] + 1)/Float(prizmTermSides[currentTerm].count), animated: true)
            progressTopText.text = "\(prizmTermProgresses[currentTerm] + 1) / \(prizmTermSides[currentTerm].count)"
        }
        
    }
    
    @objc func previousTermAction() {
        if currentTerm > 0 {
            currentTerm -= 1
            
            updateSideView()
            progressBar.setProgress(Float(prizmTermProgresses[currentTerm] + 1)/Float(prizmTermSides[currentTerm].count), animated: false)
            progressText.text = "\(currentTerm + 1) / \(prizmTermTitles.count)"
            progressTopText.text = "\(prizmTermProgresses[currentTerm] + 1) / \(prizmTermSides[currentTerm].count)"
        }
        
    }
    
    @objc func nextTermAction() {
        if currentTerm < prizmTermTitles.count - 1 {
            currentTerm += 1
            
            updateSideView()
            progressBar.setProgress(Float(prizmTermProgresses[currentTerm] + 1)/Float(prizmTermSides[currentTerm].count), animated: false)
            progressText.text = "\(currentTerm + 1) / \(prizmTermTitles.count)"
            progressTopText.text = "\(prizmTermProgresses[currentTerm] + 1) / \(prizmTermSides[currentTerm].count)"
        }
        
        
    }
    
    @objc func shareAction() {
        print("Share button pressed")
        let shareVC = PrizmSetShareViewController(prizmSet: self.prizmSet)
        self.navigationController?.pushViewController(shareVC, animated: true)
    }

    
    func setUpFlashPrizmView() {
        
    }
    
    
}

