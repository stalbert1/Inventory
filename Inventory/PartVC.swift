//
//  PartVC.swift
//  Inventory
//
//  Created by Shane Talbert on 2/19/17.
//  Copyright © 2017 com.shane.talbert1@gmail. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class PartVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, MFMailComposeViewControllerDelegate {

    
    @IBOutlet weak var txtPartDesc: UITextField!
    @IBOutlet weak var txtPartNumber: UITextField!
    @IBOutlet weak var txtComments: UITextView!
    @IBOutlet weak var txtQuantity: UITextField!
    @IBOutlet weak var txtModelName: UITextField!
    
    @IBOutlet weak var pkrModelName: UIPickerView!
    
    //added this to account for the keyboard and being able to see what your typing.
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var partToEdit: Part?
    
    var modelNames = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pkrModelName.delegate = self
        pkrModelName.dataSource = self
        txtModelName.isHidden = true
        
        bottomConstraint.constant = 0
        view.layoutIfNeeded()
        
        //fetch request all unique model names and build model names array
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Part")
        //request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [Part] {
                    if modelNames.contains(result.modelName!) == false {
                        modelNames.append(result.modelName!)
                    }
                }
            } else {
                print ("No results")
            }
        } catch {
            print ("Could not retrieve")
        }
        
        if partToEdit != nil {
            loadPartData()
        }
    }
    
    //used this to dismiss the keyboard from uitextfield when pressing the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        bottomConstraint.constant = 0
        view.layoutIfNeeded()
        self.view.endEditing(true)
    }
    
    @IBAction func addModelNamePressed() {
        
        if pkrModelName.isHidden == false {
            pkrModelName.isHidden = true
            txtModelName.isHidden = false
        }else {
            pkrModelName.isHidden = false
            txtModelName.isHidden = true
        }
        
        bottomConstraint.constant = 308
        view.layoutIfNeeded()
        
    }
    
    //MARK: - UI picker boiler plate
    //title for row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //code here
        let modelName = modelNames[row]
        return modelName
    }
    
    //number of rows in componenet
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return modelNames.count
    }
    
    //number of components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        //number of columns.
        return 1
    }
    
    //did select row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //code here
    }
    
    //MARK: - Methods

    @IBAction func savePressed(_ sender: Any) {
        
        //cant update the qty at this point
        
        //perform fetch before part is created.
        var potentialModelName: String!
        
        //got to choose who will be assigning model name
        if pkrModelName.isHidden == false {
            potentialModelName = modelNames[pkrModelName.selectedRow(inComponent: 0)]
        }else {
            //this will allow a blank model name?
            potentialModelName = txtModelName.text
        }
        
        //check to see if the database already contains this part number
        let uniqueID = potentialModelName + (txtPartNumber.text!)
        
        var uniques = [String]()
        var partExist = false
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Part")
        //request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [Part] {
                    uniques.append (result.modelName! + result.partNumber!)
                }
                if uniques.contains(uniqueID) {
                    partExist = true
                }
            } else {
                print ("No results")
            }
        } catch {
            print ("Could not retrieve")
        }
        
        if txtPartDesc.text != "" && txtPartNumber.text != "" {
            
            //going to need to check if part is duplicate only allow all this if parttoedit == nil
            var part: Part!
            
            if partToEdit == nil {
                part = Part(context: context)
            } else {
                part = partToEdit
                partExist = false
            }
            
            part.partDescription = txtPartDesc.text
            part.partNumber = txtPartNumber.text
            part.modelName = potentialModelName
            
            if txtComments.text == "" {
                part.comments = "No comments"
            }else{
                part.comments = txtComments.text
            }
            
            //if qty cant be converted to an int make it 0
            if let qty = Int (txtQuantity.text!) {
                part.quantity = Int16(qty)
            }else{
                part.quantity = 0
            }
            
            if partExist == false {
                ad.saveContext()
            }
            
            _ = navigationController?.popViewController(animated: true)
            
        }//end if looking for empty strings
    }
    
    
    @IBAction func exportPressed() {
        
        print ("Export pressed")
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Part")
        //request.returnsObjectsAsFaults = false
        var myPartsList: String = "Model Name, Part Description, Part Number, Comments\n"
        
        do {
            
            let results = try context.fetch(request)
            if results.count > 0 {
                
                //results here is a NSManaged object which is what Part class is inherited from.
                for result in results as! [Part] {
                    let partNumb = result.value(forKey: "partNumber") as? String
                    let partDes = result.value(forKey: "partDescription") as? String
                    let modelNme = result.value(forKey: "modelName") as? String
                    let comments = result.value(forKey: "comments") as? String
                    myPartsList = myPartsList + "\(modelNme!),\(partDes!),\(partNumb!),\(comments!)\n"
                    //print ("\(modelNme!),\(partDes!),\(partNumb!),\(comments!)")
                    
                }
                
            } else {
                print ("No results")
            }
            
        } catch {
                print ("Could not retrieve")
            
        }
        
        createSaveEmailFile(stringDataToSave: myPartsList)
        
            }
    
    @IBAction func deletePressed(_ sender: UIBarButtonItem) {
        
        if partToEdit != nil {
            context.delete(partToEdit!)
            ad.saveContext()
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    //added function to load data once one of the parts is selected in the table
    func loadPartData() {
        
        //ensures the part is not nil, if not it's a part
        if let part = partToEdit {
            txtPartNumber.text = part.partNumber
            txtQuantity.text = ("\(part.quantity)")
            txtComments.text = part.comments
            txtPartDesc.text = part.partDescription
            var counter = 0
            //he started to ensure it was not an optional
            for model in modelNames {
                if model == part.modelName {
                    //got to select the index of the array that the numbers match in.  May create a counter?
                    pkrModelName.selectRow(counter, inComponent: 0, animated: false)
                }
                counter = counter + 1
            }
            
        }
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            //cancelled
            alert(title: "OOpps", msg: "Cancelled")
        case MFMailComposeResult.sent.rawValue:
            //message sent
            alert(title: "Sucess", msg: "Message sent")
        case MFMailComposeResult.failed.rawValue:
            //message failed
            alert(title: "Failed", msg: "Message failed to save")
        case MFMailComposeResult.saved.rawValue:
            alert(title: "Saved", msg: "Message is saved")
        default: break
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func alert (title: String, msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
        present(alertController, animated: true, completion: nil)
        
    }
    
    func showMailComposer(withAttachmentURL: String, myData: Data) {
        
        let subject = "Parts inventory backup CSV file"
        let messageBody = "Parts inventory database backup file in CSV format."
        
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(messageBody, isHTML: false)
        
        mailComposer.addAttachmentData(myData, mimeType: "text/csv", fileName: withAttachmentURL)
        present(mailComposer, animated: true, completion: nil)
        
    }
    
    func createSaveEmailFile(stringDataToSave: String) {
        
        let flMgr = FileManager.init()
        let documentsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        //this appends the file name to the end of the returned string
        let writePath = documentsDir.appending("/test.txt")
        flMgr.createFile(atPath: writePath, contents: nil, attributes: nil)
        
        //let myData = Data(base64Encoded: stringDataToSave, options: .ignoreUnknownCharacters)
        
        
        //print(writePath)
        //write file code
        do {
            //without overriding.  Only saving last entry
            try stringDataToSave.write(toFile: writePath, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print ("Error\(error)")
        }
        
        //next email the file that was just created
        let myData = NSData(contentsOfFile: writePath)
        
        //mime type text/csv
        if MFMailComposeViewController.canSendMail() == true {
            showMailComposer(withAttachmentURL: "partsInventory.csv", myData: myData! as Data)
        } else {
            print("This device can't send mail")
        }
        

    }
    

}
