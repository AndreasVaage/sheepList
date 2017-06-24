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
    //var lambs = [Sheep]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedSheeps = Sheep.loadSheeps() {
            sheeps = savedSheeps
        } else {
            sheeps = Sheep.loadSampleSheeps()
        }
        navigationItem.leftBarButtonItem = editButtonItem
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let detailedSheepViewController = segue.destination
                as! DetailedSheepViewController
            let indexPath = tableView.indexPathForSelectedRow!
            let selectedSheep = sheeps[indexPath.row]
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
        return sheeps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SheepCellIdentifier") as? SheepCell else {
            fatalError("Could not dequeue a cell")
            
        }
        
        let sheep = sheeps[indexPath.row]
        cell.SheepIDLabel?.text = sheep.sheepID
        
        for lamb in sheep.lambs {
            let label = UILabel()
            label.text = lamb.sheepID
            cell.LambStackView.addArrangedSubview(label)
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sheeps.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            Sheep.saveSheeps(sheeps)
        }
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
}
