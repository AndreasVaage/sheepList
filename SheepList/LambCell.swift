//
//  LambCell.swift
//  SheepList
//
//  Created by Andreas Våge on 29.06.2017.
//
//
import UIKit

class LambCell: UITableViewCell {
    
    @IBOutlet weak var lambIDLabel: UITextField!
    @IBOutlet weak var DateLabel: UILabel!
    
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
        
        self.lambIDLabel.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction()
    {
        self.lambIDLabel.resignFirstResponder()
    }

}
