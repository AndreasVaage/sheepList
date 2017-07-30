//
//  WorkingSetTVC.swift
//  SheepList
//
//  Created by Andreas Våge on 30.07.2017.
//
//


import UIKit

class WorkingSetController: SheepTableVC {
    var modelC: ModelController!
    
    override func deleteSheep(at index: Int){
        modelC.workingSet.remove(at: index)
        sheeps = modelC.workingSet
    }
    
    override func viewDidLoad() {
        
//        if let savedSheeps = Sheep.loadSheeps() {
//            modelC.sheeps = savedSheeps
//        } else {
//            modelC.sheeps = []
//        }
        sheeps = modelC.workingSet
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let detailedSheepViewController = segue.destination
                as! DetailedSheepViewController
            
            if searchController.isActive && searchController.searchBar.text != "" {
                modelC.sheepGroup = .search
            }else{
                modelC.sheepGroup = .all
            }
            // modelC.selectedSheep = indexPath.row
            let sheep = sheeps[tableView.indexPathForSelectedRow!.row]
            detailedSheepViewController.modelC = modelC
            detailedSheepViewController.sheep = sheep
            detailedSheepViewController.sheepIndex = modelC.sheeps.index(of: sheep)
        }else if segue.identifier == "addSheep"{
            
            let addSheeptableNC = segue.destination as! UINavigationController
            let addSheeptableVC = addSheeptableNC.topViewController as! AddSheepsToWorkingSetTVC
            addSheeptableVC.modelC = modelC
        }else{
            fatalError("Unknown Segue")
        }
    }
    
    @IBAction func unwindToWorkingSet(segue: UIStoryboardSegue) {
        sheeps = modelC.workingSet
        guard segue.identifier == "SaveUnwindToWorkingSet" else { return }
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [selectedIndexPath], with: UITableViewRowAnimation.automatic )
        } 
    }
    
}
