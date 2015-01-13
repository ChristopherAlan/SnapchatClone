//
//  UserTableViewController.swift
//  SnapchatClone
//
//  Created by Christopher Alan on 1/12/15.
//  Copyright (c) 2015 Christopher Alan. All rights reserved.
//

import UIKit

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var userArray = [String]()
    var selectedReceiver = 0
    var refresh = UIRefreshControl()
    
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUsers()
        
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: "refreshed", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresh)
        
        
    }
    
    func updateUsers() {
        
        var query = PFUser.query()
        query.whereKey("username", notEqualTo: PFUser.currentUser().username)
        var users  = query.findObjects()
        
        for user in users {
            
            //println(user.username)
            userArray.append(user.username)
            tableView.reloadData()
            
        }
        self.refresh.endRefreshing()
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("checkForMessage"), userInfo: nil, repeats: true) // push notifications is also an option here instead of a timer to fetch new images.
    }
    
    func checkForMessage() {
            
            var query = PFQuery(className: "image")
            query.whereKey("receiverUsername", equalTo: PFUser.currentUser().username)
            var images = query.findObjects()
        
            var done = false
        
            for image in images {
            
                if done == false {
                
                    var imageView:PFImageView = PFImageView()
                    imageView.file = image["photo"] as PFFile
                    imageView.loadInBackground({(photo, error) -> Void in
                    
                        if error == nil {
                        
                            var senderUsername: AnyObject! = image["senderUsername"]
                            self.displayAlert("You have a message!", error: "Message from \(senderUsername)")
                        
                            var displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                            displayedImage.image = photo
                            displayedImage.tag = 3
                            displayedImage.contentMode = UIViewContentMode.ScaleAspectFill
                            self.view.addSubview(displayedImage)
                        
                            self.timer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)
                            image.delete()
                        }
                
                    })
                
                    done = true
                }
            
            
        }
    }
    
    func refreshed() {
        println("refreshed")
        updateUsers()
    }
    
    func hideMessage() {
        
        // could add a tag if we had ultiple things to remove.
        for subview in self.view.subviews {
            if subview.tag == 3 {
                subview.removeFromSuperview()
            }
        }
    }

    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        // Upload to parse
        var imageToSend = PFObject(className:"image")
        imageToSend["photo"] = PFFile(name: "image.jpg", data: UIImageJPEGRepresentation(image, 0.8))
        imageToSend["senderUsername"] = PFUser.currentUser().username
        imageToSend["receiverUsername"] = userArray[selectedReceiver]
        //imageToSend.saveInBackground() // use save with block
        imageToSend.saveInBackgroundWithBlock {
            (success: Bool!, error: NSError!) -> Void in
            if error == nil {
                
                self.displayAlert("Success", error: "Image has been sent.")
                
            } else {
                self.displayAlert("Error", error: "Please try again.")
                println(error)
            }
        }
    }
    
    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
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
        return userArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = userArray[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedReceiver = indexPath.row
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        //image.sourceType = UIImagePickerControllerSourceType.Camera
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logout" {
            PFUser.logOut()
            var currentUser = PFUser.currentUser()
        }
    }

   

}
