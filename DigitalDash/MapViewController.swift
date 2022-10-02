//
//  MapViewController.swift
//  DigitalDash
//
//  Created by Nicholas Blackburn on 8/18/17.
//  Copyright © 2017 Nicholas Blackburn. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreMotion
import MapKit
import CoreLocation

var counter: Int16?

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // Data model connection
    lazy var coreDataModel = CoreDataModel()
    
    // Declare results array to store entities as NSManagedObjects
    var results: [NSManagedObject] = []
    
    // Create Pedometer instance
    let pedometer = CMPedometer()
    
    // IBOutlets
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pauseText: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: CircleLabelView!
    
    // Location Manager
    var locationManager: CLLocationManager!
    
    // Declare timer variables
    var timer = Timer()
    var startTime = 0.0
    var currentTime = 0.0
    var timePassed = 0.0
    var timerActive = false
    
    // Declare date variables
    var dateShortString: String?
    var startHours: String?
    var endHours: String?
    var currentDate: String?
    
    // Declare motion variables
    var steps: Int? = 0
    var distance: Double? = 0.0
    var averageSpeed: Double? = 0.0
    var exerciseLocations: [CLLocation] = []
    
    // Load view
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start mapView updates
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType.standard
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        // Start location updates
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if (authorizationStatus == .notDetermined || authorizationStatus == .denied) {
            locationManager.requestAlwaysAuthorization()
        }
        locationManager.startUpdatingLocation()
        
        // Start the timer
        activateTimer()
        
        // Start the pedometer
        activatePedometer()
        
        // Show Date
        let currentDateFormat = DateFormatter()
        currentDateFormat.dateStyle = .long
        currentDateFormat.timeStyle = .long
        let date = Date()
        currentDate = currentDateFormat.string(from: date)
        
        // Store Date without timeStyle
        let currentDateShort = DateFormatter()
        currentDateShort.dateStyle = .long
        dateShortString = currentDateShort.string(from: date)
    }
    
    // Track location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Prevent location manager from updating while map is still loading
        if (currentTime > 3) {
            // Loop through locations
            for newLocation in locations {
                // Set old location to the last location in array
                if let oldLocation = locations.last {
                    // Store coordinates of old and new location
                    let coordinates = [oldLocation.coordinate, newLocation.coordinate]
                    // Assign polyline to the coordinates
                    let polyline = MKPolyline(coordinates: coordinates, count: 2)
                    // Add polyline to the map view
                    mapView.add(polyline)
                }
                // Add the new location to the exerciseLocations array
                exerciseLocations.append(newLocation)
            }
        }
    }
    
    // Draw current route
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Prevent polyline from drawing while map is still loading
        if (currentTime > 3) {
            // Overlay is a polyline
            if (overlay is MKPolyline) {
                // Draw polyline with renderer as red line
                let polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.strokeColor = UIColor.red
                polylineRenderer.lineWidth = 5
                return polylineRenderer
            }
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
 
    // Activate the timer
    func activateTimer() {
        // Show start time
        let dateTimeStart = DateFormatter()
        dateTimeStart.timeStyle = .medium
        dateTimeStart.doesRelativeDateFormatting = true
        let date = Date()
        startHours = dateTimeStart.string(from: date)
        
        // Invalidate timer
        timer.invalidate()
        
        // Calculate start time
        startTime = Date().timeIntervalSinceReferenceDate - timePassed
        
        // Start scheduled timer
        timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        // Timer active
        timerActive = true
    }
    
    // Activate the pedometer
    func activatePedometer() {
        // Start pedometer updates
        pedometer.startUpdates(from: Date(), withHandler: {
            (data: CMPedometerData?, error: Error?) -> Void in
            if let data = data {
                // DispatchQueue on main
                DispatchQueue.main.async(execute: { () -> Void in
                    if (error == nil)
                    {
                        // Store data into predefined variables
                        self.steps = data.numberOfSteps as Int?
                        self.distance = data.distance as Double?
                    }
                    else {
                        print(error!)
                    }
                }
            )
            }
        })
    }
    
    // Convert meters to miles
    func metersToMiles(meters: Double) -> Double {
        let mileRatio = 1609.344
        let miles: Double = meters / mileRatio
        return miles
    }
    
    // Convert meters per second to minutes per mile
    func minutesPerMile(pace: Double) -> String {
        var metersPerSecondToMinutesPerMile = 0.0
        let minutesRatio = 26.8224
        if pace != 0 {
            metersPerSecondToMinutesPerMile = minutesRatio / pace
        }
        let minutes = Int(metersPerSecondToMinutesPerMile)
        let seconds = Int(metersPerSecondToMinutesPerMile * 60) % 60
        return String(format: "%02d:%02d minutes/mile", minutes, seconds)
    }
    
    // Average speed calculator
    func averageSpeedCalc(distance: Double, time: Int) -> Double {
        let averageSpeed = distance / Double(time)
        return averageSpeed
    }
    
    // Update the timer
    func updateTimer() {
        // Calculate current time
        currentTime = Date().timeIntervalSinceReferenceDate - startTime
        
        // Update timer label
        timerLabel.text = timeToString(time: TimeInterval(currentTime))
        
        // Update distance label
        if (self.distance != nil) {
            self.distanceLabel.text = String(format: "%.3f mi", metersToMiles(meters: distance!))
        }
        else {
            self.distanceLabel.text = "0.000 mi"
        }
    }
    
    // Convert timer from Int to String in hours minutes and seconds
    func timeToString(time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    // Stop the timer
    @IBAction func stopTimer(_ sender: UIButton) {
        // Show stop time
        let dateTimeEnd = DateFormatter()
        dateTimeEnd.timeStyle = .medium
        dateTimeEnd.doesRelativeDateFormatting = true
        let date = Date()
        endHours = dateTimeEnd.string(from: date)
        
        // Invalidate timer
        timer.invalidate()
        
        // Stop the pedometer
        pedometer.stopUpdates()
        
        // Store temp variables
        var stepsString: String
        var distanceString: String
        var averageSpeedString: String
        
        // Store pedometer values in String form
        if (self.steps != nil) {
            stepsString = String(format: "%i", self.steps!)
        }
        else {
            stepsString = "0"
        }
        if (self.distance != nil) {
            distanceString = String(format: "%.3f", self.metersToMiles(meters: self.distance!))
        }
        else {
            distanceString = "0"
        }
        if (self.distance != nil || self.currentTime != 0) {
            averageSpeed = averageSpeedCalc(distance: distance!, time: Int(currentTime))
            if (self.averageSpeed != nil) {
                averageSpeedString = String(describing: self.minutesPerMile(pace: self.averageSpeed!))
            }
            else {
                averageSpeedString = "0"
            }
        }
        else {
            averageSpeedString = "0"
        }
        
        // Calculate time passed
        timePassed = Date().timeIntervalSinceReferenceDate - startTime
        
        // Timer not active
        timerActive = false
        
        // Access core data context
        let context = coreDataModel.persistentContainer.viewContext
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ExerciseLoop")
        
        // Store results from fetch request in results array
        do {
            results = try context.fetch(fetchRequest)
            // Set counter to 1 initially, otherwise increase counter by 1
            if (results.count == 0) {
                counter = 1
            }
            else {
                counter = counter! + 1
            }
        } catch {
            fatalError("Failed to fetch exercise loops: \(error)")
        }
        
        // Core data saving for ExerciseLoop
        let entity = NSEntityDescription.entity(forEntityName: "ExerciseLoop", in: context)
        let exerciseLoop = NSManagedObject(entity: entity!, insertInto: context)
        
        // Set values to exerciseLoop and insert entity into context
        exerciseLoop.setValue(currentTime, forKeyPath: "time")
        exerciseLoop.setValue(startHours, forKeyPath: "startHours")
        exerciseLoop.setValue(endHours, forKeyPath: "endHours")
        exerciseLoop.setValue(currentDate, forKeyPath: "date")
        exerciseLoop.setValue(dateShortString, forKey: "dateShort")
        exerciseLoop.setValue(counter!, forKeyPath: "exerciseID")
        exerciseLoop.setValue(stepsString, forKeyPath: "steps")
        exerciseLoop.setValue(distanceString, forKeyPath: "distance")
        exerciseLoop.setValue(averageSpeedString, forKeyPath: "averageSpeed")
        exerciseLoop.setValue(exerciseLocations, forKey: "locationPoints")
        
        // Save to core data
        coreDataModel.saveContext()
        
        // Segue from Map to WorkoutDetail
        self.performSegue(withIdentifier: "MapToWorkoutDetail", sender: nil)
    }
    
    // Memory warnings
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
