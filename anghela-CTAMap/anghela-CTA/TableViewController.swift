//
//  TableViewController.swift
//  anghela-CTA
//
//  Created by Ana Anghel on 4/29/21.
//

import UIKit



var feed = "";

class TableViewController: UITableViewController {
    
    class Stop {
        var name: String = ""
        var finalDest: String = ""
        var delayed: String = ""
        var approaching: String = ""
        var eta: String = ""
    }
    
    enum SerializationError: Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    var dataAvailable = false
    var stops: [Stop] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        dataAvailable = false
        if super.title == "Red Line" {
            feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=red&outputType=JSON"
        }
        else if super.title == "Blue Line" {
            feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=blue&outputType=JSON"
        }
        else if super.title == "Brown Line" {
            feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=brn&outputType=JSON"
        }
        else if super.title == "Green Line" {
            feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=g&outputType=JSON"
        }
        else if super.title == "Orange Line" {
            feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=org&outputType=JSON"
        }
        else if super.title == "Purple Line" {
            feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=p&outputType=JSON"
        }
        else if super.title == "Pink Line" {
            feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=pink&outputType=JSON"
        }
        else {
            feed = "http://lapi.transitchicago.com/api/1.0/ttpositions.aspx?key=ae3b8777f14e4eef8c0ee9571fc873e8&rt=y&outputType=JSON"
        }

        
        loadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataAvailable ? lines.count : 18
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indexavailable = stops.count>indexPath.row
        print(indexavailable)
        if (dataAvailable && indexavailable==true) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LazyTableCell", for: indexPath)
            // Configure the cell...
            print(indexPath.row)
            let stop = stops[indexPath.row]
            cell.textLabel?.text = "Next Stop: " + stop.name
            cell.detailTextLabel?.text = "Heading To " + stop.finalDest
            if stop.delayed == "1" {
                cell.backgroundColor = UIColor.systemRed
            }
            if stop.approaching == "1"{
                cell.backgroundColor = UIColor.systemGreen
            }
            return cell
        } else if indexavailable==false{
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhiteCell", for: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell", for: indexPath)
            return cell
        }
        
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
                        throw SerializationError.missing("train")
                    }
                     
                    guard let trains = rn["train"] as? [Any] else {
                        throw SerializationError.missing("train")
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
                                
                                
                                
                                let stop = Stop()
                                stop.name = stationName as! String
                                stop.finalDest = destinationName as! String
                                stop.delayed = isDelayed as! String
                                stop.approaching = isApproaching as! String
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
                    self.dataAvailable = true
                    DispatchQueue.main.async{
                        self.tableView.reloadData()
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
    
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let stop = stops[indexPath.row]
    
        if stop.approaching == "1" {
            let title = "Train is Approaching"
            let message = ""
            let alertController = UIAlertController(title: title,
            message: message, preferredStyle: .actionSheet)
                
            let okayAction = UIAlertAction(title: "Okay",
            style: .default, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        if stop.delayed == "1" {
            let title = "Train is Delayed"
            let message = ""
            let alertController = UIAlertController(title: title,
            message: message, preferredStyle: .actionSheet)
                
            let okayAction = UIAlertAction(title: "Okay",
            style: .default, handler: nil)
            alertController.addAction(okayAction)
            present(alertController, animated: true, completion: nil)
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    
    }
}
