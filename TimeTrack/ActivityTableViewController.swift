//
//  ActivityTableViewController.swift
//  TimeTrack
//
//  Created by Kenneth Jones on 12/6/20.
//

import UIKit
import CoreData

protocol ActivityTableViewDelegate: class {
    func didAddAction()
}

class ActivityTableViewController: UITableViewController {
    
    weak var delegate: ActivityTableViewDelegate?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Activity> = {
        let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "activity", ascending: true)
        ]
        
        let moc = CoreDataStack.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            NSLog("Error fetching Activity objects: \(error)")
        }
        return frc
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath)

        cell.textLabel?.text = fetchedResultsController.object(at: indexPath).activity

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Start/Stop Activity", message: "Are you starting or stopping this action?", preferredStyle: .alert)
        
        let startAction = UIAlertAction(title: "Start", style: .default) { (_) in
            self.startActivity(indexPath: indexPath)
        }
        
        let stopAction = UIAlertAction(title: "Stop", style: .default) { (_) in
            self.stopActivity(indexPath: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(startAction)
        alert.addAction(stopAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true) {
            self.delegate?.didAddAction()
        }
    }
    
    func startActivity(indexPath: IndexPath) {
        guard let activity = fetchedResultsController.object(at: indexPath).activity else { return }
        Daily(action: "Start \(activity)", time: Date(), notes: nil)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    func stopActivity(indexPath: IndexPath) {
        guard let activity = fetchedResultsController.object(at: indexPath).activity else { return }
        Daily(action: "Stop \(activity)", time: Date(), notes: nil)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    @IBAction func createNewActivity(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Create New Activity", message: "Add a new activity to the list.", preferredStyle: .alert)
        
        var activityTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "New Activity:"
            textField.autocapitalizationType = .sentences
            activityTextField = textField
        }
        
        let addActivityAction = UIAlertAction(title: "Add Activity", style: .default) { (_) in
            
            guard let activityText = activityTextField?.text else { return }
            
            Activity(activity: activityText)
            
            do {
                try CoreDataStack.shared.mainContext.save()
            } catch {
                NSLog("Error saving managed object context: \(error)")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addActivityAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let activity = fetchedResultsController.object(at: indexPath)
            let moc = CoreDataStack.shared.mainContext
            moc.delete(activity)
            DispatchQueue.main.async {
                do {
                    try moc.save()
                    tableView.reloadData()
                } catch {
                    moc.reset()
                    NSLog("Error saving managed object context: \(error)")
                }
            }
        }
    }

}


extension ActivityTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case .move:
            guard let oldIndexPath = indexPath,
                let newIndexPath = newIndexPath else { return }
            tableView.deleteRows(at: [oldIndexPath], with: .automatic)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        @unknown default:
            break
        }
    }
}
