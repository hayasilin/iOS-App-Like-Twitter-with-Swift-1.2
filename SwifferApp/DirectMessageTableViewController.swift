//
//  DirectMessageTableViewController.swift
//  SwifferApp
//
//  Created by Kareem Khattab on 11/12/14.
//  Copyright (c) 2014 Kareem Khattab. All rights reserved.
//

import UIKit

class DirectMessageTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet var searchBar: UISearchBar! = UISearchBar()
    
   // var userList = [PFUser]()
    
    var userList: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        loadUsers("")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadUsers(name:String)
    {
        var findUsers:PFQuery = PFUser.query()
        
        if(!name.isEmpty)
        {
            findUsers.whereKey("username", containsString: name)
        }
        
        findUsers.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!) -> Void in
            if(error == nil){
                self.userList = NSMutableArray(array: objects)
                self.tableView.reloadData()
                
            }
            
            
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        loadUsers(searchText)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        loadUsers("")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return userList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        var user:PFUser = userList.objectAtIndex(indexPath.row) as PFUser
        
        // Configure the cell...
        
        cell.textLabel.text = user.username

        return cell
    }
    
    
     override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var messageAlert:UIAlertController = UIAlertController(title: "New Direct Message", message:"Enter Your Message", preferredStyle: UIAlertControllerStyle.Alert)
        
        messageAlert.addTextFieldWithConfigurationHandler{
            (textfield:UITextField!) -> Void in
            
            textfield.placeholder = "Your message"
            
        
        }
        
        messageAlert.addAction(UIAlertAction(title: "Send", style: UIAlertActionStyle.Default, handler: {
            (alertAction:UIAlertAction!) -> Void in
            
            var pushQuery: PFQuery = PFInstallation.query()
            pushQuery.whereKey("user", equalTo: self.userList.objectAtIndex(indexPath.row))
            
            var push: PFPush = PFPush()
            push.setQuery(pushQuery)
            
            let textfields:Array = messageAlert.textFields!
            let messageTextField:UITextField = textfields.first as UITextField
            
            push.setMessage(messageTextField.text)
            push.sendPushInBackgroundWithTarget(nil, selector: nil)
            
            
        }))
        
        messageAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(messageAlert, animated: true, completion: nil)
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
