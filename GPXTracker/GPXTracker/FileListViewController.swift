import PKHUD
import UIKit

class FileListViewController: UITableViewController {
  var items: [GTFile] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
      navigationItem.leftBarButtonItems = []
    }

    if !UserDefaults.hasLaunchedBefore {
      FileManager.default.copyBundleToDocumentDirectory()
      UserDefaults.hasLaunchedBefore = true
    }

    reload()
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
    items.removeAll()

    HUD.show(.progress)

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      let files = FileManager.default.files()
      DispatchQueue.main.async { [weak self] in
        self?.items = files
        self?.tableView.reloadData()
        HUD.hide()
      }
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

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let row = indexPath.row
      guard row < items.count else { return }
      FileManager.default.delete(file: items[row])
      items.remove(at: row)
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    NotificationCenter.default.post(name: Notification.Name(rawValue: SELECTED_FILE),
                                    object: nil,
                                    userInfo: [SELECTED_FILE_PATH: items[indexPath.row]])
    close()
  }
}
