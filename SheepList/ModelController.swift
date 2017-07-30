//
//  ModelController.swift
//  SheepList
//
//  Created by Andreas Våge on 09.07.2017.
//
//

import UIKit




class ModelController{
    var sheeps = [Sheep]()
    var workingSet = [Sheep]()
    
    var everyOneByThemSelf: [Sheep] {
        var sheepList: [Sheep]  = sheeps
        for sheep in sheeps {
            sheepList.append(contentsOf: sheep.lambs)
        }
        return sheepList
    }
    
    enum SheepGroup {
        case all, search
    }
    var sheepGroup: SheepGroup = .all
    
    func findMissingSheeps() -> [Sheep]{
        var missingSheeps = [Sheep]()
        for sheep in workingSet{
            if let mother = sheep.mother {
                if !workingSet.contains(mother){
                    missingSheeps.append(mother)
                }
            }
        }
        return missingSheeps
    }
    func findMissingLambs(list: [Sheep]) -> [Sheep] {
        var missingLambs = [Sheep]()
        for sheep in list{
            for lamb in sheep.lambs{
                if !workingSet.contains(lamb){
                    missingLambs.append(lamb)
                }
            }
        }
        return missingLambs
    }
    func countLambsInWorkingSet() -> Int{
        var count = 0
        for sheep in workingSet{
            if sheep.isLamb(){
                count += 1
            }
        }
        return count
    }
   // modelC.sheeps.sort(sortBasedOnMissing)
    let sortBasedOnMissing = { (lhs: Sheep,rhs: Sheep) -> Bool in
        if lhs.groupMemberships[2] && !rhs.groupMemberships[2]{
            return true
        }
        var missingLamb = false
        for lamb in lhs.lambs{
            if lamb.groupMemberships[2] {
                missingLamb = true
                break
            }
        }
        for lamb in rhs.lambs{
            if lamb.groupMemberships[2] {
                missingLamb = false
                break
            }
        }
        
        return missingLamb
    }
    
    func delete(sheep: Sheep) {
        if let index = sheeps.index(of: sheep){
            sheeps.remove(at: index)
            Sheep.saveSheeps(sheeps)
        }else{
            fatalError("Trying to delete sheep which does not exist")
        }
    }
    
    func save(sheep: Sheep, sheepIndex: Int?, lambIndex: Int?){
        if let sheepIndex = sheepIndex {
            if let lambIndex = lambIndex {
                sheeps[sheepIndex].lambs[lambIndex] = sheep
            }else{
                sheeps[sheepIndex] = sheep
            }
            
        }else{
            sheeps.append(sheep)
        }
        Sheep.saveSheeps(sheeps)
    }
    
    func findLastSavedLambID() -> String? {
        for sheep in sheeps.reversed(){
            if let lambID = sheep.lambs.last?.sheepID {
                return lambID
            }
        }
        return nil
    }
}
