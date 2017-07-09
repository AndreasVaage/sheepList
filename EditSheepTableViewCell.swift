//
//  EditSheepTableViewCell.swift
//  SheepList
//
//  Created by Andreas Våge on 24.06.2017.
//
//

import UIKit

class EditSheepTableViewCell: UITableViewCell {
    @IBOutlet weak var sheepIDTextField: UITextField!
    
    // Done buttton
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(LambCell.doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.sheepIDTextField.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction()
    {
        self.sheepIDTextField.resignFirstResponder()
    }

}
