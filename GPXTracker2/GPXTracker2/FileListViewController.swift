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
  var items: [URL] = []
  let fileManager = FileManager.default
  
  @IBOutlet var cancelButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    if !UserDefaults.standard.bool(forKey: IS_FIRST_RUN) {
      copySampleLogFromBundle()
      UserDefaults.standard.set(true, forKey: IS_FIRST_RUN)
    }
  
    if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
      navigationItem.leftBarButtonItems = []
    }
    
    reload()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func copySampleLogFromBundle() {
    guard let path = Bundle.main.resourcePath else { return }
    let fullPath = path + "/samples"
    let files = try! fileManager.contentsOfDirectory(atPath: fullPath)
    let destPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                       FileManager.SearchPathDomainMask.userDomainMask, true).first!
    for file in files {
      try! fileManager.copyItem(atPath: fullPath + "/" + file, toPath: destPath + "/" + file)
    }
  }
  
  func reload() {
    HUD.show(.progress)
    
    let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
      self.reloadWithDelay()
    }
  }
  
  func reloadWithDelay() {
    items.removeAll()
    
    let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    addFilesInDirectory(documentsUrl)
    tableView.reloadData()
    HUD.hide()
  }
  
  func addFilesInDirectory(_ path: URL) {
    do {
      let directoryContents = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions())
      
      var isDirectory: ObjCBool = false
      for content in directoryContents {
        if fileManager.fileExists(atPath: content.path, isDirectory:&isDirectory) {
          if isDirectory.boolValue {
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
  @IBAction func reloadButtonClicked(_ sender: AnyObject) {
    reload()
  }
  
  @IBAction func cancelButtonClicked(_ sender: AnyObject) {
    close()
  }
  
  func close(){
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: - UITableView
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    let path = items[(indexPath as NSIndexPath).row]
    let parser: Parser = Parser.init(path: path)
    cell.textLabel?.text = parser.title()
    cell.detailTextLabel?.text = path.lastPathComponent

    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      try! fileManager.removeItem(at: items[(indexPath as NSIndexPath).row])
      items.remove(at: (indexPath as NSIndexPath).row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let row = items[(indexPath as NSIndexPath).row]
    NotificationCenter.default.post(
      name: Notification.Name(rawValue: SelectFile),
      object: nil,
      userInfo: [SelectedFilePath: row])
    close()
  }
}
