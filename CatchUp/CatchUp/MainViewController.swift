//
//  NavigationViewController.swift
//  CatchUp
//
//  Created by Paul Mandel on 11/29/14.
//  Copyright (c) 2014 Mandelbrot Makers. All rights reserved.
//

import UIKit
import AddressBook
import AddressBookUI
import Foundation
import CoreData

class MainViewController: UITableViewController, ABPeoplePickerNavigationControllerDelegate {
    @IBOutlet weak var catchupTable: UITableView!
    
    var catchUps = [] as [NSManagedObject]
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        
        var error: NSError?
        
        let fetchResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
        
        if let results = fetchResults {
            catchUps = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        catchupTable.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "Cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catchUps.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = catchupTable.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        let person = catchUps[indexPath.row]
        
        cell.textLabel?.text = person.valueForKey("name") as String?
        cell.detailTextLabel?.text = "No catch up date set"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("editCatchup", sender: tableView)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "editCatchup" {
            let editCatchupViewController = segue.destinationViewController as CatchupDetailViewController
            
            let indexPath = self.tableView.indexPathForSelectedRow()!
            let destinationTitle = self.catchUps[indexPath.row].valueForKey("name") as String?
            editCatchupViewController.title = destinationTitle
            
            let person = catchUps[indexPath.row]
            
            editCatchupViewController.catchupFrequency = person.valueForKey("catchupFrequency") as Int?
            editCatchupViewController.catchupPeriod = person.valueForKey("catchupPeriod") as String?
        }
    }
    
    @IBAction func addCatchup(sender: UIBarButtonItem) {
        let picker = ABPeoplePickerNavigationController()
        picker.peoplePickerDelegate = self
        
        picker.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        picker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        self.presentViewController(picker, animated:true) {}
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, shouldContinueAfterSelectingPerson person: ABRecord!) -> Bool {
        return false
    }
    
    func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!) {
        self.dismissViewControllerAnimated(true) {}
    }
    
    func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecord!) {
        self.savePerson(person)
        catchupTable!.reloadData()
    }
    
    func savePerson(personToSave: ABRecord) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedContext)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        let name = ABRecordCopyCompositeName(personToSave)?.takeRetainedValue() as String? ?? ""
        person.setValue(name, forKey: "name")
        person.setValue(1 as Int?, forKey: "catchupFrequency")
        person.setValue("month" as String?, forKey: "catchupPeriod")
        
        let oneMonth : Double = 1*30*24*60*60
        
        person.setValue(NSDate(timeIntervalSinceNow: oneMonth), forKey: "nextCatchup")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        catchUps.append(person)
    }
}