//
//  Structs.swift
//  FlashPrizm
//
//  Created by Cade Edney on 2/19/23.
//

import Foundation

struct PrizmSet: Decodable {
    let className: String
    let content: [String:[String]]
    let description: String
    let ownerID: String
    let prizmName: String
    let publicSet: Bool
    let sharedIDs: [String]
    let id: String
    let prizmOrder: [String]
    
    init(data: [String: Any]) {
        self.prizmName = data["prizmName"] as? String ?? ""
        self.content = data["content"] as? [String:[String]] ?? [:]
        self.description = data["description"] as? String ?? ""
        self.ownerID = data["ownerID"] as? String ?? ""
        self.className = data["className"] as? String ?? ""
        self.publicSet = data["publicSet"] as? Bool ?? false
        self.sharedIDs = data["sharedIDs"] as? [String] ?? []
        self.id = data["id"] as? String ?? ""
        self.prizmOrder = data["prizmOrder"] as? [String] ?? []
    }
    
    init() {
        self.init(data: [:])
    }
}

struct FlashUser: Decodable {
    var email: String
    var username: String
    var phoneNumber: String
    var prizmSets: [String]
    var followers: [String]
    var following: [String]
    var invites: [String]
    var classOrder: [String]
    var uid: String
    var starredSets: [String]
    
    init(data: [String: Any] = [:]) {
        self.email = data["email"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.phoneNumber = data["phoneNumber"] as? String ?? ""
        self.prizmSets = data["prizmSets"] as? [String] ?? []
        self.followers = data["followers"] as? [String] ?? []
        self.following = data["following"] as? [String] ?? []
        self.invites = data["invites"] as? [String] ?? []
        self.classOrder = data["classOrder"] as? [String] ?? []
        self.uid = data["uid"] as? String ?? ""
        self.starredSets = data["starredSets"] as? [String] ?? []
    }
}
