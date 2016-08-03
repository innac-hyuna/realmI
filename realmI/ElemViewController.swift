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
    var selectedList : RListUser!
    var openTasks : Results<FirstO>!
    var completedTasks : Results<FirstO>!
    var currentCreateAction: UIAlertAction!
    var isEditingMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        
        let editButton = UIBarButtonItem.init(title: "Edit", style: .Plain, target: self, action: #selector(ElemViewController.didClickOnEdit(_:)))
        self.navigationItem.setRightBarButtonItem(editButton, animated: true)
        let addButton = UIBarButtonItem.init(title: "Add", style: .Plain, target: self, action: #selector(ElemViewController.didClickOnNew(_:)))
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
        
        completedTasks = self.selectedList.tasks.filter("isCompleted = true")
        openTasks = self.selectedList.tasks.filter("isCompleted = false")
        tableView.reloadData()
    }

    func displayAlertToAddTask(updatedTask:FirstO!){
        
        var title = "New Task"
        var doneTitle = "Create"
        if updatedTask != nil {
            title = "Update Task"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your task.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.view.setNeedsLayout()
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.Default) { (action) -> Void in
            
            let taskName = alertController.textFields?.first?.text
            
            if updatedTask != nil{
                // update mode
                
                   try!  uiRealm.write({ () -> Void in
                        updatedTask.name = taskName!
                        self.readTasksAndUpateUI() })
            } else {
                
                let newTask = FirstO()
                newTask.name = taskName!
               
                   try! uiRealm.write({ () -> Void in
                        self.selectedList.tasks.append(newTask)
                        self.readTasksAndUpateUI() })

           }
            print(taskName)
        }
        
        alertController.addAction(createAction)
        createAction.enabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Name"
            textField.addTarget(self, action: #selector(ElemViewController.taskNameFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
            if updatedTask != nil{
                textField.text = updatedTask.name
            }
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func taskNameFieldDidChange(textField:UITextField){
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
            return openTasks.count
        }
        return completedTasks.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return "OPEN"
        }
        return "SELECTED"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell")
        var task: FirstO!
        if indexPath.section == 0{
            task = openTasks[indexPath.row]
        }
        else{
            task = completedTasks[indexPath.row]
        }
        
        cell?.textLabel?.text = task.name
        return cell!
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            var taskToBeDeleted: FirstO!
            if indexPath.section == 0{
                taskToBeDeleted = self.openTasks[indexPath.row]
            }
            else{
                taskToBeDeleted = self.completedTasks[indexPath.row]
            }
             try! uiRealm.write({ () -> Void in
                uiRealm.delete(taskToBeDeleted)
                self.readTasksAndUpateUI() })
        }
        
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Edit") { (editAction, indexPath) -> Void in
            
            // Editing will go here
            var taskToBeUpdated: FirstO!
            if indexPath.section == 0 {
                taskToBeUpdated = self.openTasks[indexPath.row]
            }
            else {
                taskToBeUpdated = self.completedTasks[indexPath.row]
            }
            
            self.displayAlertToAddTask(taskToBeUpdated)
            
        }
        
        let doneAction = UITableViewRowAction(style: UITableViewRowActionStyle.Normal, title: "Select") { (doneAction, indexPath) -> Void in
            // Editing will go here
            var taskToBeUpdated: FirstO!
            if indexPath.section == 0 {
                taskToBeUpdated = self.openTasks[indexPath.row]
            }
            else{
                taskToBeUpdated = self.completedTasks[indexPath.row]
            }
            try! uiRealm.write({ () -> Void in
                taskToBeUpdated.isCompleted = true
                self.readTasksAndUpateUI()
            })
        }
        
        return [deleteAction, editAction, doneAction]
    }
    

}