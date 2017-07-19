//
//  DetailedSheepViewController.swift
//  SheepList
//
//  Created by Andreas Våge on 22.06.2017.
//
//

import UIKit

class DetailedSheepViewController: UITableViewController {
    var sheep: Sheep?
    var modelC: ModelController!
    let sheepSection = 0
    let lambSection = 1
    
    override func viewDidLoad() { // runs only one time: when the viewcontroller is created.
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sheep = modelC.sheeps[modelC.selectedSheep!]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    // return how many rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == sheepSection {
            return 1
        }else{
            if let numberOfRows = sheep?.lambs.count{
            return numberOfRows
            } else {
                fatalError("Could not load a sheep")
            }
        }
    }
    //what are the content of each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DetailedSheepCell") as? DetailedSheepCell else {
            fatalError("Could not dequeue a cell")
        }
        
        if indexPath.section == sheepSection {
            if let sheep = sheep{
                cell.sheepIDTextLabel.text = sheep.sheepID
                updateBirthdayLabel(date: sheep.birthday, cell: cell)
                cell.notesTextField.text = sheep.notes
            }
            else{
                fatalError("No sheep")
            }
            
        }else{
            if let lambs = sheep?.lambs{
                cell.sheepIDTextLabel.text = lambs[indexPath.row].sheepID
                updateBirthdayLabel(date: lambs[indexPath.row].birthday, cell: cell)
                cell.notesTextField.text = lambs[indexPath.row].notes
            }else{
                fatalError("No sheep/lambs")
            }
        }
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSheep" {
            let editSheepTableViewController = segue.destination
                as! EditSheepTableViewController
            let indexPath = tableView.indexPathForSelectedRow!
            if indexPath.section == sheepSection {
                editSheepTableViewController.sheep = sheep!
            }else{
                editSheepTableViewController.sheep = (sheep?.lambs[indexPath.row])!
            }
            editSheepTableViewController.lastSavedLamb = modelC.findLastSavedLambID()
            if tableView.indexPathForSelectedRow?.section == sheepSection {
                editSheepTableViewController.seguedFrom = "sheepList"
            }else{
                editSheepTableViewController.seguedFrom = "detailedSheep"
            }
        }
    }
    
    @IBAction func unwindToDetailedSheep(segue: UIStoryboardSegue) {
        guard segue.identifier == "SaveUnwindToDetailedSheep" else { return }
        let sourceViewController = segue.source as! EditSheepTableViewController
        
        let NewSheep = sourceViewController.sheep
        guard Sheep.isCorrectFormat(for: NewSheep) else {
            fatalError("Trying to save sheep with wrong format")
        }
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            switch selectedIndexPath.section {
            case sheepSection:
                sheep = NewSheep
            case lambSection:
                sheep?.lambs[selectedIndexPath.row] = NewSheep
            default:
                break
            }
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        
        } else {
            let newIndexPath = IndexPath(row: (sheep?.lambs.count)!, section: lambSection)
            sheep?.lambs.append(NewSheep)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
        tableView.scrollToBottom(ofSection: lambSection)
    }

    func updateBirthdayLabel(date: Date?, cell: DetailedSheepCell) {
        if let date = date {
            cell.birthdayLabel.text = Sheep.birthdayFormatter.string(from: date)
        }else{
            cell.birthdayLabel.text = "Unknown"
        }
        
    }
    //give each section a title
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Sheep"
        }else{
            return "Lambs"
        }
    }

}
