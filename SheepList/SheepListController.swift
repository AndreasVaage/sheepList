//
//  SheepListTableViewController.swift
//  SheepList
//
//  Created by Andreas Våge on 21.06.2017.
//
//

import UIKit

class SheepListController: SheepTableVC {  
    var modelC: ModelController!
    
    
    override func deleteSheep(at index: Int){
        modelC.delete(sheep: sheeps[index])
        sheeps = modelC.sheeps
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        
        //modelC = ModelController()
        if let savedSheeps = Sheep.loadSheeps() {
            modelC.sheeps = savedSheeps
        } else {
            modelC.sheeps = []
        }
        sheeps = modelC.sheeps
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
            detailedSheepViewController.modelC = modelC
            detailedSheepViewController.sheep = sheeps[tableView.indexPathForSelectedRow!.row]
            detailedSheepViewController.sheepIndex = tableView.indexPathForSelectedRow!.row
        }else if segue.identifier == "newSheep"{
            
            let addSheeptableNC = segue.destination as! UINavigationController
            let addSheeptableVC = addSheeptableNC.topViewController as! EditSheepTableViewController
            addSheeptableVC.modelC = modelC
            addSheeptableVC.seguedFrom = "sheepList"
            addSheeptableVC.sheepIndex = nil
        }else{
            fatalError("Unknown Segue")
        }
    }
        
    @IBAction func unwindToSheepList(segue: UIStoryboardSegue) {
        guard segue.identifier == "SaveUnwindToSheepList" else {
            return
        }
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            sheeps = modelC.sheeps
            tableView.reloadRows(at: [selectedIndexPath], with: UITableViewRowAnimation.automatic )
        } else {
            sheeps = modelC.sheeps
            let newIndexPath = IndexPath(row: modelC.sheeps.count-1, section: 0)
            tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.bottom )
        }
    }
    
}

