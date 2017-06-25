//
//  SheepListTableViewController.swift
//  SheepList
//
//  Created by Andreas Våge on 21.06.2017.
//
//

import UIKit

class SheepListTableViewController: UITableViewController {  //SheepCellDelegate
    var sheeps = [Sheep]()
    var filteredSheeps = [Sheep]()
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
            sheeps = savedSheeps
        } else {
            sheeps = Sheep.loadSampleSheeps()
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
            
            let selectedSheep: Sheep
            if searchController.isActive && searchController.searchBar.text != "" {
                selectedSheep = filteredSheeps[indexPath.row]
            }else{
                selectedSheep = sheeps[indexPath.row]
            }
            detailedSheepViewController.sheep = selectedSheep
        }
    }
    
    @IBAction func unwindToSheepList(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        let sourceViewController = segue.source as! EditSheepTableViewController
        
        if let sheep = sourceViewController.sheep {
            if let selectedIndexPath =
                tableView.indexPathForSelectedRow {
                sheeps[selectedIndexPath.row] = sheep
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                let newIndexPath = IndexPath(row: sheeps.count, section: 0)
                sheeps.append(sheep)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
        Sheep.saveSheeps(sheeps)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredSheeps.count
        }
        return sheeps.count
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
            sheep = filteredSheeps[indexPath.row]
        }else {
            sheep = sheeps[indexPath.row]
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
        return cell
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        filteredSheeps = sheeps.filter { sheep in
            for lamb in sheep.lambs {
                if subSecuence(is: searchText.lowercased(), subSecuenceOff: lamb.sheepID.lowercased()){
                    return true
                }
            }
            return subSecuence(is: searchText.lowercased(), subSecuenceOff: sheep.sheepID.lowercased())
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
    
//    bool isSubSequence(char str1[], char str2[], int m, int n)
//    {
//    int j = 0; // For index of str1 (or subsequence
//    
//    // Traverse str2 and str1, and compare current character
//    // of str2 with first unmatched char of str1, if matched
//    // then move ahead in str1
//    for (int i=0; i<n&&j<m; i++)
//    if (str1[j] == str2[i])
//    j++;
//    
//    // If all characters of str1 were found in str2
//    return (j==m);
//    }
    
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
            sheeps.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            Sheep.saveSheeps(sheeps)
        }
    }
}

extension SheepListTableViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
