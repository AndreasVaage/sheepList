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
    var lambs = [Sheep]()
    var filteredSheeps = [Sheep]()
    enum SheepGroup {
        case all, search
    }
    var sheepGroup: SheepGroup = .all
    
    func deleteSheep(at sheepIndex: Int) {
        sheeps.remove(at: sheepIndex)
        Sheep.saveSheeps(sheeps)
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
