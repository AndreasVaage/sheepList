//
//  EditSheepTableViewController.swift
//  SheepList
//
//  Created by Andreas Våge on 24.06.2017.
//
//

import UIKit

class EditSheepTableViewController: UITableViewController {

    // MARK: - Table view data source
    var sheep: Sheep?
    var lastAddedLamb: String?
    var numberOfLambs = 0
    
    let sheepSection = 0
    let lambSection = 1
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func addLambButtonPressed(_ sender: UIButton) {
        
        let newIndexPath = IndexPath(row: numberOfLambs ,section: 1)
        numberOfLambs += 1
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        updateLambHeader()
        updateLambFooter()
        tableView.scrollToBottom(ofSection: 1)
    }
    @IBAction func sheepIDTextEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    @IBAction func birthdayPickerChanged(_ sender: UIDatePicker) {
        let cell = sender.superview?.superview as! EditSheepTableViewCell
        updateBirthdayLabel(cell: cell)
    }
    @IBAction func sheepIDTextEditingFinnished(_ sender: UITextField){
        if let cell = sender.superview?.superview as? EditSheepTableViewCell{
            if tableView.indexPath(for: cell)?.section == 1{
                lastAddedLamb = sender.text
            }
        }else{
            print("DID nOT WORK")
        }
    }

    
    var isDatePickerHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let numberOfExistingLambs = sheep?.lambs.count{
            numberOfLambs = numberOfExistingLambs
        }
        updateSaveButtonState()
        //updateLambHeader()
       
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

    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return numberOfLambs
        default:
            return 0
        }
    }

    // Display rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = EditSheepTableViewCell()
        
        if indexPath.section == sheepSection {
            cell.sheepIDTextField.placeholder = "Sheep ID"
            if let sheep = sheep{
                cell.sheepIDTextField.text = sheep.sheepID
                cell.birthdayDatePicker.date = sheep.birthday
                cell.notesTextView.text = sheep.notes
            }
        }else{
            cell.sheepIDTextField.placeholder = "Lamb ID"
            if lastAddedLamb != nil && cell.sheepIDTextField.text == "" {
                if let lastAddedLambInt = Int(lastAddedLamb!){
                    lastAddedLamb = String(describing: lastAddedLambInt+1)
                    cell.sheepIDTextField.text = lastAddedLamb
                }
            }
            
            if let lambs = sheep?.lambs {
                if lambs.count > indexPath.row {
                    let lamb = lambs[indexPath.row]
                    cell.sheepIDTextField.text = lamb.sheepID
                    cell.birthdayDatePicker.date = lamb.birthday
                    cell.notesTextView.text = lamb.notes
                }
            }
        }
        updateBirthdayLabel(cell: cell)
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
    
    // Select a row
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
        var sheepID: String?
        var birthday: Date?
        var notes: String?
        var lambs = [Sheep]()
        guard let indexPaths = self.tableView.indexPathsForVisibleRows else {
            fatalError("There is a nil in our indexPaths!")
        }
        
        for indexPath in indexPaths {
            guard let cell = self.tableView.cellForRow(at: indexPath) as? EditSheepTableViewCell else {
                fatalError("There is a wolf in sheepCellClothing")
            }

            if indexPath.section == 0 {
                sheepID = cell.sheepIDTextField.text!
                birthday = cell.birthdayDatePicker.date
                notes = cell.notesTextView.text
            }else{
                guard let lambID = cell.sheepIDTextField.text else {
                    fatalError("LambID is nil when trying to save")
                }
                let birthday = cell.birthdayDatePicker.date
                let notes = cell.notesTextView.text
                lambs.append(Sheep(sheepID: lambID, birthday: birthday,notes: notes,lambs: []))
            }
        }
        if let lastLambID = lambs.last?.sheepID{
            lastAddedLamb = lastLambID
        }
        
        sheep = Sheep(sheepID: sheepID!, birthday: birthday!, notes: notes, lambs: lambs)
    }
    
    func updateSaveButtonState() {
        guard let indexPaths = tableView.indexPathsForVisibleRows  else {
            saveButton.isEnabled = false
            print("Skipped cheking that text was entered")
            return
        }
        var state = false
        for indexPath in indexPaths {
            let cell = tableView.cellForRow(at: indexPath) as! EditSheepTableViewCell
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
    
    //give each section a title
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            if numberOfLambs == 1 {
                return " 1 lamb"
            }else{
                return  String(numberOfLambs) + " lambs"
            }
        }
        return nil
    }
    
    func updateLambFooter() {
        let footer = tableView.footerView(forSection: lambSection)
        guard let addLambbutton = footer?.subviews.first as? UIButton else {
            fatalError("Could not find footerButton")
        }
        if numberOfLambs >= 9 {
            addLambbutton.titleLabel?.text = "max number of lambs"
            addLambbutton.isEnabled = false
        }else{
            addLambbutton.titleLabel?.text = "Register new lamb"
            addLambbutton.isEnabled = true
        }
    }
    
    func updateLambHeader(){
        
        let header = tableView.headerView(forSection: lambSection)
        if numberOfLambs == 1 {
            header?.textLabel?.text = " 1 lamb"
        }else{
            header?.textLabel?.text = String(numberOfLambs) + " lambs"
        }
        header?.textLabel?.sizeToFit()
    }
    
    //set row higth for each cell
    override func tableView(_ tableView: UITableView, heightForRowAt
        indexPath: IndexPath) -> CGFloat {
        let normalCellHeight = CGFloat(160)
        switch(indexPath.section) {
        case 0: //Sheep Cell
            return normalCellHeight
            //return isEndDatePickerHidden ? normalCellHeight :
            //largeCellHeight
        case 1: //Lamb Cell
            return normalCellHeight
            //return isEndDatePickerHidden ? normalCellHeight :
            //largeCellHeight
        default: return normalCellHeight
        }
    }
    
    //EDITING
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 1 {
            return true
        }else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            numberOfLambs -= 1
            tableView.deleteRows(at: [indexPath], with: .fade)
            updateLambHeader()
            updateLambFooter()
        }
    }

}

extension UITableView {
    
    func scrollToBottom(ofSection section: Int) {
        let rows = self.numberOfRows(inSection: section)
        
        let indexPath = IndexPath(row: rows - 1, section: section)
        self.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}
