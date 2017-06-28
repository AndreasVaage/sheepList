//
//  Sheep.swift
//  SheepList
//
//  Created by Andreas Våge on 21.06.2017.
//
//

import UIKit

class Sheep: NSObject, NSCoding {
    
    struct PropertyKey {
        static let sheepID = "sheepID"
        static let birthday = "birthday"
        static let notes = "notes"
        static let lambs = "lambs"
    }
    
    var sheepID: String?
    var birthday: Date?
    var notes: String?
    var lambs: [Sheep]
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("sheeps")
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let lambs = aDecoder.decodeObject(forKey: PropertyKey.lambs) as? [Sheep] else { return nil }
        
        let sheepID = aDecoder.decodeObject(forKey: PropertyKey.sheepID) as? String
        let birthday = aDecoder.decodeObject(forKey: PropertyKey.birthday) as? Date
        let notes = aDecoder.decodeObject(forKey: PropertyKey.notes) as? String
        
        self.init(sheepID: sheepID, birthday: birthday, notes: notes, lambs: lambs)
    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(sheepID, forKey: PropertyKey.sheepID)
        aCoder.encode(birthday, forKey: PropertyKey.birthday)
        aCoder.encode(notes, forKey: PropertyKey.notes)
        aCoder.encode(lambs, forKey: PropertyKey.lambs)
    }
    
    init(sheepID: String?) {
        self.sheepID = sheepID
        self.birthday = nil
        self.notes = nil
        self.lambs = []
    }
    init(sheepID: String?, birthday: Date?) {
        self.sheepID = sheepID
        self.birthday = birthday
        self.notes = nil
        self.lambs = []
    }
    
    init(sheepID: String?, birthday: Date?, notes: String?, lambs: [Sheep]){
        
        self.sheepID = sheepID
        self.birthday = birthday
        self.notes = notes
        self.lambs = lambs
    }
    static func saveSheeps(_ sheeps: [Sheep]) {
        NSKeyedArchiver.archiveRootObject(sheeps, toFile: Sheep.ArchiveURL.path)
    }
    
    static func loadSheeps() -> [Sheep]?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Sheep.ArchiveURL.path) as? [Sheep]
    }
    
    static func loadSampleSheeps() -> [Sheep] {
        let sheep1 = Sheep(sheepID: "10023", birthday: Date(), notes: "Notes 1", lambs:
            [Sheep(sheepID: "30007")
            ])
        let sheep2 = Sheep(sheepID: "10024", birthday: Date(), notes: "Notes 2", lambs:
            [Sheep(sheepID: "30008"),
            Sheep(sheepID: "30009"),
            Sheep(sheepID: "30010"),
            Sheep(sheepID: "30011")])
        let sheep3 = Sheep(sheepID: "10025", birthday: Date(), notes: "Notes 3", lambs:
            [Sheep(sheepID: "30012"),
             Sheep(sheepID: "30013"),
             Sheep(sheepID: "30013")])
        
        return [sheep1, sheep2, sheep3]
    }
    
    static func isCorrectFormat(for sheep: Sheep) -> Bool{
        guard let sheepID = sheep.sheepID else { return false }
        guard sheepID != "" else { return false }
        for lamb in sheep.lambs {
            guard let lambID = lamb.sheepID else { return false }
            guard lambID != "" else { return false }
            guard lamb.lambs == [] else { return false }
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
