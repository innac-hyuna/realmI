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

class ListViewController: UIViewController {
    
       var tableView: UITableView!
       var lists : Results<RListUser>!
       var isEditingMode = false
       var currentCreateAction:UIAlertAction!

    override func viewDidLoad() {
        super.viewDidLoad()
   
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "listCell")
        view.addSubview(tableView)
        
        let segmSort = UISegmentedControl(items: ["A-Z","Date"])
        segmSort.selectedSegmentIndex = 1
        segmSort.addTarget(self, action: #selector(ListViewController.didSelectSortCriteria(_:)), forControlEvents: .TouchUpInside)
        segmSort.addTarget(self, action: #selector(ListViewController.didSelectSortCriteria(_:)), forControlEvents: .ValueChanged)
        view.addSubview(segmSort)

        
        let editButton = UIBarButtonItem.init(title: "Edit", style: .Plain, target: self, action: #selector(ListViewController.didClickOnEditButton(_:)))
        self.navigationItem.setRightBarButtonItem(editButton, animated: true)
        let addButton = UIBarButtonItem.init(title: "Add", style: .Plain, target: self, action: #selector(ListViewController.didClickOnAddButton(_:)))
        self.navigationItem.setLeftBarButtonItem(addButton, animated: true)
        
        
        segmSort.snp_makeConstraints { (make) in
            make.top.equalTo(snp_topLayoutGuideBottom)
            make.width.equalTo(view)
            make.height.equalTo(44)
        }
        
        tableView.snp_makeConstraints { (make) in
            make.top.equalTo(segmSort.snp_bottom)
            make.width.equalTo(view)
            make.height.equalTo(view)
        }
        
        RDataManager.sharedManager.getData("https://api.discogs.com/users/innablack") { [unowned self] (eprocess) in
            if eprocess {
              self.readTasksAndUpdateUI()  
            }
            
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func didSelectSortCriteria(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            
            // A-Z
            self.lists = self.lists.sorted("title")
        }
        else{
            // date
            self.lists = self.lists.sorted("autor", ascending:false)
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
    
    
    func displayAlertToAddTaskList(updatedList: RListUser!){
        
        var title = "New List"
        var doneTitle = "Create"
        if updatedList != nil{
            title = "Update  List"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your list.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.view.setNeedsLayout()
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.Default) { alert -> Void in
            
            let listName = alertController.textFields?.first?.text
            
            if updatedList != nil {
                // update mode
                try! uiRealm.write({ () -> Void in
                    updatedList.username = listName!
                    self.readTasksAndUpdateUI()  })
            } else {
                let newTaskList = RListUser()
                newTaskList.username = listName!
                
                try! uiRealm.write({ () -> Void in
                    
                    uiRealm.add(newTaskList)
                    self.readTasksAndUpdateUI()   })
            }
            
            print(listName)
        }
        
        alertController.addAction(createAction)
        createAction.enabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "List Name"
            textField.addTarget(self, action: #selector(self.listNameFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
            if updatedList != nil{
                textField.text = updatedList.username
            }
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func listNameFieldDidChange(textField:UITextField){
        self.currentCreateAction.enabled = textField.text?.characters.count > 0
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell")
        
        let list = lists[indexPath.row]
        
        cell?.textLabel?.text = list.username
        cell?.detailTextLabel?.text = "\(list.tasks.count) Tasks"
        return cell!
    }
    
    func readTasksAndUpdateUI(){
        
        lists = uiRealm.objects(RListUser)
        self.tableView.setEditing(false, animated: true)
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "Delete") { (deleteAction, indexPath) -> Void in
            
            //Deletion will go here
            
            let listToBeDeleted = self.lists[indexPath.row]
             try! uiRealm.write({ () -> Void in
                 uiRealm.delete(listToBeDeleted)
                 self.readTasksAndUpdateUI() })
          
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