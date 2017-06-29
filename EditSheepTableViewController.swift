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
    var isDatePickerHidden = [Bool]()
    
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
        isDatePickerHidden.append(true)
        var newDateIndexPath = newIndexPath
        newDateIndexPath.row = newIndexPath.row + 1
        tableView.insertRows(at: [newIndexPath,newDateIndexPath], with: .automatic)
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
        let cell = sender.superview?.superview as! DateTVCell
        updateBirthdayLabel(cell: cell, date: sender.date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isDatePickerHidden.append(true)
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
            return 2
        case lambSection:
            return sheep.lambs.count*2
        default:
            return 0
        }
    }

    // Display rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row % 2 == 1{ // datepicker cell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell") as? DateTVCell else {
                fatalError("Could not dequeue a cell")
            }
            var tmp_sheep: Sheep?
            switch indexPath.section {
            case sheepSection:
                tmp_sheep = sheep
            case lambSection:
                tmp_sheep = sheep.lambs[(indexPath.row+1)/2-1]
            default:
                fatalError("Unknown section")
            }
            if let sheepBirthday = tmp_sheep?.birthday {
                cell.datePicker.date = sheepBirthday

            }
             updateBirthdayLabel(cell: cell, date: tmp_sheep?.birthday)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditSheepCell") as? EditSheepTableViewCell else {
            fatalError("Could not dequeue a cell")
        
        }
        
        switch indexPath.section {
        case sheepSection:
            cell.sheepIDTextField.placeholder = "Sheep ID"
            cell.sheepIDTextField.text = sheep.sheepID
            cell.notesTextView.text = sheep.notes
        case lambSection:
            cell.sheepIDTextField.placeholder = "Lamb ID"
            cell.sheepIDTextField.text = sheep.lambs[indexPath.row/2].sheepID
            cell.notesTextView.text = sheep.lambs[indexPath.row/2].notes
        default:
            fatalError("Unknown section")
        }
        return cell
    }
    func datePickerCell(for cell: EditSheepTableViewCell)-> DateTVCell{
        var indexPath = tableView.indexPath(for: cell)
        indexPath?.row = (indexPath?.row)! + 1
        return tableView.cellForRow(at: indexPath!) as! DateTVCell
    }
    func updateBirthdayLabel(cell: DateTVCell, date: Date?) {
        if let date = date{
            cell.dateLabel.text = Sheep.birthdayFormatter.string(from: date)
        }else{
        cell.dateLabel.text = "Unknown"
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
    // select cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pickerIndex = (indexPath.row+1)/2 - 1
        if indexPath.row % 2 == 1 {
            isDatePickerHidden[pickerIndex] = !isDatePickerHidden[pickerIndex]
            let cell = tableView.cellForRow(at: indexPath) as! DateTVCell
            
            let color = isDatePickerHidden[pickerIndex] ? .black : tableView.tintColor
            cell.dateLabel.textColor = color
            cell.descriptionLabel.textColor = color
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    //set row higth for each cell
    override func tableView(_ tableView: UITableView, heightForRowAt
        indexPath: IndexPath) -> CGFloat {
        let smallCellHeight = CGFloat(44)
        let normalCellHeight = CGFloat(160)
        let largeCellHeight = CGFloat(200)
        if indexPath.row % 2 == 0 { // sheep/lamb cell
            return normalCellHeight
        }else{ //datePicker cell
            if indexPath.section == sheepSection{
                return isDatePickerHidden[0] ? smallCellHeight : largeCellHeight
            }else{
            return isDatePickerHidden[(indexPath.row+1)/2 - 1] ? smallCellHeight : largeCellHeight
            }
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
            var dateIndexPath = indexPath
            dateIndexPath.row = indexPath.row + 1
            sheep.lambs.remove(at: indexPath.row)
            isDatePickerHidden.remove(at: dateIndexPath.row)
            tableView.deleteRows(at: [indexPath, dateIndexPath], with: .fade)
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
