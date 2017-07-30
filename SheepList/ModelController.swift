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
    var filteredSheeps = [Sheep]()
    var workingSet = [Sheep]()
    var workingSetActive = false
    
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
    
    func findMissingSheeps()-> [Sheep]{
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
    
    func deleteSheep(at sheepIndex: Int) {
        if workingSetActive{
            workingSet.remove(at: sheepIndex)
        }else{
            sheeps.remove(at: sheepIndex)
            Sheep.saveSheeps(sheeps)
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
