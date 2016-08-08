//
//  ListViewController.swift
//  realmI
//
//  Created by FE Team TV on 8/1/16.
//  Copyright © 2016 courses. All rights reserved.
//

import UIKit
import RealmSwift
import SnapKit

enum status: Int {
    case non = 0
    case added = 1
    case deleted = 2
    case updated = 3
}

class ListViewController: UIViewController {
    
       var tableView: UITableView!
       var lists : Results<RListWants>!
       var isEditingMode = false
       var currentCreateAction:UIAlertAction!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.bgColor()
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.tableColor()
        tableView.registerClass(WantlistTableViewCell.self, forCellReuseIdentifier: "listCell")
        view.addSubview(tableView)
        
        let segmSort = UISegmentedControl(items: ["A-Z","Year","Rating"])
        segmSort.selectedSegmentIndex = 1
        segmSort.addTarget(self, action: #selector(ListViewController.didSelectSortCriteria(_:)), forControlEvents: .TouchUpInside)
        segmSort.addTarget(self, action: #selector(ListViewController.didSelectSortCriteria(_:)), forControlEvents: .ValueChanged)
        segmSort.tintColor = UIColor.barItemColor()
        view.addSubview(segmSort)
        //
        let buttonSyn = UIButton(type: UIButtonType.Custom) as UIButton
        buttonSyn.setImage(UIImage(named: "Synchronize"), forState: UIControlState.Normal)
        buttonSyn.addTarget(self, action: #selector(ListViewController.synchronization(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonSyn.frame=CGRectMake(0, 0, 30, 30)
        let synButton = UIBarButtonItem(customView: buttonSyn)
        
       // Edit Button
        let button = UIButton(type: UIButtonType.Custom) as UIButton
        button.setImage(UIImage(named: "editCollection"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(ListViewController.didClickOnEditButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame=CGRectMake(0, 0, 30, 30)
        let editButton = UIBarButtonItem(customView: button)
        self.navigationItem.setRightBarButtonItems([editButton, synButton], animated: true)
        
        // Add button
        let buttonAdd = UIButton(type: UIButtonType.Custom) as UIButton
        buttonAdd.setImage(UIImage(named: "addToCollection"), forState: UIControlState.Normal)
        buttonAdd.addTarget(self, action: #selector(ListViewController.didClickOnAddButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonAdd.frame=CGRectMake(0, 0, 30, 30)
        let addButton = UIBarButtonItem(customView: buttonAdd)
        
        self.navigationItem.setLeftBarButtonItem(addButton, animated: true)
        
        segmSort.snp_makeConstraints { (make) in
            make.top.equalTo(snp_topLayoutGuideBottom)
            make.width.equalTo(view)
            make.height.equalTo(44)
        }
        
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(segmSort.snp_bottom).offset(10)
            make.width.equalTo(view)
            make.bottom.equalTo(view).offset(0)
        }
       
        loadData(0)
    }
    
    func loadData(i: Int) -> Bool {

        RDataManager.sharedManager.getData("https://api.discogs.com/users/innablack/wants?per_page=50&page=\(i)") { [unowned self] (eprocess) in
            print("https://api.discogs.com/users/innablack/wants?per_page=50&page=\(i)")
            if eprocess {
                self.readTasksAndUpdateUI()
            }
        }
      return true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func didSelectSortCriteria(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.lists = self.lists.sorted("title")
        case 1:
            self.lists = self.lists.sorted("year")
        case 2:
            self.lists = self.lists.sorted("rating")
        default:
            break
        }
       
        self.tableView.reloadData()
    }
    
    func didClickOnEditButton(sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        self.tableView.setEditing(isEditingMode, animated: true)
    }
    
    func didClickOnAddButton(sender: UIBarButtonItem) {
        
        displayAlertToAddTaskList(nil)
    }
    
    func displayAlertToAddTaskList(updatedList: RListWants!){
        
            var title = "New List"
            var doneTitle = "Create"
            if updatedList != nil{
                title = "Update  List"
                doneTitle = "Update"
            }
        
            let alertController = UIAlertController(title: title, message: "Write the name of your list.", preferredStyle: UIAlertControllerStyle.Alert)
      
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "Title"
                textField.enabled = false
                textField.addTarget(self, action: #selector(self.listNameFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
                if updatedList != nil{
                    textField.text = updatedList.title
                }
            }
        
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "Rating"
                textField.addTarget(self, action: #selector(self.listNameFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
                if updatedList != nil{
                    textField.text = String(updatedList.rating)
                }
            }
        
        //CREATE
       let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.Default) { alert -> Void in
            
            let name = alertController.textFields?[0].text
            let rating = alertController.textFields?[1].text
            self.addToRealm(updatedList, listName: name, rating: rating)
            
        }
           alertController.addAction(createAction)
           createAction.enabled = false
           self.currentCreateAction = createAction
        
        //CANCEL
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
          // alertController.view.setNeedsLayout()
           presentViewController(alertController, animated: true, completion: nil)
    }
    
    func addToRealm (updatedList: RListWants!, listName: String!, rating: String!) {
        
        if updatedList != nil {
            // update mode
            try! uiRealm.write({ () -> Void in
                updatedList.title = listName!
                updatedList.rating = Int(rating) ?? 0
                updatedList.status = status.updated.rawValue
                self.readTasksAndUpdateUI()
            })
        } else {
            // add mode
            let updatedList = RListWants()
            updatedList.title = listName!
            updatedList.id = updatedList.IncrementaID()
            updatedList.rating = Int(rating) ?? 0
            updatedList.date_added = NSDate()
            updatedList.status = status.added.rawValue
            try! uiRealm.write({ () -> Void in              
                uiRealm.add(updatedList)
                self.readTasksAndUpdateUI()
            })
        }
    }
    
    func listNameFieldDidChange(textField:UITextField){
        self.currentCreateAction.enabled = textField.text?.characters.count > 0
    }
    
    func synchronization (sender: UIButton) {
        RDataManager.sharedManager.synRealtoDiscogs()
    }

}

extension ListViewController: UITableViewDelegate {
    
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if let listsTasks = lists{
            return listsTasks.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let list = lists[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell") as! WantlistTableViewCell
        cell.titleLabel.text = list.title
        cell.year.text = String(list.year)
        cell.textFormat.text = list.formats_descriptions
        cell.floatRatingView.rating = Float(list.rating)
        return cell
    }
    
    func readTasksAndUpdateUI(){
        
        lists = uiRealm.objects(RListWants).filter("status != %@", status.deleted.rawValue)
        self.tableView.setEditing(false, animated: true)
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            let listToBeDeleted = self.lists[indexPath.row]
             try! uiRealm.write({ () -> Void in
                  listToBeDeleted.status = status.deleted.rawValue
                         self.readTasksAndUpdateUI()})
        }
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Editing will go here
            let listToBeUpdated = self.lists[indexPath.row]
            self.displayAlertToAddTaskList(listToBeUpdated)
            
        }
        
        return [deleteAction, editAction]
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let elemenContr = ElemViewController()
        
        elemenContr.selectedList =  self.lists[indexPath.row]
        
        navigationController?.pushViewController(elemenContr, animated: true)
        
    }
    
}