//
//  LineTableViewController.swift
//  anghela-CTA
//
//  Created by Ana Anghel on 5/4/21.
//

import UIKit

class LineTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lines.count
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
   -> UITableViewCell {
        let line = lines[indexPath.row]
        let cell = tableView.dequeueReusableCell( withIdentifier: "LineCell" , for: indexPath)
        
        cell.textLabel?.text = line.name
        if line.name == "Red Line"{
            cell.backgroundColor = UIColor.systemRed
        }
        else if line.name == "Blue Line"{
            cell.backgroundColor = UIColor.systemBlue
        }
        else if line.name == "Brown Line"{
            cell.backgroundColor = UIColor.brown
        }
        else if line.name == "Green Line"{
            cell.backgroundColor = UIColor.systemGreen
        }
        else if line.name == "Orange Line"{
            cell.backgroundColor = UIColor.systemOrange
        }
        else if line.name == "Purple Line"{
            cell.backgroundColor = UIColor.systemPurple
        }
        else if line.name == "Pink Line"{
            cell.backgroundColor = UIColor.systemPink
        }
        else {
            cell.backgroundColor = UIColor.systemYellow
        }
     
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let TableViewController = segue.destination as? TableViewController {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                TableViewController.title = lines[indexPath.row].name
                }
            }
    }
}
