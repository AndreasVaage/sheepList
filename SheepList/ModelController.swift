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
    var selectedSheep: Int?
    enum SheepGroup {
        case all, search
    }
    var sheepGroup: SheepGroup = .all
    
    func findLastSavedLambID() -> String? {
        for sheep in sheeps.reversed(){
            if let lambID = sheep.lambs.last?.sheepID {
                return lambID
            }
        }
        return nil
    }

}
