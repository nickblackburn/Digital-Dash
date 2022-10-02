//
//  WorkoutDetailViewController.swift
//  DigitalDash
//
//  Created by Nicholas Blackburn on 8/26/17.
//  Copyright © 2017 Nicholas Blackburn. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit
import CoreLocation

class WorkoutDetailViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // IBOutlets
    @IBOutlet weak var exerciseIDLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var startHoursLabel: UILabel!
    @IBOutlet weak var endHoursLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var stepsLabel: CircleLabelView!
    @IBOutlet weak var distanceLabel: CircleLabelView!
    @IBOutlet weak var averageSpeedLabel: CircleLabelView!
    @IBOutlet weak var mapView: MKMapView!
    
    // Data model connection
    lazy var coreDataModel = CoreDataModel()
    
    // Array of CLLocation to store values of exerciseLocations
    var exerciseLocations: [CLLocation] = []
    
    // Declare array to store entities as NSManagedObjects
    var results: [NSManagedObject] = []
    var result: NSManagedObject?
    
    // Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // View will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Access core data context
        let context = coreDataModel.persistentContainer.viewContext
        
        // Create fetch request to update new table data
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ExerciseLoop")

        
        // Sort descriptors for sorting the table view
        let sortDescriptorByID = NSSortDescriptor(key: "exerciseID", ascending: false,
                                                  selector: #selector(NSString.localizedStandardCompare))
        fetchRequest.sortDescriptors = [sortDescriptorByID]
        
        // try to fetch ExerciseLoop context from data model and store in results array
        do {
            results = try context.fetch(fetchRequest) as! [ExerciseLoop]
            
            if (resultsToWorkoutDetail) {
                result = self.results[rowClicked!]
                resultsToWorkoutDetail = false
            }
            else {
                result = self.results[0]
                exerciseIDLabel.text = "Workout " + String(describing: result?.value(forKeyPath: "exerciseID")!)
            }
            
            // Update Labels
            exerciseIDLabel.text = "Workout " + String(describing: result!.value(forKeyPath: "exerciseID")!)
            dateLabel.text = " Date: " + String(describing: result!.value(forKeyPath: "dateShort")!)
            startHoursLabel.text = " Start Hours: " + String(describing: result!.value(forKeyPath: "startHours")!)
            endHoursLabel.text = " End Hours: " + String(describing: result!.value(forKeyPath: "endHours")!)
            let timeVal = result!.value(forKeyPath: "time")
            timeLabel.text = " Time: " + timeToString(time: timeVal as! TimeInterval)
            stepsLabel.text = " Steps: " + String(describing: result!.value(forKeyPath: "steps")!)
            distanceLabel.text = " Distance: " + String(describing: result!.value(forKeyPath: "distance")!) + " miles"
            averageSpeedLabel.text = " Average Speed: " + String(describing: result!.value(forKeyPath: "averageSpeed")!)
            
            // Store locationPoints locations into the exerciseLocations array
            exerciseLocations = result!.value(forKeyPath: "locationPoints") as! [CLLocation]
            
        } catch {
            fatalError("Failed to fetch exercise loops: \(error)")
        }
        
        // Set up map view
        mapView.delegate = self
        mapView.showsUserLocation = false
        mapView.mapType = MKMapType.standard
        // Draw polyline on map
        drawPolyline()
        
    }
    
    // Set new and old polyline coordinates and add polyline to map view
    func drawPolyline() {
        // Loop through exerciseLocations array with index
        for (index, _) in exerciseLocations.enumerated() {
            // Set old location to previous index and new location to current index
            if (index > 0) {
                let oldLocation = exerciseLocations[index - 1].coordinate
                let newLocation = exerciseLocations[index].coordinate
                // Store coordinates of old and new location
                let oldLocationCoord = oldLocation
                let newLocationCoord = newLocation
                let coordinates = [oldLocationCoord, newLocationCoord]
                // Set map view region
                mapView.setRegion(MKCoordinateRegionMake(oldLocationCoord, MKCoordinateSpanMake(0.01, 0.01)), animated: true)
//                testing
//                print("\(coordinates)")
                // Assign polyline to the coordinates
                let polyline = MKPolyline(coordinates: coordinates, count: 2)
                // Add polyline to the map view
                mapView.add(polyline)
            }
        }
    }
    
    // Draw route on map
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Overlay is a polyline
        if (overlay is MKPolyline) {
            // Draw polyline with renderer as red line
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    // Convert timer from Int to String in hours minutes and seconds
    func timeToString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02d hours %02d minutes %02d seconds", hours, minutes, seconds)
    }
    
    // Home button tapped
    @IBAction func HomeTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "WorkoutDetailToHome", sender: nil)
    }
    
    // Back button tapped
    @IBAction func BackTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "WorkoutDetailToResults", sender: nil)
    }
   
    // Memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Portrait mode only
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // Does not autorotate
    override var shouldAutorotate: Bool {
        return false
    }
}
