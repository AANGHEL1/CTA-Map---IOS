//
//  MapViewController.swift
//  anghela-CTA
//
//  Created by Ana Anghel on 5/18/21.
//

import UIKit
import MapKit
import CoreLocation

let linesURL = ["http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=red&outputType=JSON",
    "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=blue&outputType=JSON",
    "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=brn&outputType=JSON",
    "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=g&outputType=JSON",
    "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=org&outputType=JSON",
    "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=p&outputType=JSON",
    "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=pink&outputType=JSON",
    "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=y&outputType=JSON"
]

let points = [
    (lat: 41.875680415958804, lon: -87.63124465942383, name: "LaSalle"),
    (lat: 41.876783, lon: -87.631695, name: "LaSalle/Van Buren"),
    (lat: 41.87813007930993, lon: -87.6293333622452, name: "Jackson"),
    (lat: 41.878125, lon: -87.627637, name: "Jackson"),
    (lat: 41.879611, lon: -87.626112, name: "Adams/Wabash"),
    (lat: 41.880809, lon: -87.627744, name: "Monroe"),
    (lat: 41.876863, lon: -87.628689, name: "Harold Washington Library-State/Van Buren"),
    (lat: 41.878860, lon: -87.633778, name: "Quincy")
    
]

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    
    class Stop {
        var line: String = ""
        var name: String = ""
        var finalDest: String = ""
        var delayed: String = ""
        var approaching: String = ""
        var latitude: String = ""
        var longitude: String = ""
        var id: String = ""
    }
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    var stops: [Stop] = []
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var message: UILabel!
    
    let locationManager = CLLocationManager()

    
    
    
    var regions = [CLCircularRegion]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for lines in linesURL {
            feed = lines
            loadData()
        }
        regions.removeAll()
    
        let status = locationManager.authorizationStatus
        if status == .denied || status == .restricted {
            message.text = "Location service not authorized"
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 1
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
 
            mapView.showsUserLocation = true
            
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                for p in points {
                    let center = CLLocationCoordinate2D(latitude: p.lat, longitude: p.lon)
                    let region = CLCircularRegion(center: center, radius: 4, identifier: p.name)
                    region.notifyOnEntry = true
                    region.notifyOnExit = true
                    regions.append(region)
                }
            } else {
                showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) &&
            !regions.isEmpty {
            for region in regions {
                locationManager.startMonitoring(for: region)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        for region in regions {
            locationManager.stopMonitoring(for: region)
        }
    }
    
    // delegate methods
    
    var annotation: MKAnnotation?
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        NSLog("(\(location.coordinate.latitude), \(location.coordinate.longitude))")
    
        
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        
        
        if mapView.isPitchEnabled {
            mapView.setCamera(MKMapCamera(lookingAtCenter: location.coordinate, fromDistance: 3500, pitch: 0, heading: 0), animated: true)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        mapView.removeAnnotations(mapView.annotations)
        NSLog("Region \(region)")
        message.text = "Region: \(region.identifier)"
        for stop in stops {
            let line = lineConvertor(line: stop.line)
            if stop.name == region.identifier {
                let latitude = CLLocationDegrees(stop.latitude)!
                let longitude = CLLocationDegrees(stop.longitude)!
                let location = CLLocation(latitude: latitude, longitude: longitude)
                message.text = message.text! + "\nTrain " + stop.id + " approaching at "+region.identifier + "\n Line: "+line
                let place = Place(location.coordinate, "Train " + stop.id + " to "+region.identifier)
                mapView.addAnnotation(place)
                annotation = place
            }
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        NSLog("Error \(error)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    func loadData(){
        guard let feedURL = URL(string: feed) else {
            return;
        }
        let request = URLRequest(url: feedURL);
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let data = data else { return }
            
            print(data)
            
            do {
                if let json =
                try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                    print(json)
                    print(data)
                    
                    guard let ctatt = json["ctatt"] as? [String:Any] else {
                        throw SerializationError.missing("ctatt")
                    }
                    guard let routes = ctatt["route"] as? [Any] else {
                        throw SerializationError.missing("route")
                    }
                    
                    guard let rn = routes[0] as? [String:Any] else {
                        throw SerializationError.missing("rn")
                    }
                     
                    guard let trains = rn["train"] as? [Any] else {
                        throw SerializationError.missing("train")
                    }
                    
                    guard let line = rn["@name"] else {
                        throw SerializationError.missing("@name")
                    }
                    
                    
                    for t in trains {
                        do {
                            if let train = t as? [String:Any] {
                                guard let stationName = train["nextStaNm"] else {
                                    throw SerializationError.missing("nextStaNm")
                                }
                                guard let destinationName = train["destNm"] else {
                                    throw SerializationError.missing("destNm")
                                }
                                guard let isDelayed = train["isDly"] else {
                                    throw SerializationError.missing("isDly")
                                }
                                guard let isApproaching = train["isApp"] else {
                                    throw SerializationError.missing("isApp")
                                }
                                guard let latitude = train["lat"] else {
                                    throw SerializationError.missing("lat")
                                }
                                guard let longitude = train["lon"] else {
                                    throw SerializationError.missing("lon")
                                }
                                guard let id = train["rn"] else {
                                    throw SerializationError.missing("rn")
                                }
                                
                                
                                
                                let stop = Stop()
                                stop.line = line as! String
                                stop.name = stationName as! String
                                stop.finalDest = destinationName as! String
                                stop.delayed = isDelayed as! String
                                stop.approaching = isApproaching as! String
                                stop.latitude = latitude as! String
                                stop.longitude = longitude as! String
                                stop.id = id as! String
                                
                                self.stops.append(stop)
                                }
                        } catch SerializationError.missing(let msg) {
                            print("Missing \(msg)")
                        } catch SerializationError.invalid(let msg, let data) {
                            print("Invalid \(msg): \(data)")
                        } catch let error as NSError {
                            print(error.localizedDescription)
                        }
                    //}
                    }
                }
            } catch SerializationError.missing(let msg) {
                print("Missing \(msg)")
            } catch SerializationError.invalid(let msg, let data) {
                print("Invalid \(msg): \(data)")
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }.resume()
        }
    
    
    
    
    func lineConvertor(line: String) -> String {
        var retLine = ""
        if line == "red" {
            retLine = "Red"
        }
        else if line == "blue" {
            retLine = "Blue"
        }
        else if line == "brn" {
            retLine = "Brown"
        }
        else if line == "g" {
            retLine = "Green"
        }
        else if line == "org" {
            retLine = "Orange"
        }
        else if line == "p" {
            retLine = "Purple"
        }
        else if line == "pink" {
            retLine = "Pink"
        }
        else {
            retLine = "Yellow"
        }
        return retLine
    }
    
}




class Place : NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(_ coordinate: CLLocationCoordinate2D,
         _ title: String? = nil,
         _ subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
