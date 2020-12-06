//
//  NotesViewController.swift
//  TimeTrack
//
//  Created by Kenneth Jones on 12/6/20.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    var daily: Daily?
    
    @IBOutlet weak var notesTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = daily?.action
        notesTextView.text = daily?.notes
        if notesTextView.text.isEmpty {
            notesTextView.becomeFirstResponder()
        }
    }
    
    @IBAction func saveNotes(_ sender: UIBarButtonItem) {
        if let notes = notesTextView.text,
           !notes.isEmpty {
            daily?.notes = notes
            
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                NSLog("Error saving managed object context: \(error)")
            }
        }
        navigationController?.popViewController(animated: true)
    }
}
