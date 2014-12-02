//
//  TimeLineTableViewController.swift
//  SwifferApp
//
//  Created by Kareem Khattab on 11/8/14.
//  Copyright (c) 2014 Kareem Khattab. All rights reserved.
//

import UIKit

class TimeLineTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    var timelineData = [PFObject]()

    

    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.loadData()
       
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"loadData", name:"reloadTimeline" , object: nil)
        
        
    }
    
    
    @IBAction func refreshButton()
    {
        timelineData.removeAll(keepCapacity: false)
        
        var findTimelineData:PFQuery = PFQuery(className:"Sweets")
        findTimelineData.findObjectsInBackgroundWithBlock
            {
                (objects:[AnyObject]! , error:NSError!) -> Void in
                if error == nil
                {
                    self.timelineData = objects.reverse() as [PFObject]
                    
                    
                    //let array:NSArray = self.timelineData.reverseObjectEnumerator().allObjects
                    
                    println(objects)
                    
                    // self.timelineData = array as NSMutableArray
                    
                    
                    self.tableView.reloadData()
                }
        }
    }
    
    @IBAction func loadData(){
        timelineData.removeAll(keepCapacity: false)
        
        var findTimelineData:PFQuery = PFQuery(className:"Sweets")
        findTimelineData.findObjectsInBackgroundWithBlock
            {
                (objects:[AnyObject]! , error:NSError!) -> Void in
                if error == nil
                {
                    self.timelineData = objects.reverse() as [PFObject]
                    
                    
                    //let array:NSArray = self.timelineData.reverseObjectEnumerator().allObjects
                    
                    // self.timelineData = array as NSMutableArray
                    
                    
                    
                    self.tableView.reloadData()
                }
        }
    }

    
    
    
    override func viewDidAppear(animated: Bool) {
        
       
        
        var footerView:UIView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        self.tableView.tableFooterView = footerView
        
        var logoutButton:UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        logoutButton.frame = CGRectMake(20, 10, 50, 20)
        logoutButton.setTitle("Logout", forState: UIControlState.Normal)
        logoutButton.addTarget(self, action:"logout:", forControlEvents: UIControlEvents.TouchUpInside)
        
        footerView.addSubview(logoutButton)
        
        if((PFUser.currentUser()) == nil){
            
            self.showLoginSignUp()
            
            
        }
        
        
        
      
        
}
    
    
    
    func showLoginSignUp()
    {
        
        
        var loginAlert:UIAlertController = UIAlertController(title: "Sign Up / Login ", message: "Please Sign Up or Login", preferredStyle: UIAlertControllerStyle.Alert)
        
        loginAlert.addTextFieldWithConfigurationHandler({
            textfield in
            textfield.placeholder = "Your username"
            
        })
        
        loginAlert.addTextFieldWithConfigurationHandler({
            textfield in
            textfield.placeholder = "Your Password"
            textfield.secureTextEntry = true
            
        })
        
        loginAlert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = loginAlert.textFields as AnyObject! as NSArray
            let usernameTextField:UITextField = textFields.objectAtIndex(0) as UITextField
            let passwordTextField:UITextField = textFields.objectAtIndex(1) as UITextField
            
            PFUser.logInWithUsernameInBackground(usernameTextField.text, password: passwordTextField.text){
                (user:PFUser!, error:NSError!)->Void in
                if((user) != nil){
                    println("Login Successful")
                    var installation:PFInstallation = PFInstallation.currentInstallation()
                    installation.addUniqueObject("Reload", forKey: "channels")
                    installation["user"] = PFUser.currentUser()
                    installation.saveInBackgroundWithTarget(nil, selector: nil)
                    
                    
                    
                    
                }else{
                    println("Login Failed")
                }
            }
            
            
            
        }))
        
        
        
        loginAlert.addAction(UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.Default, handler: {
            alertAction in
            let textFields:NSArray = loginAlert.textFields as AnyObject! as NSArray
            let usernameTextField:UITextField = textFields.objectAtIndex(0) as UITextField
            let passwordTextField:UITextField = textFields.objectAtIndex(1) as UITextField
            
            var sweeter:PFUser = PFUser()
            sweeter.username = usernameTextField.text
            sweeter.password = passwordTextField.text
            
            sweeter.signUpInBackgroundWithBlock{
                (success:Bool!, error:NSError!)-> Void in
                
                if (error == nil) {
                    
                    println("Sign Up Successful")
                    
                    var imagePicker:UIImagePickerController = UIImagePickerController()
                    imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                    imagePicker.delegate = self
                    self.presentViewController(imagePicker, animated: true, completion: nil)
                    
                    var installation:PFInstallation = PFInstallation.currentInstallation()
                    installation.addUniqueObject("Reload", forKey: "channels")
                    installation["user"] = PFUser.currentUser()
                    installation.saveInBackgroundWithTarget(nil, selector: nil)

                    
                    
                    
                }else{
                    
                    println("Error")
                    
                }
            }
            
            
        }))
        
        self.presentViewController(loginAlert, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: NSDictionary!) {
        
        let pickedImage:UIImage = info.objectForKey(UIImagePickerControllerOriginalImage) as UIImage
        
        //Scale
        let scaledImage = self.scaleImageWith(pickedImage, and:CGSizeMake(80, 80))
        
        let imageData = UIImagePNGRepresentation(scaledImage)
        let imageFile:PFFile = PFFile(name: "Profile", data: imageData )
        
        PFUser.currentUser().setObject(imageFile , forKey: "profilePicture")
        PFUser.currentUser().save()
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        
        
        
    }
    
    func scaleImageWith(image:UIImage, and newSize:CGSize )-> UIImage{
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        return newImage
        
        
    }
    
    func logout(sender:UIButton){
        PFUser.logOut()
        self.showLoginSignUp()
        
        
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
        return timelineData.count
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell: SweetTableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as SweetTableViewCell
        
        //let sweet:PFObject = self.timelineData.objectAtIndex(indexPath.row) as PFObject
        let sweet: PFObject = self.timelineData[indexPath.row] as PFObject
        
        
        cell.sweetTextView.alpha = 0
        cell.timestampLabel.alpha = 0
        cell.usernameLabel.alpha = 0
        
        
        
        cell.sweetTextView.text = sweet.objectForKey("content") as String
        
        
        
        var dataFormatter:NSDateFormatter = NSDateFormatter()
        dataFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        cell.timestampLabel.text = dataFormatter.stringFromDate(sweet.createdAt)
        
        
        
        var findSweeter: PFQuery = PFUser.query()
        findSweeter.whereKey("objectId", equalTo: sweet.objectForKey("sweeter").objectId)
        
        
        
        findSweeter.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if (error == nil){
                if let actualObjects = objects {
                    let possibleUser = (actualObjects as NSArray).lastObject as? PFUser
                    if let user = possibleUser {
                        cell.usernameLabel.text = user.username
                        
                        //Profile Image
                        cell.profileImageView.alpha = 0
                        
                        let profileImage:PFFile = user["profilePicture"] as PFFile
                        
                        profileImage.getDataInBackgroundWithBlock{
                            (imageData:NSData! , error:NSError!)-> Void in
                            
                            if(error == nil) {
                                let image:UIImage = UIImage (data: imageData)!
                                cell.profileImageView.image = image
                                
                            }
                        }
                        
                        UIView.animateWithDuration(0.5, animations: {
                            cell.sweetTextView.alpha = 1
                            cell.timestampLabel.alpha = 1
                            cell.usernameLabel.alpha = 1
                            cell.profileImageView.alpha = 1
                        })
                        
                    }
                }

                    }
                }
               /*
                let user:PFUser = (objects as NSArray).lastObject as PFUser
                cell.usernameLabel.text = user.username
                
                //Profile Image
                cell.profileImageView.alpha = 0
                
                let profileImage:PFFile = user["profilePicture"] as PFFile
                
                profileImage.getDataInBackgroundWithBlock{
                    (imageData:NSData! , error:NSError!)-> Void in
                    
                    if(error == nil) {
                        let image:UIImage = UIImage (data: imageData)!
                        cell.profileImageView.image = image
                        
                                    }
                }

                UIView.animateWithDuration(0.5, animations: {
                    cell.sweetTextView.alpha = 1
                    cell.timestampLabel.alpha = 1
                    cell.usernameLabel.alpha = 1
                    cell.profileImageView.alpha = 1
                })
                
            }
        }
        */
        
        
        return cell
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
