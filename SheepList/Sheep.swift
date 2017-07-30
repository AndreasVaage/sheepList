//
//  Sheep.swift
//  SheepList
//
//  Created by Andreas Våge on 21.06.2017.
//
//

import UIKit

class Sheep: NSObject, NSCoding {
    
    let lambPrefix = "70"
    struct Group {
        let group: String
        let color: UIColor
        init(_ group: String, _ color: UIColor) {
            self.group = group
            self.color = color
        }
    }
    static var groups = [Group("orphan",.blue),Group("dead",.red),Group("missing",.gray),Group("sold",.green),
                         Group("k",.yellow),Group("test",.purple),Group("testing",.orange),Group("tes",.cyan)]
    
    struct PropertyKey {
        static let sheepID = "sheepID"
        static let birthday = "birthday"
        static let notes = "notes"
        static let lambs = "lambs"
        static let mother = "mother"
        static let father = "father"
        static let groupMemberships = "groupMemberships"
    }
    
    var sheepID: String?
    var birthday: Date?
    var notes: String?
    var lambs: [Sheep]
    weak var mother: Sheep?
    weak var father: Sheep?
    var groupMemberships: [Bool]
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("sheeps")
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let lambs = aDecoder.decodeObject(forKey: PropertyKey.lambs) as? [Sheep] else { return nil }
        guard let groupMemberships = aDecoder.decodeObject(forKey: PropertyKey.groupMemberships) as? [Bool] else { return nil }
       
        
        let sheepID = aDecoder.decodeObject(forKey: PropertyKey.sheepID) as? String
        let birthday = aDecoder.decodeObject(forKey: PropertyKey.birthday) as? Date
        let notes = aDecoder.decodeObject(forKey: PropertyKey.notes) as? String
        let mother = aDecoder.decodeObject(forKey: PropertyKey.mother) as? Sheep
        let father = aDecoder.decodeObject(forKey: PropertyKey.father) as? Sheep
        
        self.init(sheepID: sheepID, birthday: birthday, notes: notes, lambs: lambs, mother: mother, father: father, groupMemberships: groupMemberships)
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sheepID, forKey: PropertyKey.sheepID)
        aCoder.encode(birthday, forKey: PropertyKey.birthday)
        aCoder.encode(notes, forKey: PropertyKey.notes)
        aCoder.encode(lambs, forKey: PropertyKey.lambs)
        aCoder.encode(mother, forKey: PropertyKey.mother)
        aCoder.encode(father, forKey: PropertyKey.father)
        aCoder.encode(groupMemberships, forKey: PropertyKey.groupMemberships)
    }
    
    init(sheepID: String?) {
        self.sheepID = sheepID
        self.lambs = []
        self.groupMemberships = [Bool](repeating: false, count: Sheep.groups.count)
    }
    init(sheepID: String?, birthday: Date?) {
        self.sheepID = sheepID
        self.birthday = birthday
        self.lambs = []
        self.groupMemberships = [Bool](repeating: false, count: Sheep.groups.count)
    }
    init(sheepID: String?, birthday: Date?, mother: Sheep?) {
        self.sheepID = sheepID
        self.birthday = birthday
        self.lambs = []
        self.mother = mother
        self.groupMemberships = [Bool](repeating: false, count: Sheep.groups.count)
    }
    
    init(sheepID: String?, birthday: Date?, notes: String?, lambs: [Sheep], mother: Sheep?, father: Sheep?, groupMemberships: [Bool]){
        guard groupMemberships.count == Sheep.groups.count else {
            fatalError("Group sizes dont match")
        }
        self.sheepID = sheepID
        self.birthday = birthday
        self.notes = notes
        self.lambs = lambs
        self.mother = mother
        self.father = father
        self.groupMemberships = groupMemberships
    }
    func isLamb() -> Bool {
        return (self.sheepID?.hasPrefix(lambPrefix))!
    }
    
    func activeGroupMembershipCount() -> Int {
        var count = 0
        for groupMembership in self.groupMemberships {
            if groupMembership {
                count = count + 1
            }
        }
        return count
    }
    func activeGroupMemberships() -> [Group] {
        var activeGroupMemberships: [Group] = []
        for i in 0..<self.groupMemberships.count {
            if self.groupMemberships[i] {
                activeGroupMemberships.append(Sheep.groups[i])
            }
        }
        return activeGroupMemberships
    }
    
    static func saveSheeps(_ sheeps: [Sheep]) {
        NSKeyedArchiver.archiveRootObject(sheeps, toFile: Sheep.ArchiveURL.path)
    }
    
    static func loadSheeps() -> [Sheep]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Sheep.ArchiveURL.path) as? [Sheep]
    }
    
//    static func loadSampleSheeps() -> [Sheep] {
//        let sheep1 = Sheep(sheepID: "10023", birthday: Date(), notes: "Notes 1", lambs:
//            [Sheep(sheepID: "30007")
//            ])
//        let sheep2 = Sheep(sheepID: "10024", birthday: Date(), notes: "Notes 2", lambs:
//            [Sheep(sheepID: "30008"),
//            Sheep(sheepID: "30009"),
//            Sheep(sheepID: "30010"),
//            Sheep(sheepID: "30011")])
//        let sheep3 = Sheep(sheepID: "10025", birthday: Date(), notes: "Notes 3", lambs:
//            [Sheep(sheepID: "30012"),
//             Sheep(sheepID: "30013"),
//             Sheep(sheepID: "30013")])
//        
//        return [sheep1, sheep2, sheep3]
//    }
    
    static func isCorrectFormat(for sheep: Sheep) -> Bool{
        guard let sheepID = sheep.sheepID else { return false }
        guard sheepID != "" else { return false }
        for lamb in sheep.lambs {
            guard let lambID = lamb.sheepID else { return false }
            guard lambID != "" else { return false }
            guard lamb.lambs == [] else { return false }
        }
        if let motherSheep = sheep.mother {
            guard let sheepID = motherSheep.sheepID else { return false }
            guard sheepID != "" else { return false }
        }
        if let ram = sheep.father {
            guard let ramID = ram.sheepID else { return false }
            guard ramID != "" else { return false }
        }
        guard sheep.groupMemberships.count == Sheep.groups.count else {
            fatalError("Group sizes dont match")
        }
        
        return true
    }
    
    
    static let birthdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
