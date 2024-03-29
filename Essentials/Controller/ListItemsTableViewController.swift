import UIKit
import CoreData

class ListItemsTableViewController: UITableViewController {

    // swiftlint:disable force_cast
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // swiftlint:enable force_cast

    private var items = [Items]()
    var selectedList: Lists? {
        didSet {
            getAllItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = selectedList?.list
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Item",
                                      message: nil,
                                      preferredStyle: .alert)

        let action = UIAlertAction(title: "Add Item", style: .default) { [weak self] _ in

            guard let strongSelf = self else { return }

            guard
                let field = alert.textFields?.first,
                let item = field.text,
                !item.isEmpty
            else {
                return
            }
            strongSelf.createItem(content: item)
        }
        alert.addTextField { field in
            field.placeholder = "Item name"
            field.autocorrectionType = .no
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: CoreData
extension ListItemsTableViewController {

    func getAllItems() {
        let predicate = NSPredicate(format: "parentList.list MATCHES %@", selectedList!.list!)
        let request: NSFetchRequest<Items> = Items.fetchRequest()
        request.predicate = predicate
        do {
            items = try context.fetch(request)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView.reloadData()
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }

    func createItem(content: String) {
        let newItem = Items(context: context)
        newItem.item = content
        newItem.parentList = selectedList
        do {
            try context.save()
            getAllItems()
        } catch {
            print("Error saving context \(error)")
        }
    }

    func updateItem(item: Items, newContent: String) {
        item.item = newContent
        do {
            try context.save()
            getAllItems()
        } catch {
            print("Error saving context \(error)")
        }
    }

    func deleteItem(item: Items) {
        context.delete(item)
        do {
            try context.save()
            getAllItems()
        } catch {
            print("Error saving context \(error)")
        }
    }
}

extension ListItemsTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in

            guard let strongSelf = self else { return }

            let alert = UIAlertController(title: "Edit Item", message: "Edit your item", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.item
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
                guard
                    let field = alert.textFields?.first,
                    let newContent = field.text,
                    !newContent.isEmpty
                else {
                    return
                }
                self?.updateItem(item: item, newContent: newContent)
            }))
            strongSelf.present(alert, animated: true)
        }))
        present(sheet, animated: true)
    }

    // Swipe to Delete
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            let item = items[indexPath.row]
            let alert = UIAlertController(title: "Delete item", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.deleteItem(item: item)
                strongSelf.tableView.deleteRows(at: [indexPath], with: .right)
            }))
            present(alert, animated: true)
          }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.cell2Identifier, for: indexPath)
        cell.textLabel?.text = items[indexPath.row].item
        return cell
    }

}
