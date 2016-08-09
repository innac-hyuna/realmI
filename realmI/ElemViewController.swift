//
//  ElemViewController.swift
//  realmI
//
//  Created by FE Team TV on 8/1/16.
//  Copyright © 2016 courses. All rights reserved.
//

import UIKit
import RealmSwift

class ElemViewController: UIViewController {
    
    var tableView: UITableView!
    var selectedList : RListWants!
    var openMarket : Results<RMarket>!
    var completedMarket : Results<RMarket>!
    var currentCreateAction: UIAlertAction!
    var isEditingMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.bgColor()
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.tableColor()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        // Edit Button
        let button = UIButton(type: UIButtonType.Custom) as UIButton
        button.setImage(UIImage(named: "editCollection"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(ElemViewController.didClickOnEdit(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 30, 30)
        let editButton = UIBarButtonItem(customView: button)
        self.navigationItem.setRightBarButtonItem(editButton, animated: true)
        
        // Add button
        let buttonAdd = UIButton(type: UIButtonType.Custom) as UIButton
        buttonAdd.setImage(UIImage(named: "addToCollection"), forState: UIControlState.Normal)
        buttonAdd.addTarget(self, action: #selector(ElemViewController.didClickOnNew(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        buttonAdd.frame = CGRectMake(0, 0, 30, 30)
        let addButton = UIBarButtonItem(customView: buttonAdd)
        self.navigationItem.leftItemsSupplementBackButton = true
        navigationController?.navigationBar.tintColor = UIColor.tableColor()
        self.navigationItem.setLeftBarButtonItem(addButton, animated: true)
        
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(snp_topLayoutGuideBottom)
            make.width.equalTo(view)
            make.height.equalTo(view)
        }
        readTasksAndUpateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didClickOnEdit(sender: AnyObject) {
        isEditingMode = !isEditingMode
        self.tableView.setEditing(isEditingMode, animated: true)
    }
    
    func didClickOnNew(sender: AnyObject) {
        self.displayAlertToAddTask(nil)
    }
    
    func readTasksAndUpateUI(){
        
        completedMarket = self.selectedList.tasks.filter("isCompleted = true")
        openMarket = self.selectedList.tasks.filter("isCompleted = false")
        tableView.reloadData()
    }

    func displayAlertToAddTask(updatedMarket:RMarket!){
          //if !(self.navigationController?.visibleViewController?.isKindOfClass(UIAlertController.classForCoder()))! {
            var title = "New Market"
            var doneTitle = "Create"
            if updatedMarket != nil {
                title = "Update Market"
                doneTitle = "Update"
            }
            
            let alertControllerEl = UIAlertController(title: title, message: "Write the name of your Market.", preferredStyle: UIAlertControllerStyle.Alert)
            alertControllerEl.view.setNeedsLayout()
            let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.Default) { (action) -> Void in
                
                let marketName = alertControllerEl.textFields?.first?.text
                
                if updatedMarket != nil{
                    // update mode
                    
                    try!  uiRealm.write({ () -> Void in
                        updatedMarket.name = marketName!
                        self.readTasksAndUpateUI() })
                } else {
                    
                    let newMarket = RMarket()
                    newMarket.name = marketName!
                    
                    try! uiRealm.write({ () -> Void in
                        self.selectedList.tasks.append(newMarket)
                        self.readTasksAndUpateUI() })                    
                }
            }
            
            alertControllerEl.addAction(createAction)
            createAction.enabled = false
            self.currentCreateAction = createAction
            
            alertControllerEl.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            
            alertControllerEl.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "Name"
                textField.addTarget(self, action: #selector(ElemViewController.taskNameFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
                if updatedMarket != nil{
                    textField.text = updatedMarket.name
                }
            }
            
            self.presentViewController(alertControllerEl, animated: true, completion: nil)        
    }
    
    func taskNameFieldDidChange(textField:UITextField){
        print(textField.text?.characters.count > 0)
        self.currentCreateAction.enabled = textField.text?.characters.count > 0
    }

}

extension ElemViewController: UITableViewDelegate {

}

extension ElemViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0 {
            return openMarket.count
        }
        return completedMarket.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "ADDED"
        }
        return "SELECTED"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        var task: RMarket!
        if indexPath.section == 0{
            task = openMarket[indexPath.row]
        }
        else{
            task = completedMarket[indexPath.row]
        }
        
        cell?.textLabel?.text = task.name
        return cell!
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            var taskToBeDeleted: RMarket!
            if indexPath.section == 0 {
                taskToBeDeleted = self.openMarket[indexPath.row]
            }
            else{
                taskToBeDeleted = self.completedMarket[indexPath.row]
            }
             try! uiRealm.write({ () -> Void in
                uiRealm.delete(taskToBeDeleted)
                self.readTasksAndUpateUI() })
        }
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Editing will go here
            var taskToBeUpdated: RMarket!
            if indexPath.section == 0 {
                taskToBeUpdated = self.openMarket[indexPath.row]
            }
            else {
                taskToBeUpdated = self.completedMarket[indexPath.row]
            }
            
            self.displayAlertToAddTask(taskToBeUpdated)
            
        }
        
        let doneAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Select") { (doneAction, indexPath) -> Void in
            // Editing will go here
            var taskToBeUpdated: RMarket!
            if indexPath.section == 0 {
                taskToBeUpdated = self.openMarket[indexPath.row]
            }
            else{
                taskToBeUpdated = self.completedMarket[indexPath.row]
            }
            try! uiRealm.write({ () -> Void in
                taskToBeUpdated.isCompleted = true
                self.readTasksAndUpateUI()
            })
        }
        
        return [deleteAction, editAction, doneAction]
    }
}