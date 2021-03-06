//
//  MainVC.swift
//  Inventory
//
//  Created by Shane Talbert on 2/16/17.
//  Copyright © 2017 com.shane.talbert1@gmail. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

//imported core data and added protocol for nsfetchedresultscontroller delegate

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate, SwipeTableViewCellDelegate {

    //key point is the 3 labels in the cell are connected to the view and not the view controller
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    var fetchedResultsContoller: NSFetchedResultsController<Part>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        //generateTest()
        attemptFetch(filter: "")
        
        if fetchedResultsContoller.fetchedObjects?.count == 0 {
            //Nothing in database need to load from CSV file
            loadCoreDataWithCsvFile()
        }
        //print("number of ogjects fetched is...\(fetchedResultsContoller.fetchedObjects!.count)")
        
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.view.endEditing(true)
        
    }
    
    //MARK: - table view setup
    
    //Boiler Plate code required by table protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsContoller.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PartCell", for: indexPath) as! PartCell
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        cell.delegate = self
        return cell
    }
    
    //this was built for table view cell for row at index path
    func configureCell (cell: PartCell, indexPath: NSIndexPath) {
        //update cell
        let part = fetchedResultsContoller.object(at: indexPath as IndexPath)
        cell.configureCell(part: part)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let sections = fetchedResultsContoller.sections {
            return sections.count
        }
        
        return 0
    }
    //End Boiler plate code
    
    //SwipeTableCellCode
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let updateAction = SwipeAction(style: .default, title: "Edit") { action, indexPath in
            // handle action by updating model with deletion
            print("update Action Called")
            //, was once keyword where
            //making sure there are items in the table view.
            if let objs = self.fetchedResultsContoller.fetchedObjects, objs.count > 0 {
                let part = objs[indexPath.row]
                //sending the part object to the Part VC
                self.performSegue(withIdentifier: "PartsDetail", sender: part)
            }
        }
        
        let copyPartNumAction = SwipeAction(style: .default, title: "Copy Part#") {action, indexPath in
            
            if let objs = self.fetchedResultsContoller.fetchedObjects, objs.count > 0 {
                let part = objs[indexPath.row]
                
                //print("copy part number only, which is... \(part.partNumber!)")
                UIPasteboard.general.string = part.partNumber!
            }
            
        }
        
        let copyPartInfoAction = SwipeAction(style: .default, title: "Copy Part Desc") {action, indexPath in
            
            if let objs = self.fetchedResultsContoller.fetchedObjects, objs.count > 0 {
                let part = objs[indexPath.row]
                
                UIPasteboard.general.string = "The part number for the \(part.partDescription!) for the \(part.modelName!) is \(part.partNumber!)"
            }
            
        }
        
        // customize the action appearance
        copyPartInfoAction.backgroundColor = UIColor(red: 0.498, green: 0.498, blue: 0.498, alpha: 1.00)
        //only stays while its pressed
        //copyPartInfoAction.highlightedBackgroundColor = UIColor.cyan
        copyPartInfoAction.hidesWhenSelected = true
        
        copyPartNumAction.backgroundColor = UIColor(red: 0.250, green: 0.250, blue: 0.250, alpha: 1.00)
        copyPartNumAction .hidesWhenSelected = true
        updateAction.backgroundColor = UIColor(red: 0.100, green: 0.100, blue: 0.100, alpha: 1.00)
        
        copyPartInfoAction.image = UIImage(named: "copypartinfo")
        copyPartNumAction.image = UIImage(named: "copypartnum")
        updateAction.image = UIImage(named: "updatepart")
        
        
        return [updateAction, copyPartNumAction, copyPartInfoAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        //options.expansionStyle = .destructive
        
        //this will cause edit action for row action to fire
        options.expansionStyle = .selection
        //options.expansionStyle = .destructive
        options.transitionStyle = .border
        
        return options
    }
    
    //this is to ensure the row height stays the same
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //Leave this so that I can implement if I want to just touch the row to update the part...
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        //, was once keyword where
//        //making sure there are items in the table view.
//        if let objs = fetchedResultsContoller.fetchedObjects, objs.count > 0 {
//            let part = objs[indexPath.row]
//            //sending the part object to the Part VC
//            performSegue(withIdentifier: "PartsDetail", sender: part)
//        }
//    }
    
    //MARK: - Prepare for segue
    
    //this is what will map out where to send the part to
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PartsDetail" {
            if let destination = segue.destination as? PartVC {
                if let part = sender as? Part {
                    destination.partToEdit = part
                }
            }
        }
    }
   
    func attemptFetch(filter: String) {
        
        let fetchRequest: NSFetchRequest<Part> = Part.fetchRequest()
        //how to sort the data that was fetched
        let dateSort = NSSortDescriptor(key: "created", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        //going to have to modify the fetch request results and update the fetchRequestController
        //fetchRequest.predicate
        //"" returns nothing
        if filter == "" {
            fetchRequest.predicate = nil
            //tableView.beginUpdates()
        } else {
            //NS predicate is used to interface with query results.
            //the [c] is case insensitive
            fetchRequest.predicate = NSPredicate(format: "(modelName contains[c] %@) OR (partDescription contains[c] %@)", filter, filter)
            //tableView.beginUpdates()
            
        }
        
        
        //the context here was code that was placed in the App Delegate at end of file.  The nil will return all the results.
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        //was not updating the table after save without this
        controller.delegate = self
        
        //not so sure about this??  This would crash without this line
        self.fetchedResultsContoller = controller
        
        do {
            
            try controller.performFetch()
            tableView.reloadData()
            
        }catch{
            let error = error as NSError
            print ("Error occured in attempt fetch \(error)")
        }
        
    }
    
    //MARK: - Controller
    //called when table view is about to update
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    //called when table did change
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()
    }
    
    
    //listening for when you going to make a change.  This is a built in enum that comes as part of nsmanaged data
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
            
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
            
        case .update:
            if let indexPath = indexPath {
                let cell = tableView.cellForRow(at: indexPath) as! PartCell
                // update the cell data
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            
            }
            break
            
        //this would be if they moved the row with their fingers
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
            
        //default:
        //
        }
    }
    
    func loadCoreDataWithCsvFile() {
        
        //NOTE the I in Inventory
        let contents = readDataFromFile(file: "partsInventory")
        if let line = contents?.components(separatedBy: "\n") {
            
            //used this to disallow the header (without the count -1 it goes out range
            for i in 1..<line.count - 1 {
                let indData = line[i].components(separatedBy: ",")
                //print("loop number...\(i)")
                //indData represents an individual part
                print("\(indData[0]), \(indData[1]), \(indData[2]), \(indData[3])")
                //Model Name, Part Description, Part Number, Comments
                let part = Part(context: context)
                //part = Part(context: context)
                part.partDescription = indData[1]
                part.partNumber = indData[2]
                part.modelName = indData[0]
                part.comments = indData[3]
                part.quantity = 0
                ad.saveContext()
            }
        }
    }
    
    //this will return the contents of the file.  Now need to parse the text
    func readDataFromFile(file:String) -> String! {
        
        let myBundle = Bundle.main
        guard let filepath = myBundle.path(forResource: file, ofType: "csv")
            else {
                return nil
        }
        
        do {
            let contents = try String(contentsOfFile: filepath)
            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //text changed on text bar
        attemptFetch(filter: searchBar.text!)

    }

}

