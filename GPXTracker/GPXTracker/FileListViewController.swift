import UIKit
import PKHUD

class FileListViewController: UITableViewController {
  var items: [GTFile] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad{
      navigationItem.leftBarButtonItems = []
    }
    
    if !UserDefaults.standard.bool(forKey: IS_FIRST_RUN) {
      FileController.copyBundleToFolder()
      UserDefaults.standard.set(true, forKey: IS_FIRST_RUN)
    }
  
    reload()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - User Action
  @IBAction func cancelButtonClicked(_ sender: AnyObject) {
    close()
  }
  
  func close() {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func reloadButtonClicked(_ sender: Any) {
    reload()
  }
  
  func reload() {
    self.items.removeAll()
    
    HUD.show(.progress)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      self.items = FileController.files()
      self.tableView.reloadData()
      HUD.hide()
    }
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
    let file = items[indexPath.row]
    cell.textLabel?.text = file.fullName
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let row = indexPath.row
      FileController.delete(file: self.items[row])
      self.items.remove(at: row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: SELECTED_FILE),
                                    object: nil,
                                    userInfo: [SELECTED_FILE_PATH : self.items[indexPath.row]])
    close()
  }
}
