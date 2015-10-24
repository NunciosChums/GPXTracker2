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
  let fileManager = NSFileManager.defaultManager()
  
  @IBOutlet var cancelButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if !NSUserDefaults .standardUserDefaults().boolForKey(IS_FIRST_RUN) {
      copySampleLogFromBundle()
      NSUserDefaults .standardUserDefaults().setBool(true, forKey: IS_FIRST_RUN)
    }
    
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad{
      navigationItem.leftBarButtonItems = []
    }
    
    reload()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func copySampleLogFromBundle() {
    let path = NSBundle.mainBundle().resourcePath! + "/samples"
    let files = try! fileManager.contentsOfDirectoryAtPath(path)
    
    let destPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
    
    for file in files {
      do{
        try fileManager.copyItemAtPath(path + "/" + file, toPath: destPath + "/" + file)
      } catch {
      }
    }
  }
  
  func reload() {
    items.removeAll()
    
    let documentsUrl =  fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    do {
      let files = try fileManager.contentsOfDirectoryAtURL(documentsUrl, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
      
      for file in files {
        items.append(file.lastPathComponent!)
      }
    } catch let error as NSError {
      print(error.localizedDescription)
    }
  }
  
  // MARK: - User Action
  @IBAction func reloadButtonClicked(sender: AnyObject) {
    reload()
  }
  
  @IBAction func cancelButtonClicked(sender: AnyObject) {
    close()
  }
  
  func close(){
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - UITableView
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
