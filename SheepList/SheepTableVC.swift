//
//  RootTVC.swift
//  SheepList
//
//  Created by Andreas Våge on 30.07.2017.
//
//

import UIKit

class SheepTableVC: UITableViewController {
    var sheeps = [Sheep]()
    var filteredSheeps = [Sheep]()
    let searchController = UISearchController(searchResultsController: nil)
    
    func deleteSheep(at index: Int){
        fatalError("Must override deleteSheep function")
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
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
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
        }else{
            sheep = sheeps[indexPath.row]
        }
        cell.SheepIDLabel?.text = sheep.sheepID
        cell.SheepIDLabel.textColor = sheep.activeGroupMemberships().first?.color
        
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
            deleteSheep(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension SheepTableVC: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        filteredSheeps = sheeps.filter { sheep in
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
}
