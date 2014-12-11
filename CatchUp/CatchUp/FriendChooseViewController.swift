//
//  ViewController.swift
//  CatchUp
//
//  Created by Paul Mandel on 11/28/14.
//  Copyright (c) 2014 Mandelbrot Makers. All rights reserved.
//

import UIKit
import AddressBook
import Foundation


class FriendChooserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    @IBOutlet var appsTableView: UITableView?
    
    var tableData = []
    var filteredTableData = []
    
    var adbk : ABAddressBook!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        getContactNames()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelAddCatchUp(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) {}
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredTableData.count
        } else {
            return self.tableData.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "MyTestCell")
        
        var person: ABRecord
        if tableView == self.searchDisplayController!.searchResultsTableView {
            person = self.filteredTableData[indexPath.row] as ABRecord
        } else {
            person = self.tableData[indexPath.row] as ABRecord
        }
        
        
        let personName = getName(person)
        
        cell.textLabel?.text = personName
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        var person: ABRecord
        if tableView == self.searchDisplayController!.searchResultsTableView {
            person = self.filteredTableData[indexPath.row] as ABRecord
        } else {
            person = self.tableData[indexPath.row] as ABRecord
        }
    }
    
    func filterContentForSearchText(searchText: String) {
        let toFilter = self.tableData as Array
        self.filteredTableData = toFilter.filter({( person: ABRecord) -> Bool in
            return self.getName(person).lowercaseString.rangeOfString(searchText.lowercaseString) != nil
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }
    
    func createAddressBook() -> Bool {
        if self.adbk != nil {
            return true
        }
        var err : Unmanaged<CFError>? = nil
        let adbk : ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if adbk == nil {
            println(err)
            self.adbk = nil
            return false
        }
        self.adbk = adbk
        return true
    }
        
    func determineStatus() -> Bool {
        let status = ABAddressBookGetAuthorizationStatus()
        switch status {
        case .Authorized:
            return self.createAddressBook()
        case .NotDetermined:
            var ok = false
            ABAddressBookRequestAccessWithCompletion(nil) {
                (granted:Bool, err:CFError!) in
                dispatch_async(dispatch_get_main_queue()) {
                    if granted {
                        ok = self.createAddressBook()
                    }
                }
            }
            if ok == true {
                return true
            }
            self.adbk = nil
            return false
        case .Restricted:
            self.adbk = nil
            return false
        case .Denied:
            self.adbk = nil
            return false
        }
    }
    
    func getContactNames() {
        if !self.determineStatus() {
            println("not authorized")
            return
        }
        var people = ABAddressBookCopyArrayOfAllPeople(adbk).takeRetainedValue() as NSArray as [ABRecord]
        
        people = people.filter(nonBlank)
        
        println("\(people.count) contacts found")
        
        self.tableData = people.sorted(nameAscending)
        self.appsTableView!.reloadData()
    }
    
    func nonBlank(person1: ABRecord) -> Bool {
        var name1 = getName(person1).stringByReplacingOccurrencesOfString(" ", withString: "")
        name1 = name1.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return !name1.isEmpty
    }
    
    func nameAscending(person1: ABRecord, person2: ABRecord) -> Bool {
        let name1 = getName(person1)
        let name2 = getName(person2)
        
        return name1.localizedCaseInsensitiveCompare(name2) == NSComparisonResult.OrderedAscending
    }
    
    func getName(person: ABRecord) -> String {
        return ABRecordCopyCompositeName(person)?.takeRetainedValue() as String? ?? ""
    }
}

