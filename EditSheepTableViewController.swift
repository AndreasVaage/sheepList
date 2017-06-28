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
    var sheep = Sheep(sheepID: nil)
    var lastAddedLamb: String?
    
    let sheepSection = 0
    let lambSection = 1
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var addLambButton: UIButton!
    @IBAction func addLambButtonPressed(_ sender: UIButton) {
        let newIndexPath = IndexPath(row: sheep.lambs.count ,section: lambSection)
        var sheepID: String? = nil
        if lastAddedLamb != nil {
            if let lastAddedLambInt = Int(lastAddedLamb!){
                lastAddedLamb = String(describing: lastAddedLambInt+1)
                sheepID = lastAddedLamb
            }
        }
        sheep.lambs.append(Sheep(sheepID: sheepID, birthday: Date()))
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        updateLambHeader()
        updateLambFooter()
        tableView.scrollToBottom(ofSection: lambSection)
    }
    @IBAction func sheepIDTextEditingChanged(_ sender: UITextField) {
        guard let cell = sender.superview?.superview as? EditSheepTableViewCell else{
            fatalError("Unknown cell")
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            fatalError("Unknown indexpath")
        }
        guard let enteredText = sender.text else {
            return // nothing was entered
        }
        
        switch indexPath.section {
        case sheepSection:
            sheep.sheepID = enteredText
        case lambSection:
            sheep.lambs[indexPath.row].sheepID = enteredText
            lastAddedLamb = enteredText
        default:
            fatalError("Unknown section")
        }
        updateSaveButtonState()
    }
    
    
    @IBAction func birthdayPickerChanged(_ sender: UIDatePicker) {
        let cell = sender.superview?.superview as! EditSheepTableViewCell
        updateBirthdayLabel(cell: cell, date: sender.date)
    }
    
    var isDatePickerHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveButtonState()
        updateLambFooter()
        //updateLambHeader()
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
        case sheepSection:
            return 1
        case lambSection:
            return sheep.lambs.count
        default:
            return 0
        }
    }

    // Display rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditSheepCell") as? EditSheepTableViewCell else {
            fatalError("Could not dequeue a cell")
        
        }
        var birthday: Date? = nil
        switch indexPath.section {
        case sheepSection:
            cell.sheepIDTextField.placeholder = "Sheep ID"
            cell.sheepIDTextField.text = sheep.sheepID
            cell.notesTextView.text = sheep.notes

            if let sheepBirthday = sheep.birthday {
                cell.birthdayDatePicker.date = sheepBirthday
                birthday = sheepBirthday
            }
        case lambSection:
            cell.sheepIDTextField.placeholder = "Lamb ID"
            cell.sheepIDTextField.text = sheep.lambs[indexPath.row].sheepID
            cell.notesTextView.text = sheep.lambs[indexPath.row].notes
            
            if let lambBirthday = sheep.lambs[indexPath.row].birthday {
                cell.birthdayDatePicker.date = lambBirthday
                birthday = lambBirthday
            }
            
        default:
            fatalError("Unknown section")
        }
        updateBirthdayLabel(cell: cell, date: birthday )
        return cell
    }
    
    func updateBirthdayLabel(cell: EditSheepTableViewCell, date: Date?) {
        if let date = date{
            cell.birthdayLabel.text = Sheep.birthdayFormatter.string(from: date)
        }else{
        cell.birthdayLabel.text = "Unknown"
        }
    }

    

        // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
        guard Sheep.isCorrectFormat(for: sheep) else {
            fatalError("Trying to save sheep with wrong format")
        }
    }
    
    func updateSaveButtonState() {
        if Sheep.isCorrectFormat(for: sheep) {
            saveButton.isEnabled = true
        }else{
            saveButton.isEnabled = false
        }
    }
    
    //give each section a title
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == lambSection {
            if sheep.lambs.count == 1 {
                return " 1 lamb"
            }else{
                return  String(sheep.lambs.count) + " lambs"
            }
        }
        return nil
    }
    
    func updateLambFooter() {
        if sheep.lambs.count >= 9 {
            addLambButton.titleLabel?.text = "max number of lambs"
            addLambButton.isEnabled = false
        }else{
            addLambButton.titleLabel?.text = "Register new lamb"
            addLambButton.isEnabled = true
        }
    }
    
    func updateLambHeader(){
        
        let header = tableView.headerView(forSection: lambSection)
        let numberOfLambs = sheep.lambs.count
        var headerText = String(numberOfLambs) + " lamb"
        if numberOfLambs != 1 {
            headerText += "s"
        }
        if numberOfLambs == 9 {
            headerText += " (max)"
        }
        header?.textLabel?.text = headerText
        header?.textLabel?.sizeToFit()
    }
    
    //set row higth for each cell
    override func tableView(_ tableView: UITableView, heightForRowAt
        indexPath: IndexPath) -> CGFloat {
        let normalCellHeight = CGFloat(160)
        switch(indexPath.section) {
        case sheepSection: //Sheep Cell
            return normalCellHeight
            //return isEndDatePickerHidden ? normalCellHeight :
            //largeCellHeight
        case lambSection: //Lamb Cell
            return normalCellHeight
            //return isEndDatePickerHidden ? normalCellHeight :
            //largeCellHeight
        default: return normalCellHeight
        }
    }
    
    //EDITING
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == lambSection {
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
            sheep.lambs.remove(at: indexPath.row)
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
