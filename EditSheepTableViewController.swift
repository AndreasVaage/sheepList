//
//  EditSheepTableViewController.swift
//  SheepList
//
//  Created by Andreas Våge on 24.06.2017.
//
//

import UIKit

class EditSheepTableViewController: UITableViewController {

    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func sheepIDTextEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    @IBAction func birthdayPickerChanged(_ sender: UIDatePicker) {
        let cell = sender.superview?.superview as! EditSheepTableViewCell
        updateBirthdayLabel(cell: cell)
    }
    var isDatePickerHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveButtonState()
//        for cell in self.tableView.visibleCells as! [EditSheepTableViewCell]{
//            updateBirthdayLabel(cell: cell)
//        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    var sheep: Sheep?
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            if let numberOfRows = sheep?.lambs.count{
                return numberOfRows
            } else {
                return 1
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditSheepCell") as? EditSheepTableViewCell else {
            fatalError("Could not dequeue a cell")
            
        }
        if indexPath.section == 0 {
            if let sheep = sheep{
                cell.sheepIDTextField.text = sheep.sheepID
                cell.birthdayDatePicker.date = sheep.birthday
                updateBirthdayLabel(cell: cell)
                cell.notesTextView.text = sheep.notes
            }
            else{
                cell.sheepIDTextField.placeholder = "Sheep ID"
                //fatalError("No sheep")
            }
        }else{
            if let lamb = sheep?.lambs[indexPath.row]{
                cell.sheepIDTextField.text = lamb.sheepID
                cell.birthdayDatePicker.date = lamb.birthday
                updateBirthdayLabel(cell: cell)
                cell.notesTextView.text = lamb.notes
            }else{
                cell.sheepIDTextField.placeholder = "Lamb ID"
                //fatalError("No sheep/lambs")
            }
        }
        return cell
    }
    
    func updateBirthdayLabel(cell: EditSheepTableViewCell) {
        let date = cell.birthdayDatePicker.date
        cell.birthdayLabel.text = Sheep.birthdayFormatter.string(from: date)
    }

 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
        var sheepID: String?
        var birthday: Date?
        var notes: String?
        var lambs = [Sheep]()
        
        for indexPath in self.tableView.indexPathsForVisibleRows! {
            let cell = self.tableView.cellForRow(at: indexPath) as! EditSheepTableViewCell

            if indexPath.section == 0 {
                sheepID = cell.sheepIDTextField.text!
                birthday = cell.birthdayDatePicker.date
                notes = cell.notesTextView.text
            }else{
                let lambID = cell.sheepIDTextField.text!
                let birthday = cell.birthdayDatePicker.date
                let notes = cell.notesTextView.text
                lambs.append(Sheep(sheepID: lambID, birthday: birthday,notes: notes,lambs: []))
            }
        }
        sheep = Sheep(sheepID: sheepID!, birthday: birthday!, notes: notes, lambs: lambs)
    }
    
    func updateSaveButtonState() {
        var state = false
        for cell in self.tableView.visibleCells as! [EditSheepTableViewCell] {
            let text = cell.sheepIDTextField.text ?? ""
            if text.isEmpty {
                state = false
                break
            }else{
                state = true
            }
        }
        saveButton.isEnabled = state
    }
}
