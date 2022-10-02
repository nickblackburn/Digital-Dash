//
//  ResultsViewController.swift
//  DigitalDash
//
//  Created by Nicholas Blackburn on 8/20/17.
//  Copyright © 2017 Nicholas Blackburn. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// Helper variables
var resultsToWorkoutDetail = false
var rowClicked: Int?

class ResultsViewController: UITableViewController {
    
    // Table view
    @IBOutlet var ResultsTableView: UITableView!
    
    // Data model connection
    lazy var coreDataModel = CoreDataModel()
    
    // Declare array to store entities as NSManagedObjects
    var results: [NSManagedObject] = []
    
    // Index path
    var path: IndexPath? = nil
    
    // Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // Appear view
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access core data context
        let context = coreDataModel.persistentContainer.viewContext
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ExerciseLoop")
        
        // Sort descriptors for sorting the table view
        let sortDescriptorByID = NSSortDescriptor(key: "exerciseID", ascending: false,
                                              selector: #selector(NSString.localizedStandardCompare))

        fetchRequest.sortDescriptors = [sortDescriptorByID]
        
        // Store results from fetch request in results array
        do {
            results = try context.fetch(fetchRequest)
//            testing
//            print("number of results: \(results.count)")
//            
//            for result in results as! [ExerciseLoop] {
//                print("\(result.exerciseID)")
//                print("\(result.time)")
//            }
        } catch {
            fatalError("Failed to fetch exercise loops: \(error)")
        }
        
        // Reload table view data
        ResultsTableView.reloadData()
    }
    
    // Home tapped
    @IBAction func HomeTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "ResultsToHome", sender: nil)
    }
    
    // Memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Table view number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Table view number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    // Table view cell for row at
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cell indentifier
        let cellIdentifier = "ExerciseIDViewCell"
        
        // Dequeue reusuable cell with cell identifier at index path
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ExerciseIDViewCell
        
        // Check cell for nil
        if cell == nil {
            // Assign cell to the cell identifier
            cell = ExerciseIDViewCell(style: UITableViewCellStyle.value2, reuseIdentifier: cellIdentifier)
        }
        
        // Fetches exercise loop at specific indexPath row
        let result = results[indexPath.row]
        
        // Show label with results
        cell?.ExerciseIDLabel.text = "Workout " + String(describing: result.value(forKeyPath: "exerciseID")!)
        cell?.ExerciseIDSubtitle.text = result.value(forKeyPath: "date") as? String
        
        return cell!
    }
    
    // Can delete a workout
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Commit editing style - delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // Access core data context
        let context = coreDataModel.persistentContainer.viewContext
        
        // Store indexPath in path
        path = indexPath
        
        // Swipe right to left for delete
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // Workout results that user wants to delete
            let workoutToDelete = results[indexPath.row]
            
            // Loop through results
            for result in results as! [ExerciseLoop] {
                // Results matches workout user wants to delete
                if (result == workoutToDelete) {
                    // Workout exerciseID
                    let workoutID = result.exerciseID
                    
                    // Set up delete and cancel alerts
                    let alert = UIAlertController(title: "Delete Workout", message: "Are you sure you want to delete Workout \(workoutID)?", preferredStyle: .actionSheet)
                    let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteWorkout)
                    let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteWorkout)
                    
                    // Add alerts
                    alert.addAction(DeleteAction)
                    alert.addAction(CancelAction)
                    
                    // Present alerts
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        // Create fetch request to update new table data
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ExerciseLoop")
        
        // Sort descriptors for sorting the table view
        let sortDescriptorByID = NSSortDescriptor(key: "exerciseID", ascending: false,
                                                  selector: #selector(NSString.localizedStandardCompare))
        fetchRequest.sortDescriptors = [sortDescriptorByID]

        // try to fetch ExerciseLoop context from data model and store in results array
        do {
            results = try context.fetch(fetchRequest) as! [ExerciseLoop]
//            testing
//            print("number of results: \(results.count)")
//            
//            for result in results as! [ExerciseLoop] {
//                print("\(result.exerciseID)")
//                print("\(result.time)")
//            }
        } catch {
            fatalError("Failed to fetch exercise loops: \(error)")
        }
        
        // Reload table view data
        ResultsTableView.reloadData()
    }
    
    // Delete alert handler
    func handleDeleteWorkout(alertAction: UIAlertAction!) -> Void {
        
        // Access core data context
        let context = coreDataModel.persistentContainer.viewContext
        
        // Delete object at row user wants to delete
        context.delete(results[(path?.row)!])
        
        // Save core data model
        coreDataModel.saveContext()
        
        // Remove object from results array
        self.results.remove(at: (path?.row)!)
        
        // Delete row from table view
        ResultsTableView.deleteRows(at: [path!], with: .automatic)
        
        // Set path to nil
        path = nil
    }
    
    // Cancel alert handler
    func cancelDeleteWorkout(alertAction: UIAlertAction!) {
        path = nil
    }
    
    // Row selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resultsToWorkoutDetail = true
        rowClicked = indexPath.row
        ResultsTableView.deselectRow(at: indexPath, animated: true)
        
//        testing
//        print("Selected row: \(rowClicked!)")
        
        let workoutDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ResultsToWorkoutDetail") as! WorkoutDetailViewController
        
        self.navigationController?.pushViewController(workoutDetailViewController, animated: true)
    }
}
