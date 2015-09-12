//
//  FileListViewController.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 9. 12..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import UIKit

class FileListViewController: UITableViewController {
  
  
  var items = [String]()
  @IBOutlet var cancelButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad{
      navigationItem.leftBarButtonItems = []
    }
    
    items.append("111")
    items.append("112")
    items.append("113")
    items.append("114")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func cancel(sender: AnyObject) {
    close()
  }
  
  func close(){
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - Table view data source
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
    
    cell.textLabel?.text = items[indexPath.row]
    cell.detailTextLabel?.text = "내용"
    
    return cell
  }

  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      items.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let row = items[indexPath.row]
    NSNotificationCenter.defaultCenter().postNotificationName(
      SelectFile,
      object: nil,
      userInfo: [SelectedFilePath: row])
    close()
  }
}
