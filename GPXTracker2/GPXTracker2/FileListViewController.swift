//
//  FileListViewController.swift
//  GPXTracker2
//
//  Created by susemi99 on 2015. 9. 12..
//  Copyright © 2015년 susemi99. All rights reserved.
//

import UIKit
import PKHUD

class FileListViewController: UITableViewController {
  var items: [NSURL] = []
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
      try! fileManager.copyItemAtPath(path + "/" + file, toPath: destPath + "/" + file)
    }
  }
  
  func reload() {
    PKHUD.sharedHUD.contentView = PKHUDProgressView()
    PKHUD.sharedHUD.show()
    
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.reloadWithDelay()
    }
  }
  
  func reloadWithDelay() {
    items.removeAll()
    
    let documentsUrl =  fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    addFilesInDirectory(documentsUrl)
    tableView.reloadData()
    PKHUD.sharedHUD.hide()
  }
  
  func addFilesInDirectory(path: NSURL) {
    do {
      let directoryContents = try fileManager.contentsOfDirectoryAtURL(path, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
      
      var isDirectory: ObjCBool = false
      for content in directoryContents {
        if fileManager.fileExistsAtPath(content.path!, isDirectory:&isDirectory) {
          if isDirectory {
            addFilesInDirectory(content)
          }
          else {
            items.append(content)
          }
        }
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
    
    let path = items[indexPath.row]
    let parser: Parser = Parser.init(path: path)
    cell.textLabel?.text = parser.title()
    cell.detailTextLabel?.text = path.lastPathComponent

    return cell
  }
  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      try! fileManager.removeItemAtURL(items[indexPath.row])
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
