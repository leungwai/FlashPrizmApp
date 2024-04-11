//
//  FirebaseManager.swift
//  FlashPrizm
//
//  Created by HowardWu on 2/10/23.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestoreSwift
import SwiftUI

class FirebaseManager {
    static let shared = FirebaseManager()
    private init() {}
    
    var db: Firestore!
    var storageRef: StorageReference!
    var currentUser: User?
    var prizmSets: [String: PrizmSet] = [:]
    var prizmIds = [String]()
    var flashUser: FlashUser?
    var byClass: [String : [PrizmSet]] = [:]
    var sharedSets: [String: PrizmSet] = [:]
    var sharedSetsByClass: [String: [PrizmSet]] = [:]
    var sharedOrder: [String] = []
    var starredSets: [String: PrizmSet] = [:]
    var starredSetsByClass: [String: [PrizmSet]] = [:]
    var starredOrder: [String] = []
    
    func configure() {
        db = Firestore.firestore()
        storageRef = Storage.storage().reference()
    }
    
    func setCurrentUser(user: User) {
        self.currentUser = user
    }
    
    /// signUp(): Backend function to take in user inputted information to register into Firebase. If failed, user will be notifed.
    func signUp(email: String, password: String, username: String, phoneNumber: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                completion(error)
                return
            }
            
            
            guard let user = result?.user else { return }
            let data: [String: Any] = [
                "email": email,
                "username": username,
                "phoneNumber": phoneNumber,
                "prizmSets": [] as [String],
                "followers": [] as [String],
                "following": [] as [String],
                "invites": [] as [String],
                "classOrder": [] as [String],
                "uid": user.uid
            ]
            
            self.db.collection("users").document(user.uid).setData(data, completion: { (error) in
                if let error = error {
                    completion(error)
                }
            })
            
            user.getIDToken { token, error in
                guard error == nil else {
                    completion(error)
                    return
                }
                UserDefaults.standard.set(token, forKey: "user_token")
                self.setCurrentUser(user: user)
                self.fetchUser { data, e in
                    guard let data = data, e == nil else {
                        completion(e)
                        return
                    }
                    self.flashUser = data
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTBC = storyboard.instantiateViewController(withIdentifier: Storyboard.mainTBC)
                    
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTBC)
                }
            }
            
        }
    }
    
    /// logIn(): Backend function to take in user inputted information to authenticate to LogIn. If failed, user will be notified.
    func logIn(email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            guard let user = result?.user else {
                print("User doesn't exist")
                completion(error)
                return
            }
            user.getIDToken { token, error in
                guard error == nil else {
                    completion(error)
                    return
                }
                UserDefaults.standard.set(token, forKey: "user_token")
                self.setCurrentUser(user: user)
                self.fetchUser { data, e in
                    guard let data = data, e == nil else {
                        completion(e)
                        return
                    }
                    self.flashUser = data
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTBC = storyboard.instantiateViewController(withIdentifier: Storyboard.mainTBC)
                    
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTBC)
                }
            }
        }
    }
    
    func logOut() {
        do {
            try Auth.auth().signOut()
        } catch (let e) {
            print(e)
        }
        currentUser = nil
        prizmSets = [:]
        prizmIds = []
        flashUser = nil
        byClass = [:]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginNC = storyboard.instantiateViewController(withIdentifier: Storyboard.loginNC)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNC)
    }
    
    func reauthenticate(password: String, completion: @escaping (Error?) -> Void) {
        let credential = EmailAuthProvider.credential(withEmail: flashUser?.email ?? "undefined", password: password)
        
        Auth.auth().currentUser?.reauthenticate(with: credential) { (result, error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func updateUser(updateField: updateType, newValue: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            // user is not logged in
            let error = MyError.notLoggedIn
            completion(error)
            return
        }
        
        switch updateField {
        case .email:
            user.updateEmail(to: newValue) { (error) in
                if let error = error {
                    completion(error)
                    return
                }
                self.flashUser?.email = newValue
                self.db.collection("users").document(user.uid).updateData(["email": newValue])
                completion(nil)
            }
        case .username:
            self.db.collection("users").document(user.uid).updateData(["username": newValue], completion: { (error) in
                if let error = error {
                    completion(error)
                    return
                }
                self.flashUser?.username = newValue
                completion(nil)
            })
        case .phoneNumber:
            self.db.collection("users").document(user.uid).updateData(["phoneNumber": newValue], completion: { (error) in
                if let error = error {
                    completion(error)
                    return
                }
                self.flashUser?.phoneNumber = newValue
                completion(nil)
            })
        case .deleteUser:
            self.db.collection("users").document(user.uid).delete(completion: { (error) in
                if let error = error {
                    completion(error)
                    return
                }
                user.delete { (error) in
                    if let error = error {
                        completion(error)
                        return
                    }
                }
                self.logOut()
            })
            
        default:
            resetPassword(email: currentUser!.email!, completion: { error in
                completion(error)
                return
            })
        }
    }
    
    /// fetchDataGotoHome(): Fetches the user's data then transitions to the Home Page (made due to some errors in AppDelegate)
    func fetchDataGotoHome(_ u: User? = nil, completion: @escaping (Error?) -> Void) {
        self.fetchUser(u) { data, e in
            guard let data = data, e == nil else {
                completion(e)
                return
            }
            self.flashUser = data
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mainTBC = storyboard.instantiateViewController(withIdentifier: Storyboard.mainTBC)
            
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTBC)
            completion(nil)
        }
    }
    
    /// fetchData(): Fetches user data and stores it locally
    func fetchData(_ u: User? = nil, completion: @escaping (Error?) -> Void) {
        self.fetchUser(u) { data, e in
            guard let data = data, e == nil else {
                completion(e)
                return
            }
            self.flashUser = data
            self.getSharedSets()
            self.organizeSharedSetsByClass()
            self.getStarredSets()
            self.organizeStarredSetsByClass()
            completion(nil)
        }
    }
    
    /// resetPassword(): Function that changes the password of the user.
    func resetPassword(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }
    
    /// fetchUser(): Function that parses the Firebase data into a user
    func fetchUser(_ u: User? = nil, completion: @escaping (FlashUser?, Error?) -> Void) {
        if let u = u {
            self.setCurrentUser(user: u)
        }
        guard let user = currentUser else {
            print("Unable to get user")
            completion(nil, NSError(domain: "FirebaseManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]))
            return
        }
        self.db.collection("users").document(user.uid).getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, let userData = snapshot.data() else {
                completion(nil, error ?? NSError(domain: "FirebaseManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            let flashUser = FlashUser(data: userData)
            self.prizmIds = flashUser.prizmSets
            self.fetchPrizms(prizmIds: self.prizmIds) { prizmSets, error in
                guard let prizmSets = prizmSets, error == nil else {
                    completion(nil, error)
                    return
                }
                for prizmSet in prizmSets {
                    self.prizmSets[prizmSet.id] = prizmSet
                }
                completion(flashUser, nil)
            }
        }
    }
    
    /// fetchPrizms(): Function that gets the users PrizmSets from Firebase and caches them
    func fetchPrizms(prizmIds: [String], completion: @escaping ([PrizmSet]?, Error?) -> Void) {
        var sets = [PrizmSet]()
        let dispatchGroup = DispatchGroup()
        
        for prizmSet in prizmIds {
            dispatchGroup.enter()
            self.db.collection("prizm_sets").document(prizmSet).getDocument { snapshot, error in
                
                print("Getting prizmset \(prizmSet)")
                guard let snapshot = snapshot, snapshot.exists, let prizmData = snapshot.data() else {
                    dispatchGroup.leave()
                    completion(nil, error ?? NSError(domain: "FirebaseManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "Unable to get PrizmSet"]))
                    return
                }
                let prizmSet = PrizmSet(data: prizmData)
                sets.append(prizmSet)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Done Loading")
            self.organizePrizmSetsByClass()
            print("Done organizing")
            completion(sets, nil)
        }
    }
    
    /// queryPrizms(): Function that searches PrizmSets based on query
    func queryPrizms(queryValue: String, completion: @escaping ([PrizmSet]?, Error?) -> Void) {
        var sets:[PrizmSet] = []
        var setIDs:[String] = []
        let dispatchGroup = DispatchGroup()
        
        let prizmSetCollectionRef = self.db.collection("prizm_sets")
        let query = prizmSetCollectionRef.whereField("prizmName", isEqualTo: queryValue)
        
        dispatchGroup.enter()
        query.getDocuments { querySnapshot, error in
            print("QUERYING TITLES")
            if let error = error {
                completion(nil, error)
                return
            } else {
                for document in querySnapshot!.documents {
                    print("DOCUMENT ID \(document.documentID)")
                    
                    setIDs.append(document.documentID)
                    let prizmSet = PrizmSet(data: document.data())
                    sets.append(prizmSet)
                }
                
            }
        }
        
        let queryPrizmDescription = prizmSetCollectionRef.whereField("description", isEqualTo: queryValue)
        
        queryPrizmDescription.getDocuments { querySnapshot, error in
            print("QUERYING DESCRIPTIONS")
            if let error = error {
                completion(nil, error)
                return
            } else {
                for document in querySnapshot!.documents {
                    print("QUERY DESCRIPTION DOCUMENT ID \(document.documentID)")
                    
                    let prizmSet = PrizmSet(data: document.data())
                    
                    if !setIDs.contains(document.documentID) {
                        sets.append(prizmSet)
                    }
                }
                
            }
        }
        
        let queryPrizmContents = prizmSetCollectionRef.whereField("content", in: [queryValue])
        
        queryPrizmContents.getDocuments { querySnapshot, error in
            print("QUERYING CONTENT")
            if let error = error {
                dispatchGroup.leave()
                completion(nil, error)
                return
            } else {
                for document in querySnapshot!.documents {
                    print("QUERY CONTENT DOCUMENT ID \(document.documentID)")
                    
                    let prizmSet = PrizmSet(data: document.data())
                    
                    if !setIDs.contains(document.documentID) {
                        sets.append(prizmSet)
                    }
                }
                
            }
            dispatchGroup.leave()
        }
        
        
        dispatchGroup.notify(queue: .main) {
            print("Done Loading")
            completion(sets, nil)
        }
    }
    
    func reorganizeUserData() {
        self.organizePrizmSetsByClass()
        self.getSharedSets()
        self.organizeSharedSetsByClass()
        self.getStarredSets()
        self.organizeSharedSetsByClass()
    }
    
    /// organizePrizmSetsByClass(): Takes the current locally stored PrizmSets and organizes them into a dictionary
    func organizePrizmSetsByClass() {
        byClass = [:]
        for (_, prizmSet) in prizmSets {
            let currClass = prizmSet.className
            if byClass.keys.contains(currClass) {
                byClass[currClass]?.append(prizmSet)
            } else {
                byClass[currClass] = [prizmSet]
            }
        }
    }
    
    func getSharedSets() {
        sharedSets = [:]
        for (_, prizmSet) in prizmSets {
            if prizmSet.ownerID != flashUser?.uid {
                sharedSets[prizmSet.id] = prizmSet
            }
        }
    }
    
    func organizeSharedSetsByClass() {
        sharedSetsByClass = [:]
        sharedOrder = []
        for (_, prizmSet) in sharedSets {
            let currClass = prizmSet.className
            if sharedSetsByClass.keys.contains(currClass) {
                sharedSetsByClass[currClass]?.append(prizmSet)
            } else {
                sharedSetsByClass[currClass] = [prizmSet]
                sharedOrder.append(currClass)
            }
        }
    }
    
    func getStarredSets() {
        starredSets = [:]
        guard let flashUser = flashUser else {
            print("No user to get starred from")
            return
        }
        for starredID in flashUser.starredSets {
            starredSets[starredID] = prizmSets[starredID]
        }
    }
    
    func organizeStarredSetsByClass() {
        starredSetsByClass = [:]
        starredOrder = []
        for (_, prizmSet) in starredSets {
            let currClass = prizmSet.className
            if starredSetsByClass.keys.contains(currClass) {
                starredSetsByClass[currClass]?.append(prizmSet)
            } else {
                starredSetsByClass[currClass] = [prizmSet]
                starredOrder.append(currClass)
            }
        }
    }
    
    /// fetchUsername(): fetches username of prizmSet creator
    func fetchUsername(userID: String, completion: @escaping (String?) -> Void) -> Void {
        self.db.collection("users").document(userID).getDocument { snapshot, error in
            
            guard let snapshot = snapshot, snapshot.exists, let userData = snapshot.data() else {
                completion("Deleted User")
                return
            }
            let usernameString = userData["username"] as! String
            print("FOUND USERNAME \(usernameString)")
            completion(usernameString)
        }
    }
    
    func fetchFriendData(uid: String, completion: @escaping (FlashUser?, Error?) -> Void) {
        FirebaseManager.shared.db.collection("users").document("\(uid)").getDocument { snapshot, error in
            guard let snapshot = snapshot, snapshot.exists, let friendData = snapshot.data(), error == nil else {
                completion(nil, error)
                return
            }
            
            let friendUser = FlashUser(data: friendData)
            completion(friendUser, nil)
        }
    }
    
    /// createPrizm(): Function to create a PrizmSet. It takes in the properties of a PrizmSet as well as a dictionary of the PrizmSet, puts it into the document, and then uploads it into Firebase.
    func createPrizm(prizmName: String, description: String, className: String, prizmDic: [String: [String]], prizmOrder: [String], completion: @escaping (Error?) -> Void) {
        // prizmDic is the content for each prizm. First string is the term, and the [String] contains all the faces for each term. The whole prizm have multiple terms, thus, stored in an array.
        
        guard let user = currentUser else { return }
        guard var flashUser = flashUser else { return }
        
        // Creates prizmSet collection reference. Firebase will create one if it doesn't exist.
        let prizmSetCollectionRef = self.db.collection("prizm_sets")
        let query = prizmSetCollectionRef.whereField("prizmName", isEqualTo: prizmName).whereField("ownerID", isEqualTo: flashUser.uid)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
            } else {
                var data: [String: Any] = ["prizmName": prizmName, "description": description, "className": className, "ownerID": user.uid, "public": false, "sharedIDs": [] as [String], "content": prizmDic, "prizmOrder": prizmOrder]
                
                if let document = querySnapshot?.documents.first {
                    // The document exists
                    print("Document exists with ID: \(document.documentID), EDITING existing document")
                    data["id"] = document.documentID
                    prizmSetCollectionRef.document(document.documentID).setData(data, completion: { (error) in
                        if let error = error {
                            completion(error)
                        }
                        FirebaseManager.shared.db.collection("users").document(user.uid).updateData([
                            "prizmSets": FieldValue.arrayUnion(["\(document.documentID)"])
                        ])
                        let className = data["className"] as? String ?? ""
                        if (!flashUser.classOrder.contains(className) && className != "") {
                            flashUser.classOrder.append(className)
                            FirebaseManager.shared.db.collection("users").document(user.uid).updateData([
                                "classOrder": FieldValue.arrayUnion([className])
                            ])
                        }
                        completion(nil)
                    })
                } else {
                    // The document does not exist
                    print("Document does not exist, UPLOADING new prizmSet to Firebase")
                    let newPrizmRef = prizmSetCollectionRef.document()
                    data["id"] = newPrizmRef.documentID
                    FirebaseManager.shared.db.collection("users").document(user.uid).updateData([
                        "prizmSets": FieldValue.arrayUnion(["\(newPrizmRef.documentID)"])
                    ])
                    let className = data["className"] as? String ?? ""
                    if (!flashUser.classOrder.contains(className) && className != "") {
                        flashUser.classOrder.append(className)
                        FirebaseManager.shared.db.collection("users").document(user.uid).updateData([
                            "classOrder": FieldValue.arrayUnion([className])
                        ])
                    }
                    newPrizmRef.setData(data)
                    completion(nil)
                }
            }
        }
        
    }
    
    /// updatePrizm(): Function toupdate a PrizmSet. It takes in the properties of a PrizmSet as well as a dictionary of the PrizmSet, puts it into the document, and then updates existing document into Firebase.
    func updatePrizm(prizmID: String, prizmUID: String, prizmName: String, description: String, className: String, prizmDic: [String: [String]], prizmOrder: [String], completion: @escaping (Error?) -> Void) {
        // prizmDic is the content for each prizm. First string is the term, and the [String] contains all the faces for each term. The whole prizm have multiple terms, thus, stored in an array.
        
        guard let user = currentUser else { return }
        
        // Creates prizmSet collection reference. Firebase will create one if it doesn't exist.
        let prizmSetCollectionRef = self.db.collection("prizm_sets")
        let query = prizmSetCollectionRef.whereField("id", isEqualTo: prizmID).whereField("ownerID", isEqualTo: prizmUID)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
            } else {
                var data: [String: Any] = ["prizmName": prizmName, "description": description, "className": className, "ownerID": user.uid, "public": false, "sharedIDs": [] as [String], "content": prizmDic, "prizmOrder": prizmOrder]
                
                if let document = querySnapshot?.documents.first {
                    // The document exists
                    print("Document exists with ID: \(document.documentID), EDITING existing document")
                    data["id"] = document.documentID
                    let currClassName = document.data()["className"] as? String ?? ""
                    prizmSetCollectionRef.document(document.documentID).setData(data, completion: { (error) in
                        if let error = error {
                            completion(error)
                        }
                        FirebaseManager.shared.db.collection("users").document(user.uid).updateData([
                            "prizmSets": FieldValue.arrayUnion(["\(document.documentID)"])
                        ])
                        
                        if currClassName != "", currClassName != className {
                            FirebaseManager.shared.db.collection("users").document(user.uid).updateData([
                                "classOrder": FieldValue.arrayUnion([data["className"] as Any])
                            ])
                            let classQuery = prizmSetCollectionRef.whereField("className", isEqualTo: currClassName).whereField("ownerID", isEqualTo: user.uid)
                            classQuery.getDocuments { classSnapshot, classError in
                                guard let _ = classSnapshot?.documents.first else {
                                    print("No more classes with prev. class name")
                                    FirebaseManager.shared.db.collection("users").document(user.uid).updateData([
                                        "classOrder": FieldValue.arrayRemove([currClassName])
                                    ])
                                    return
                                }
                            }
                        }
                        completion(nil)
                    })
                } else {
                    // The document does not exist
                    print("Document does not exist, UPLOADING new prizmSet to Firebase")
                    let newPrizmRef = prizmSetCollectionRef.document()
                    data["id"] = newPrizmRef.documentID
                    FirebaseManager.shared.db.collection("users").document(user.uid).updateData([
                        "prizmSets": FieldValue.arrayUnion(["\(newPrizmRef.documentID)"])
                    ])
                    newPrizmRef.setData(data)
                    completion(nil)
                }
            }
        }
        
    }
    
    func sharePrizm(prizmID: String, prizmClassName: String, shareWithIDs: [String], completion: @escaping (Error?) -> Void) {
        guard currentUser != nil else {
            completion(nil)
            return }
        
        
        // Creates prizmSet collection reference. Firebase will create one if it doesn't exist.
        let prizmSetCollectionRef = self.db.collection("prizm_sets")
        let query = prizmSetCollectionRef.whereField("id", isEqualTo: prizmID)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(error)
                return
            } else {
                if let document = querySnapshot?.documents.first {
                    // The document exists
                    print("Document exists with ID: \(document.documentID)")
                    
                    var sharedIDs: [String] = document.get("sharedIDs") as! [String]
                    
                    for toAddUIDIndex in 0..<shareWithIDs.count {
                        if !(sharedIDs.contains(shareWithIDs[toAddUIDIndex])) {
                            sharedIDs.append(shareWithIDs[toAddUIDIndex])
                        }
                    }
                    
                    prizmSetCollectionRef.document(document.documentID).updateData(["sharedIDs": sharedIDs], completion: { error in
                        
                        if let error = error {
                            print("ERROR IN UPDATING DATA")
                            completion(error)
                        }
                        
                        // looping through every single user and updating their document
                        for toAddUIDIndex in 0..<shareWithIDs.count {
                            print("SHARE - UPDATING DOCUMENT FOR USER \(shareWithIDs[toAddUIDIndex])")
                            FirebaseManager.shared.db.collection("users").document(shareWithIDs[toAddUIDIndex]).updateData([
                                "prizmSets": FieldValue.arrayUnion([prizmID])
                            ])
                            if prizmClassName != "" {
                                FirebaseManager.shared.db.collection("users").document(shareWithIDs[toAddUIDIndex]).updateData([
                                    "classOrder": FieldValue.arrayUnion([prizmClassName])
                                ])
                            }
                        }
                        
                        
                        print("NO PROBLEMS UPDATING DOCUMENT IN FIREBASE")
                        completion(nil)
             
                    })
                    
                } else {
                    // The document does not exist
                    print("Document does not exist")
                    completion(error)
                }
            }
        }
    }
    

    func deletePrizm(prizmID: String, shared: Bool, completion: @escaping (Bool) -> Void) {
        let userColl = self.db.collection("users")
        let setColl = self.db.collection("prizm_sets")
        
        if var flashUser = flashUser, shared {
            print("Removing shared prizm")
            userColl.document(flashUser.uid).updateData([
                "prizmSets": FieldValue.arrayRemove([prizmID])
            ])
            
            flashUser.prizmSets.remove(at: flashUser.prizmSets.firstIndex(of: prizmID)!)
            self.prizmIds.remove(at: self.prizmIds.firstIndex(of: prizmID)!)
            if self.prizmIds.count > 0 {
                setColl.whereField("id", in: self.prizmIds).whereField("className", isEqualTo: self.prizmSets[prizmID]?.className ?? "").getDocuments { sharedSnap, sharedError in
                    guard let sharedSnap = sharedSnap, sharedError == nil else {
                        completion(false)
                        return
                    }
                    
                    if sharedSnap.isEmpty {
                        print("No other documents to check")
                        userColl.document(flashUser.uid).updateData([
                            "classOrder": FieldValue.arrayRemove([self.prizmSets[prizmID]?.className ?? ""])
                        ])
                    }
                    self.prizmSets.removeValue(forKey: prizmID)
                    self.reorganizeUserData()
                    
                    completion(true)
                    return
                    
                }
            } else {
                self.prizmSets.removeValue(forKey: prizmID)
                self.reorganizeUserData()
                
                completion(true)
                return
            }
        }
        
        var fullPrizmSet = PrizmSet()
        // Get the current prizmSet data (cause we need to have the class)
        setColl.document(prizmID).getDocument { docSnapshot, docError in
            guard let docSnapshot = docSnapshot, docError == nil, let data = docSnapshot.data() else {
                print("No prizmSet available to delete")
                completion(false)
                return
            }
            // Put the prizmSet into a variable
            fullPrizmSet = PrizmSet(data: data)
        
            // Find users who have that prizmSet
            userColl.whereField("prizmSets", arrayContains: prizmID).getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    print("Error getting documents to delete prizm set")
                    completion(false)
                    return
                }

                if snapshot.isEmpty {
                    print("No docs with prizmID in Firebase")
                    completion(false)
                    return
                }
                
                // Go through each user
                for doc in snapshot.documents {
                    // Remove prizmSet from array
                    userColl.document(doc.documentID).updateData([
                        "prizmSets": FieldValue.arrayRemove([prizmID])
                    ])
                    
                    // Get rest of the prizmSets
                    let prizmSets = doc.data()["prizmSets"] as! [String]
                    print(prizmSets)
                    print(fullPrizmSet.className)
                    
                    
                    // Find prizmSets who have the same class
                    setColl.whereField("id", in: prizmSets)
                        .whereField("className", isEqualTo: fullPrizmSet.className)
                        .getDocuments { snapshot2, error2 in
                            
                        guard let snapshot2 = snapshot2, error2 == nil else {
                            print("Error getting documents to check class")
                            completion(false)
                            return
                        }
                            
                        print(snapshot2.count)
                        
                        // If no classes do, remove the class from the order
                        if snapshot2.isEmpty {
                            print("No other documents to check")
                            userColl.document(doc.documentID).updateData([
                                "classOrder": FieldValue.arrayRemove([fullPrizmSet.className])
                            ])
                            completion(true)
                        }
                            
                        // Delete the actual file
                        self.db.collection("prizm_sets").document(prizmID).delete { error in
                            guard let error = error else {
                                print("Prizm Set \(prizmID) successfully deleted")
                                
                                let removeIndex = self.flashUser?.prizmSets.firstIndex(of: prizmID)
                                self.flashUser?.prizmSets.remove(at: removeIndex!)
                                self.prizmSets.removeValue(forKey: prizmID)
                                self.prizmIds.remove(at: self.prizmIds.firstIndex(of: prizmID)!)
                                self.reorganizeUserData()
                                
                                // Reset data
                                FirebaseManager.shared.fetchData(FirebaseManager.shared.currentUser) { error in
                                    if let error = error {
                                        print("Error fetching data: \(error)")
                                    }
                                }
                                completion(true)
                                return
                            }
                            
                            print(error)
                            completion(false)
                        }
                    }
                }
            }
        }
        
    }
    

    // fetchSetOfFollowerzData: for the share function, search available usernames
    func fetchSetOfFollowerzData(uids: [String], completion: @escaping (Error?, [String]?, [String]?, [UIImage]?) -> Void) {
        
        var listOfUserIDs:[String] = []
        var listOfUsernames:[String] = []
        var listOfImages:[UIImage] = []
        
        print("SEARCHING USERNAMES FUNCTION FOR QUERY \(uids)")
        // Creates prizmSet collection reference. Firebase will create one if it doesn't exist.
        
        let dispatchGroup = DispatchGroup()
        
        for index in 0..<uids.count {
            
            dispatchGroup.enter()
            self.db.collection("users").document(uids[index]).getDocument { snapshot, error in
                
                guard let snapshot, snapshot.exists, let userData = snapshot.data() else {
                    dispatchGroup.leave()
                    return
                }
                
                let userUID = userData["uid"] as! String
                
                print("ENTERED DOWNLOAD IMAGE")
                let profileImageRef = FirebaseManager.shared.storageRef.child("profile_images/\(userUID).jpg")
                
                dispatchGroup.enter()
                profileImageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error downloading profile image: \(error.localizedDescription)")
                        listOfUserIDs.append(userData["uid"] as! String)
                        listOfUsernames.append(userData["username"] as! String)
                        listOfImages.append(UIImage(named: "DefaultAvatar")!)
                        print("LEFT DOWNLOAD IMAGE")
                        dispatchGroup.leave()
                    } else {
                        if let url = url {
                            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                                
                                if let data = data, let image = UIImage(data: data) {
                                    listOfUserIDs.append(userData["uid"] as! String)
                                    listOfUsernames.append(userData["username"] as! String)
                                    listOfImages.append(image)
                                    print("LEFT DOWNLOAD IMAGE")
                                    dispatchGroup.leave()
                                }
                            }
                            
                            task.resume()
                            
                            
                            
                        }
                    }
                }
                dispatchGroup.leave()
                
            }
            
            
        }
        dispatchGroup.notify(queue: .main) {
            print("Fetched user info for list: \(uids)")
            print(listOfUserIDs)
            print(listOfUsernames)
            print(listOfImages)
            print("RETURNING BACK TO SHARE VC")
            completion(nil, listOfUserIDs, listOfUsernames, listOfImages)
            
        }
    }


    // searchUsernames: for the share function, search available usernames 
    func searchUsernames(query: String, completion: @escaping (Error?, [String]?, [String]?, [UIImage]?) -> Void) {
        
        let queryString = query
        
        var listOfUserIDs:[String] = []
        var listOfUsernames:[String] = []
        var listOfImages:[UIImage] = []
        
        print("SEARCHING USERNAMES FUNCTION FOR QUERY \(query)")
        // Creates prizmSet collection reference. Firebase will create one if it doesn't exist.
        let prizmSetCollectionRef = self.db.collection("users")
        let query = prizmSetCollectionRef.whereField("username", isEqualTo: query)
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        
        query.getDocuments { [self] querySnapshot, error in
            guard let snapshot = querySnapshot, error == nil, let fUser = flashUser else {
                dispatchGroup.leave()
                completion(error, nil, nil, nil)
                return
            }
            
            if snapshot.isEmpty {
                dispatchGroup.leave()
                completion(MyError.noDocuments, nil, nil, nil)
                return

            }
            
            
            for index in 0..<snapshot.count {
                if snapshot.documents[index].get("uid") as! String != fUser.uid {
                    
                    dispatchGroup.enter()
                    // Download profile image
                    print("ENTERED DOWNLOAD IMAGE")
                    let profileImageRef = FirebaseManager.shared.storageRef.child("profile_images/\(snapshot.documents[index].get("uid") as! String).jpg")
                    
                    
                    profileImageRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Error downloading profile image: \(error.localizedDescription)")
                            listOfUserIDs.append(snapshot.documents[index].get("uid") as! String)
                            listOfUsernames.append(snapshot.documents[index].get("username") as! String)
                            listOfImages.append(UIImage(named: "DefaultAvatar")!)
                            print("LEFT DOWNLOAD IMAGE")
                            dispatchGroup.leave()
                        } else {
                            if let url = url {
                                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                                    
                                    if let data = data, let image = UIImage(data: data) {
                                        listOfUserIDs.append(snapshot.documents[index].get("uid") as! String)
                                        listOfUsernames.append(snapshot.documents[index].get("username") as! String)
                                        listOfImages.append(image)
                                        print("LEFT DOWNLOAD IMAGE")
                                        dispatchGroup.leave()
                                    }
                                }
                                
                                task.resume()
                                
                                
                                
                            }
                        }
                    }
                }
            }
            
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            print("FOUND STUFF FOR QUERY \(queryString):")
            print(listOfUserIDs)
            print(listOfUsernames)
            print(listOfImages)
            print("RETURNING BACK TO SHARE VC")
            completion(nil, listOfUserIDs, listOfUsernames, listOfImages)
        }
        
    }
    
    func fetchRandomUsers(numUsers: Int, completion: @escaping (Error?, [String]?) -> Void) {
        FirebaseManager.shared.db.collection("users").getDocuments { [self] snapshot, error in
            guard let snapshot = snapshot, error == nil, let fUser = flashUser else {
                completion(error, nil)
                return
            }
        
            if snapshot.isEmpty {
                completion(MyError.noDocuments, nil)
            }
            
            let numToGet = min(numUsers, snapshot.documents.count)
            
            var indexes:[Int] = []
            for _ in 0..<numToGet {
                var newIndex = Int.random(in: 0..<snapshot.documents.count)
                
                while indexes.contains(newIndex) ||
                        snapshot.documents[newIndex].documentID == fUser.uid {
                    newIndex = Int.random(in: 0..<snapshot.documents.count)
                }
                
                indexes.append(newIndex)
            }
            
            var ids:[String] = []
            for i in indexes {
                ids.append(snapshot.documents[i].documentID)
            }
            completion(nil, ids)
        }
    }
    
    func isFollowing(otherID: String) -> Bool {
        guard let user = flashUser else {
            print("No user to check if friend")
            return false
        }
        
        return user.following.contains(otherID)
    }
    
    func followUser(other: FlashUser?) {
        guard var user = flashUser, var other = other else {
            print("No current user for follow")
            return
        }
        
        user.following.append(other.uid)
        self.db.collection("users").document(user.uid).updateData([
            "following": FieldValue.arrayUnion([other.uid])
        ])
        
        other.followers.append(user.uid)
        other.invites.append(user.uid)
        self.db.collection("users").document(other.uid).updateData([
            "followers": FieldValue.arrayUnion([user.uid]),
            "invites": FieldValue.arrayUnion([user.uid])
        ])
        
        if other.invites.contains(user.uid) && user.invites.contains(other.uid) {
            self.db.collection("users").document(other.uid).updateData([
                "invites": FieldValue.arrayRemove([user.uid])
            ])
            
            self.db.collection("users").document(user.uid).updateData([
                "invites": FieldValue.arrayRemove([other.uid])
            ])
        }
    }
    
    func unfollowUser(other: FlashUser?) {
        guard var user = flashUser, var other = other else {
            print("No current user for follow")
            return
        }
        
        user.following.remove(at: user.following.firstIndex(of: other.uid)!)
        self.db.collection("users").document(user.uid).updateData([
            "following": FieldValue.arrayRemove([other.uid])
        ])
        
        other.followers.remove(at: other.followers.firstIndex(of: user.uid)!)
        self.db.collection("users").document(other.uid).updateData([
            "followers": FieldValue.arrayRemove([user.uid])
        ])
        
        if other.following.contains(user.uid) {
            user.invites.append(other.uid)
            self.db.collection("users").document(user.uid).updateData([
                "invites": FieldValue.arrayUnion([other.uid])
            ])
        }
    }
    
    func starSet(prizmSet: PrizmSet) {
        guard let user = flashUser else { return }
        
        print("starring")
        
        self.db.collection("users").document(user.uid).updateData([
            "starredSets": FieldValue.arrayUnion([prizmSet.id])
        ])
        
        starredSets[prizmSet.id] = prizmSet
        organizeStarredSetsByClass()
        print(starredSetsByClass)
    }
    
    func unstarSet(prizmSet: PrizmSet) {
        guard let user = flashUser else { return }
        
        print("unstarring")
        
        self.db.collection("users").document(user.uid).updateData([
            "starredSets": FieldValue.arrayRemove([prizmSet.id])
        ])
        
        starredSets.removeValue(forKey: prizmSet.id)
        organizeStarredSetsByClass()
        print(starredSetsByClass)
    }
}

enum updateType {
    case username
    case email
    case phoneNumber
    case password
    case deleteUser
}

public enum MyError: Error {
    case notLoggedIn
    case noDocuments
}

extension MyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return NSLocalizedString("User not logged in.", comment: "My error")
        case .noDocuments:
            return NSLocalizedString("No documents", comment: "My error")
        }
    
    }
}
