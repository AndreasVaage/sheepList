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

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    // return how many rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
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
        if indexPath.section == 0 {
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
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSheep" {
            let editSheepTableViewController = segue.destination
                as! EditSheepTableViewController
            let indexPath = tableView.indexPathForSelectedRow!
            var selectedSheep : Sheep? = nil
            if indexPath.section == 0 {
                selectedSheep = sheep
            }else{
                selectedSheep = sheep?.lambs[indexPath.row]
            }
            
            editSheepTableViewController.sheep = selectedSheep
        }
    }

    func updateBirthdayLabel(date: Date, cell: DetailedSheepCell) {
        cell.birthdayLabel.text = Sheep.birthdayFormatter.string(from: date)
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
