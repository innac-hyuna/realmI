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
        
       // Edit Button
        let button = UIButton(type: UIButtonType.Custom) as UIButton
        button.setImage(UIImage(named: "editCollection"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(ListViewController.didClickOnEditButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame=CGRectMake(0, 0, 30, 30)
        let editButton = UIBarButtonItem(customView: button)
        self.navigationItem.setRightBarButtonItem(editButton, animated: true)
        
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
        // if !(self.navigationController?.visibleViewController?.isKindOfClass(UIAlertController.classForCoder()))! {
            var title = "New List"
            var doneTitle = "Create"
            if updatedList != nil{
                title = "Update  List"
                doneTitle = "Update"
            }
            
            let alertController = UIAlertController(title: title, message: "Write the name of your list.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.view.setNeedsLayout()
            
            
            let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.Default) { alert -> Void in
                
                let name = alertController.textFields?[0].text
                let year = alertController.textFields?[1].text
                let rating = alertController.textFields?[2].text
                self.addToRealm(updatedList, listName: name, year: year, rating: rating!)
                
            }
            
            alertController.addAction(createAction)
            createAction.enabled = false
            self.currentCreateAction = createAction
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
            
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "Title"
                textField.addTarget(self, action: #selector(self.listNameFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
                if updatedList != nil{
                    textField.text = updatedList.title
                }
            }
            
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "Year"
                textField.addTarget(self, action: #selector(self.listNameFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
                if updatedList != nil{
                    textField.text = String(updatedList.year)
                }
            }
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "Rating"
                textField.addTarget(self, action: #selector(self.listNameFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
                if updatedList != nil{
                    textField.text = String(updatedList.rating)
                }
            }
            presentViewController(alertController, animated: true, completion: nil) //}
    }
    
    func addToRealm (updatedList: RListWants!, listName: String!, year: String!, rating: String!) {
        
        if updatedList != nil {
            // update mode
            try! uiRealm.write({ () -> Void in
                updatedList.title = listName!
                updatedList.year = Int(year)!
                updatedList.rating = Int(rating)!
                self.readTasksAndUpdateUI()  })
        } else {
            let updatedList = RListWants()
            updatedList.title = listName!
            updatedList.id = updatedList.IncrementaID()
            updatedList.year = Int(year) ?? 0
            updatedList.rating = Int(rating) ?? 0
            updatedList.date_added = NSDate()
            
            try! uiRealm.write({ () -> Void in
                uiRealm.add(updatedList)
                self.readTasksAndUpdateUI()
            })
        }

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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell") as! WantlistTableViewCell
        
        let list = lists[indexPath.row]
        
        cell.titleLabel.text = list.title
        cell.year.text = String(list.year)
        cell.textFormat.text = list.formats_descriptions
        cell.floatRatingView.rating = Float(list.rating)
             
        return cell
    }
    
    func readTasksAndUpdateUI(){
        
        lists = uiRealm.objects(RListWants)
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