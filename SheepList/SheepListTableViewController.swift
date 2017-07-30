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
    var isAddingToWorkingSet = false
    var showMissingSheeps = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        print(modelC.workingSetActive)
        if modelC.workingSetActive && !isAddingToWorkingSet{
            isAddingToWorkingSet = true
            searchController.isActive = true
            sender.title = "done"
            tableView.reloadData()
        }else if modelC.workingSetActive && isAddingToWorkingSet {
            searchController.isActive = false
            isAddingToWorkingSet = false
            sender.title = "add"
            tableView.reloadData()
        }
    }
    
    @IBAction func chackButtonPressed(_ sender: UIBarButtonItem) {
        let missingMothers = modelC.findMissingSheeps()
        let missingSheeps = missingMothers + modelC.findMissingLambs(list: missingMothers + modelC.workingSet)
        for sheep in missingSheeps{
            sheep.groupMemberships[2] = true
        }
        showMissingSheeps = true
        
        modelC.sheeps.sort() {
            if $0.groupMemberships[2] && !$1.groupMemberships[2]{
                return true
            }
            var missingLamb = false
            for lamb in $0.lambs{
                if lamb.groupMemberships[2] {
                    missingLamb = true
                    break
                }
            }
            for lamb in $1.lambs{
                if lamb.groupMemberships[2] {
                    missingLamb = false
                    break
                }
            }
            
            return missingLamb
        }
        tableView.reloadData()
    }
    
    @IBOutlet weak var leftToolBar: UIBarButtonItem!
    
    @IBAction func leftToolBarPressed(_ sender: UIBarButtonItem) {
        modelC.workingSetActive = !modelC.workingSetActive
        if (modelC.workingSetActive){
            leftToolBar.title = "Home"
            self.title = "Working Set"
        }else{
            leftToolBar.title = "Go to working set"
            self.title = "Sheep List"
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
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
            modelC.sheeps = []
        }
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 88
    }
    //laksjlkjsad
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !tableView.isEditing && !modelC.workingSetActive
    }
    //ojadsos
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
            detailedSheepViewController.sheep = modelC.sheeps[tableView.indexPathForSelectedRow!.row]
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
            tableView.reloadRows(at: [selectedIndexPath], with: UITableViewRowAnimation.automatic )
        } else {
            let newIndexPath = IndexPath(row: modelC.sheeps.count-1, section: 0)
            tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.bottom )
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return modelC.filteredSheeps.count
        }else if modelC.workingSetActive && !isAddingToWorkingSet{
            return modelC.workingSet.count
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
        }else if modelC.workingSetActive && !isAddingToWorkingSet{
            sheep = modelC.workingSet[indexPath.row]
        }else{
            sheep = modelC.sheeps[indexPath.row]
        }
        cell.SheepIDLabel?.text = sheep.sheepID
        cell.SheepIDLabel.textColor = sheep.activeGroupMemberships().first?.color

        
        if modelC.workingSetActive && !isAddingToWorkingSet && !showMissingSheeps{
            return cell
        }
        
        for (index,lamb) in sheep.lambs.enumerated() {
            if cell.LambStackView.subviews.count > index{
                let labelView = cell.LambStackView.arrangedSubviews[index] as! UILabel
                labelView.text = lamb.sheepID
                labelView.textColor = lamb.activeGroupMemberships().first?.color
            }else{
                let label = UILabel()
                label.text = lamb.sheepID
                label.textColor = lamb.activeGroupMemberships().first?.color
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
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isAddingToWorkingSet && modelC.workingSetActive{
            modelC.workingSet.append(modelC.filteredSheeps[tableView.indexPathForSelectedRow!.row])
            if searchController.isActive && searchController.searchBar.text != "" {
                modelC.filteredSheeps.remove(at: tableView.indexPathForSelectedRow!.row)
                tableView.deleteRows(at: [tableView.indexPathForSelectedRow!], with: UITableViewRowAnimation.right)
            }
        }
    }
    
    func updateHeader() -> String{
        
        let numberOfLambs = modelC.countLambsInWorkingSet()
        let numberOfSheeps = modelC.workingSet.count - numberOfLambs
        return  "Sheeps: " + String(numberOfSheeps) + " lambs: " + String(numberOfLambs)
}
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return updateHeader()
    }
    
    
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
            modelC.deleteSheep(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension SheepListTableViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        if modelC.workingSetActive && isAddingToWorkingSet {
            modelC.filteredSheeps = modelC.everyOneByThemSelf.filter { sheep in
                return subSecuence(is: searchText.lowercased(), subSecuenceOff: sheep.sheepID!.lowercased())
            }
            
        }else{
            modelC.filteredSheeps = modelC.sheeps.filter { sheep in
                for lamb in sheep.lambs {
                    if subSecuence(is: searchText.lowercased(), subSecuenceOff: lamb.sheepID!.lowercased()){
                        return true
                    }
                }
                return subSecuence(is: searchText.lowercased(), subSecuenceOff: sheep.sheepID!.lowercased())
            }
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
}
