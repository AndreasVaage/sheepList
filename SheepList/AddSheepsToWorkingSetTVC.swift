//
//  File.swift
//  SheepList
//
//  Created by Andreas Våge on 30.07.2017.
//
//

import UIKit

class AddSheepsToWorkingSetTVC: SheepTableVC {
    var modelC: ModelController!

    override func viewDidLoad() {
        sheeps = modelC.sheeps
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        modelC.workingSet.append(sheeps[indexPath.row])
    }
    
}
