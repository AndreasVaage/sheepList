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
    var isDatePickerHidden = true
    
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
        guard let cell = sender.superview?.superview as? UITableViewCell else{
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
        updateBirthdayLabel(date: sender.date)
    }
    
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
            return 3
        case lambSection:
            return sheep.lambs.count
        default:
            return 0
        }
    }

    // Display rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath{
        case [sheepSection,0]: // sheepID
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditSheepCell") as? EditSheepTableViewCell else {
                fatalError("Could not dequeue a cell")
            }
            cell.sheepIDTextField.text = sheep.sheepID
            return cell
        case [sheepSection,1]: //datepicker
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DateCell") as? DateTVCell else {
                fatalError("Could not dequeue a cell")
            }
            if let sheepBirthday = sheep.birthday {
                cell.datePicker.date = sheepBirthday
                cell.dateLabel.text = Sheep.birthdayFormatter.string(from: sheepBirthday)
            }else{
                cell.dateLabel.text = "Unknown"
            }
            return cell
        case [sheepSection,2]: // notes
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell") as? TextViewCell else {
                fatalError("Could not dequeue a cell")
            }
            cell.notesTextView.text = sheep.notes
            cell.notesTextView.delegate = self
            return cell
        default: // lambs
            print("section \(indexPath.section)")
            print("row \(indexPath.row)")
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LambCell") as? LambCell else {
                fatalError("Could not dequeue a cell")
            }
            
            cell.lambIDLabel.text = sheep.lambs[indexPath.row].sheepID
            if let sheepBirthday = sheep.lambs[indexPath.row].birthday {
                cell.DateLabel.text = Sheep.birthdayFormatter.string(from: sheepBirthday)
            }else{
                cell.DateLabel.text = "Unknown"
            }
            cell.accessoryType = UITableViewCellAccessoryType.detailDisclosureButton
            return cell
        }
    }
    
    func updateBirthdayLabel(date: Date?) {
        guard let cell = tableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? DateTVCell else{fatalError("Wrong cell")}
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
        switch indexPath.section {
        case sheepSection:
            if indexPath.row == 1 {
                isDatePickerHidden = !isDatePickerHidden
                let cell = tableView.cellForRow(at: indexPath) as! DateTVCell
                let color = isDatePickerHidden ? .black : tableView.tintColor
                cell.dateLabel.textColor = color
                cell.descriptionLabel.textColor = color
                
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        case lambSection:
            break

        default:
            break
        }
    }
    
    //set row higth for each cell
    override func tableView(_ tableView: UITableView, heightForRowAt
        indexPath: IndexPath) -> CGFloat {
        let headerCellHeight = CGFloat(60)
        let normalCellHeight = CGFloat(44)
        let largeCellHeight = CGFloat(200)
        
        switch indexPath {
        case [sheepSection,0]:
            return headerCellHeight
        case [sheepSection,1]:
            return isDatePickerHidden ? normalCellHeight : largeCellHeight
        case [sheepSection,2]:
            tableView.estimatedRowHeight = normalCellHeight
            return UITableViewAutomaticDimension
        default:
            return normalCellHeight
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

extension EditSheepTableViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
