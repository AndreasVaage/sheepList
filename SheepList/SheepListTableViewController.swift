//
//  SheepListTableViewController.swift
//  SheepList
//
//  Created by Andreas Våge on 21.06.2017.
//
//

import UIKit

class SheepListTableViewController: UITableViewController {  //SheepCellDelegate
    var modelC: ModelController!
    //var lambs = [Sheep]()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        let searchBar = searchController.searchBar
        searchBar.keyboardType = UIKeyboardType.numberPad
        tableView.tableHeaderView = searchBar
        
        
        
        if let savedSheeps = Sheep.loadSheeps() {
            modelC.sheeps = savedSheeps
        } else {
            modelC.sheeps = Sheep.loadSampleSheeps()
        }
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 88
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let detailedSheepViewController = segue.destination
                as! DetailedSheepViewController
            let indexPath = tableView.indexPathForSelectedRow!
            
            if searchController.isActive && searchController.searchBar.text != "" {
                modelC.sheepGroup = .search
            }else{
                modelC.sheepGroup = .all
            }
            modelC.selectedSheep = indexPath.row
            detailedSheepViewController.modelC = modelC
        }else if segue.identifier == "newSheep"{
            let navVC = segue.destination as? UINavigationController
            
            let addSheeptableVC = navVC?.viewControllers.first as! EditSheepTableViewController
            addSheeptableVC.seguedFrom = "sheepList"
        }else{
            fatalError("Unknown Segue")
        }
    }
        
    @IBAction func unwindToSheepList(segue: UIStoryboardSegue) {
        guard segue.identifier == "SaveUnwindToSheepList" else {return}
        let sourceViewController = segue.source as! EditSheepTableViewController
        
        let sheep = sourceViewController.sheep
        guard Sheep.isCorrectFormat(for: sheep) else {
            fatalError("Trying to save sheep with wrong format")
        }
        if let selectedIndexPath =
            tableView.indexPathForSelectedRow {
            modelC.sheeps[selectedIndexPath.row] = sheep
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        } else {
            let newIndexPath = IndexPath(row: modelC.sheeps.count, section: 0)
            modelC.sheeps.append(sheep)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
        Sheep.saveSheeps(modelC.sheeps)
        tableView.scrollToBottom(ofSection: 0)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return modelC.filteredSheeps.count
        }
        return modelC.sheeps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SheepCellIdentifier") as? SheepCell else {
            fatalError("Could not dequeue a cell")
        }
        guard cell.LambStackView.subviews.count == cell.LambStackView.arrangedSubviews.count else {
            fatalError("Arranged subviews count dont match subview count")
        }
        
        let sheep: Sheep
        if searchController.isActive && searchController.searchBar.text != "" {
            sheep = modelC.filteredSheeps[indexPath.row]
        }else {
            sheep = modelC.sheeps[indexPath.row]
        }
        cell.SheepIDLabel?.text = sheep.sheepID
        
        for (index,lamb) in sheep.lambs.enumerated() {
            if cell.LambStackView.subviews.count > index{
                let labelView = cell.LambStackView.arrangedSubviews[index] as! UILabel
                labelView.text = lamb.sheepID
            }else{
                let label = UILabel()
                label.text = lamb.sheepID
                cell.LambStackView.addArrangedSubview(label)
            }
        }
        let overCount = cell.LambStackView.subviews.count - sheep.lambs.count
        if (overCount) > 0 {
            for index in (sheep.lambs.count...cell.LambStackView.subviews.count-1).reversed() {
                let view = cell.LambStackView.arrangedSubviews[index]
                view.removeFromSuperview()
            }
            
        }
        guard((sheep.lambs.count == cell.LambStackView.subviews.count) && (sheep.lambs.count == cell.LambStackView.arrangedSubviews.count)) else{
            fatalError("lamb count dont match viewed lambcount")
        }
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        modelC.filteredSheeps = modelC.sheeps.filter { sheep in
            for lamb in sheep.lambs {
                if subSecuence(is: searchText.lowercased(), subSecuenceOff: lamb.sheepID!.lowercased()){
                    return true
                }
            }
            return subSecuence(is: searchText.lowercased(), subSecuenceOff: sheep.sheepID!.lowercased())
        }
        tableView.reloadData()
    }
    
    func subSecuence(is str1: String,subSecuenceOff str2: String) -> Bool {
        if str1.isEmpty {
            return true
        }
        if str2.isEmpty{
            fatalError("Empty Sheep ID detected")
        }
        var offset = 0
        for letter in str2.characters{
            guard let index =  str1.index(str1.startIndex, offsetBy: offset, limitedBy: str1.index(before: str1.endIndex)) else{
                return true
            }
            if letter == str1[index]{
                offset += 1
            }
        }
        return offset == str1.characters.count
    }
    
//    func checkmarkTapped(sender: SheepCell) {
//        if let indexPath = tableView.indexPath(for: sender) {
//            let sheep = sheeps[indexPath.row]
//            sheep.checked = !sheep.checked
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//            Sheep.saveSheeps(sheeps)
//        }
//        
//    }
    
    
    //EDITING
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if tableView.isEditing {
            return .delete
        }
        
        return .none
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            modelC.sheeps.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            Sheep.saveSheeps(modelC.sheeps)
        }
    }
}

extension SheepListTableViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
