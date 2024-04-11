//
//  PrizmSetEditViewController.swift
//  FlashPrizm
//
//  Created by Leung Wai Liu on 3/19/23.
//
import UIKit

class PrizmSetEditViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var prizms = UITableView()
    
    var prizmSet: PrizmSet!
    
    var prizmTitle = "No Title"
    var prizmDescription = "No Description"
    var prizmCategory = "No Category"
    var runningOrder: [String] = []
    
    // to convert to when uploading to firebase
    var prizmContents:[String:[String]] = [:]
    
    var prizmSetContents:[[String]] = []
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.viewWillAppear(true)
    }
    
    convenience init(prizmSet: PrizmSet!) {
        self.init()
        
        self.prizmSet = prizmSet
        self.prizmTitle = prizmSet.prizmName
        self.prizmDescription = prizmSet.description
        self.prizmCategory = prizmSet.className
        self.runningOrder = prizmSet.prizmOrder
        
        // restructuring PrizmSet data to be able to view
        prizmSetContents.append(["Title"])
        
        for termTitle in self.runningOrder {
            let newTerm = [termTitle] + (prizmSet.content[termTitle] ?? [])
            prizmSetContents.append(newTerm)
        }
        prizmSetContents.append(["Add New FlashPrizm Button"])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpNavBar()
        setUpTableView()
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

        navigationItem.title = "Edit PrizmSet"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(doneAction))
    }
    
    
    func setUpTableView() {
        prizms.delegate = self
        prizms.dataSource = self
        prizms.register(UITableViewCell.self, forCellReuseIdentifier: "prizmSetTitle")
        prizms.register(UITableViewCell.self, forCellReuseIdentifier: "addPrizm")
        prizms.register(UITableViewCell.self, forCellReuseIdentifier: "flashPrizm")
        prizms.rowHeight = 60
        
        prizms.backgroundColor = Colors.background
    }
    
    func setUpComponents() {
        view.addSubview(prizms)
        prizms.separatorStyle = .none
        prizms.translatesAutoresizingMaskIntoConstraints = false
        prizms.translatesAutoresizingMaskIntoConstraints = false
        prizms.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        prizms.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        prizms.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        prizms.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prizmSetContents.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // height for the title cell
        if(indexPath.row == 0){
            return 180
        }
        // height for the add new flashprizm cell
        else if (indexPath.row == prizmSetContents.count - 1) {
            return 60
        }
        // height for the term cell, varies based on size
        return CGFloat(70 + (prizmSetContents[indexPath.row].count - 1) * 40 + 60)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Title Cell
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "prizmSetTitle", for: indexPath)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = Colors.background
            cell.clearAllSubviews()
            cell.layer.sublayers?.removeAll()
            cell.clipsToBounds = true
            cell.contentView.clipsToBounds = true
    
            cell.accessibilityLabel = "titleCell"
            
            let intro = UIView(frame: CGRect(x: 20, y:20, width: view.frame.width - 40, height: 145))
            cell.addSubview(intro)
            intro.backgroundColor = Colors.green4;
            intro.layer.cornerRadius = 16;
            intro.clipsToBounds = true
            
            let title: UITextField = UITextField(frame: CGRect(x: 15, y: 10, width: view.frame.width - 40, height: 30.00))
            intro.addSubview(title)
            let titlePlaceHolder = NSAttributedString(string: prizmTitle, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            title.attributedPlaceholder = titlePlaceHolder
            title.textColor = UIColor.white
            title.font = UIFont(name: Fonts.garetBook, size: 25)
            //title.tag = -2
            title.delegate = self
            title.accessibilityLabel = "titleTextField"
            title.clipsToBounds = true
            
            //white line underneath title
            let introPath = UIBezierPath()
            introPath.move(to: CGPoint(x: 35, y: 60))
            introPath.addLine(to: CGPoint(x: view.frame.width-40, y: 60))
            let introShapeLayer = CAShapeLayer()
            introShapeLayer.path = introPath.cgPath
            introShapeLayer.strokeColor = UIColor.white.cgColor
            introShapeLayer.lineWidth = 3.0
            cell.layer.addSublayer(introShapeLayer)
            
            let description: UITextField = UITextField(frame: CGRect(x: 15, y: 55, width: view.frame.width - 40, height: 30.00))
            intro.addSubview(description)
            let descriptionPlaceHolder = NSAttributedString(string: prizmDescription, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            description.attributedPlaceholder = descriptionPlaceHolder
            description.textColor = UIColor.white
            description.font = UIFont(name: Fonts.garetBook, size: 18)
            description.delegate = self
            description.accessibilityLabel = "descriptionTextField"
            description.clipsToBounds = true
            
            //white line underneath description
            let descriptPath = UIBezierPath()
            descriptPath.move(to: CGPoint(x: 35, y: 100))
            descriptPath.addLine(to: CGPoint(x: view.frame.width-40, y: 100))
            let descriptShapeLayer = CAShapeLayer()
            descriptShapeLayer.path = descriptPath.cgPath
            descriptShapeLayer.strokeColor = UIColor.white.cgColor
            descriptShapeLayer.lineWidth = 3.0
            cell.layer.addSublayer(descriptShapeLayer)
            
    
            let category: UITextField = UITextField(frame: CGRect(x: 15, y: 95, width: view.frame.width - 40, height: 30.00))
            intro.addSubview(category)
            let categoryPlaceHolder = NSAttributedString(string: prizmCategory, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            category.attributedPlaceholder = categoryPlaceHolder
            category.textColor = UIColor.white
            category.font = UIFont(name: Fonts.garetBook, size: 18)
            category.delegate = self
            category.accessibilityLabel = "categoryTextField"
            category.clipsToBounds = true
            
            
            //white line underneath category
            let categoryPath = UIBezierPath()
            categoryPath.move(to: CGPoint(x: 35, y: 140))
            categoryPath.addLine(to: CGPoint(x: view.frame.width-40, y: 140))
            let categoryShapeLayer = CAShapeLayer()
            categoryShapeLayer.path = categoryPath.cgPath
            categoryShapeLayer.strokeColor = UIColor.white.cgColor
            categoryShapeLayer.lineWidth = 3.0
            cell.layer.addSublayer(categoryShapeLayer)

            
            return cell
            
        }
        
        // cell for adding new FlashPrizm
        else if(indexPath.row == prizmSetContents.count - 1){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "addPrizm", for: indexPath)
            cell.clearAllSubviews()
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.layer.sublayers?.removeAll()
            cell.clipsToBounds = true
            cell.contentView.clipsToBounds = true
           
            cell.backgroundColor = Colors.background
            cell.accessibilityLabel = "addNewFlashPrizmCell"
            
            let newPrizmView = UIView(frame: CGRect(x: 20, y:5, width: view.frame.width - 40, height: 40))
            cell.addSubview(newPrizmView)
            newPrizmView.backgroundColor = Colors.green2
            newPrizmView.layer.cornerRadius = 16;
            newPrizmView.clipsToBounds = true
            
            let addNewPrizmButton: UIButton = UIButton(frame: CGRect(x:24, y:5, width: view.frame.width - 40, height: 30.00))
            newPrizmView.addSubview(addNewPrizmButton)
            addNewPrizmButton.setTitle("+ Add new Prizm", for: .normal)
            addNewPrizmButton.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 18)
            addNewPrizmButton.addTarget(self, action: #selector(addNewPrizmAction), for: .touchUpInside)
            addNewPrizmButton.contentHorizontalAlignment = .left
            addNewPrizmButton.accessibilityLabel = "addNewFlashPrizmButton"
            
           return cell
        }
        
        // cell content for FlashPrizm itself
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "flashPrizm", for: indexPath)
            cell.clearAllSubviews()
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.layer.sublayers?.removeAll()
            cell.clipsToBounds = true
            cell.contentView.clipsToBounds = true
            cell.backgroundColor = Colors.background
            
            let prizm = UIView(frame: CGRect(x: 20, y:5, width: view.frame.width - 40, height: CGFloat(70 + (prizmSetContents[indexPath.row].count - 1) * 40) + 40))
            cell.addSubview(prizm)
            cell.accessibilityLabel = "flashPrizmCell\(indexPath.row)"
            prizm.backgroundColor = Colors.green3;
            prizm.layer.cornerRadius = 16;
            prizm.clipsToBounds = true
            
            // TERM
            let term: UITextField = UITextField(frame: CGRect(x: 15, y: 10, width: view.frame.width - 40, height: 30.00))
            prizm.addSubview(term)
            let termPlaceHolder = NSAttributedString(string: prizmSetContents[indexPath.row][0], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            term.attributedPlaceholder = termPlaceHolder
            term.textColor = UIColor.white
            term.font = UIFont(name: Fonts.garetBook, size: 25)
            //term.tag = indexPath.row
            term.delegate = self
            term.accessibilityLabel = "termForFlashPrizmCell\(indexPath.row)"
            term.clipsToBounds = true
            
            //white line underneath term
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 35, y: 45))
            path.addLine(to: CGPoint(x: view.frame.width-40, y: 45))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.white.cgColor
            shapeLayer.lineWidth = 3.0
            cell.layer.addSublayer(shapeLayer)
            
            // SIDES
            let sideCoordinateStart = 60
            for index in 1 ..< prizmSetContents[indexPath.row].count {
                
                let sideCell: UITextField = UITextField(frame: CGRect(x: 15, y: CGFloat((sideCoordinateStart + (index-1)*40)), width: view.frame.width - 40, height: 30.00))
                prizm.addSubview(sideCell)
                let sidePlaceHolder = NSAttributedString(string: prizmSetContents[indexPath.row][index], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                sideCell.attributedPlaceholder = sidePlaceHolder
                sideCell.textColor = UIColor.white
                sideCell.font = UIFont(name: Fonts.garetBook, size: 16)
                //sideCell.tag = indexPath.row * largestNumSides + (index + 1)
                sideCell.delegate = self
                sideCell.accessibilityLabel = "sideField\(index)ForFlashPrizm\(indexPath.row)"
                sideCell.clipsToBounds = true
                
                //white line underneath side1
                let sidePath = UIBezierPath()
                sidePath.move(to: CGPoint(x: 35, y: CGFloat((sideCoordinateStart + (index-1)*40) + 30)))
                sidePath.addLine(to: CGPoint(x: view.frame.width-40, y: CGFloat((sideCoordinateStart + (index-1)*40) + 30)))
                let sideShapeLayer = CAShapeLayer()
                sideShapeLayer.path = sidePath.cgPath
                sideShapeLayer.strokeColor = UIColor.white.cgColor
                sideShapeLayer.lineWidth = 3.0
                cell.layer.addSublayer(sideShapeLayer)
            }
            
            let addSideButton: UIButton = UIButton(frame: CGRect(x:30, y:CGFloat(70 + (prizmSetContents[indexPath.row].count - 1) * 40), width: view.frame.width - 40, height: 30.00))
            prizm.addSubview(addSideButton)
            addSideButton.tag = indexPath.row
            addSideButton.setTitle("+ Add new Side", for: .normal)
            addSideButton.titleLabel?.font = UIFont(name: Fonts.gilmerBold, size: 18)
            addSideButton.addTarget(self, action: #selector(addSideButtonAction), for: .touchUpInside)
            addSideButton.contentHorizontalAlignment = .left
            addSideButton.accessibilityLabel = "addSideButtonForFlashPrizmCell\(indexPath.row)"
            
            return cell
        }
        
    }
    
//    func textFieldDidChangeSelection(_ textField: UITextField) {
//        // Save the title
//        if textField.accessibilityLabel == "titleTextField" {
//            prizmTitle = textField.text ?? ""
//
//        }
//        else if textField.accessibilityLabel == "descriptionTextField" {
//            prizmDescription = textField.text ?? ""
//        }
//        else if textField.accessibilityLabel == "categoryTextField" {
//            prizmCategory = textField.text ?? ""
//        }
//        else {
//            for termsIndex in 1..<(prizmSetContents.count - 1) {
//                if textField.accessibilityLabel == "termForFlashPrizmCell\(termsIndex)" {
//                    prizmSetContents[termsIndex][0] = textField.text ?? ""
//                } else {
//                    for sidesIndex in 1..<prizmSetContents[termsIndex].count {
//                        if textField.accessibilityLabel == "sideField\(sidesIndex)ForFlashPrizm\(termsIndex)" {
//                            prizmSetContents[termsIndex][sidesIndex] = textField.text ?? ""
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // Save the title
        if textField.accessibilityLabel == "titleTextField" {
            prizmTitle = textField.text ?? ""
            
        }
        else if textField.accessibilityLabel == "descriptionTextField" {
            prizmDescription = textField.text ?? ""
        }
        else if textField.accessibilityLabel == "categoryTextField" {
            prizmCategory = textField.text ?? ""
        }
        else {
            for termsIndex in 1..<(prizmSetContents.count - 1) {
                if textField.accessibilityLabel == "termForFlashPrizmCell\(termsIndex)" {
                    var term = ""
                    if textField.text == "" {
                        term = textField.placeholder ?? ""
                    } else {
                        term = textField.text!
                    }
                    
                    prizmSetContents[termsIndex][0] = term
                    
                    let runningIndex = termsIndex - 1
                    if runningIndex >= runningOrder.count {
                        runningOrder.append(term)
                    } else {
                        runningOrder[runningIndex] = term
                    }
                } else {
                    for sidesIndex in 1..<prizmSetContents[termsIndex].count {
                        if textField.accessibilityLabel == "sideField\(sidesIndex)ForFlashPrizm\(termsIndex)" {
                            var side = ""
                            if textField.text == "" {
                                side = textField.placeholder ?? ""
                            } else {
                                side = textField.text!
                            }
                            
                            prizmSetContents[termsIndex][sidesIndex] = side
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Save the title
        if textField.accessibilityLabel == "titleTextField" {
            prizmTitle = textField.text ?? ""
            
        }
        else if textField.accessibilityLabel == "descriptionTextField" {
            prizmDescription = textField.text ?? ""
        }
        else if textField.accessibilityLabel == "categoryTextField" {
            prizmCategory = textField.text ?? ""
        }
        else {
            for termsIndex in 1..<(prizmSetContents.count - 1) {
                if textField.accessibilityLabel == "termForFlashPrizmCell\(termsIndex)" {
                    var term = ""
                    if textField.text == "" {
                        term = textField.placeholder ?? ""
                    } else {
                        term = textField.text!
                    }
                    
                    prizmSetContents[termsIndex][0] = term
                    
                    let runningIndex = termsIndex - 1
                    if runningIndex >= runningOrder.count {
                        runningOrder.append(term)
                    } else {
                        runningOrder[runningIndex] = term
                    }
                } else {
                    for sidesIndex in 1..<prizmSetContents[termsIndex].count {
                        if textField.accessibilityLabel == "sideField\(sidesIndex)ForFlashPrizm\(termsIndex)" {
                            var side = ""
                            if textField.text == "" {
                                side = textField.placeholder ?? ""
                            } else {
                                side = textField.text!
                            }
                            
                            prizmSetContents[termsIndex][sidesIndex] = side
                        }
                    }
                }
            }
        }

    }
    
    
    @objc func doneAction(sender: UIButton!) {
        self.view.endEditing(true)
        print("createButton tapped")
        print(prizmTitle)
        print(prizmDescription)
        print(prizmSetContents)
        
        // converting the prizmSetContents array to format suitable for uploading
        for termIndex in 1..<prizmSetContents.count-1 {
            let title = prizmSetContents[termIndex][0]
            var termArray:[String] = []
            for sideIndex in 1..<prizmSetContents[termIndex].count {
                termArray.append(prizmSetContents[termIndex][sideIndex])
            }
            prizmContents[title] = termArray
        }
        
        print("PRIZMCONTENTS TO UPLOAD")
        print(prizmContents)
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        // uploading to Firebase
        FirebaseManager.shared.updatePrizm(prizmID: prizmSet.id, prizmUID: prizmSet.ownerID, prizmName: prizmTitle, description: prizmDescription, className: prizmCategory, prizmDic: prizmContents, prizmOrder: runningOrder) { error in

            if let error = error {
                let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
                alert.message = error.localizedDescription
                alert.addAction(UIAlertAction(title: "ok", style: .default))
                self.present(alert,animated: true)
                return
            }
            dispatchGroup.leave()
            
        }
        dispatchGroup.notify(queue: .main) {
            // returning back to the home screen
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    @objc func settingsAction(sender: UIButton!) {
        print("settingsButton tapped")
    }
    
    @objc func addSideButtonAction(sender: UIButton!) {
        print("SideButton tapped")
        self.view.endEditing(true)
        prizmSetContents[sender.tag].append("Side \(prizmSetContents[sender.tag].count)")
        prizms.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    @objc func addNewPrizmAction(sender: UIButton!) {
        print("NewPrizmButton Tapped")
        self.view.endEditing(true)
        prizmSetContents.insert(["Term \(prizmSetContents.count - 1)", "Side 1"], at: prizmSetContents.count - 1)
        print("PRINTING PRIZMSETCONTENTS")
        print(prizmSetContents)
    
        prizms.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
}

