//
//  ListItemsTableViewController.swift
//  Essentials
//
//  Created by Abhinay Pratap on 25/06/22.
//

import UIKit
import CoreData

class ListItemsTableViewController: UITableViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
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
                                      message: "",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item",
                                   style: .default) { [weak self] (action) in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self?.createItem(content: text)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new moment"
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cell2Identifier, for: indexPath)
        cell.textLabel?.text = items[indexPath.row].item
        return cell
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
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            let alert = UIAlertController(title: "Edit Item", message: "Edit your item", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.item
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self] _ in
                guard let field = alert.textFields?.first, let newContent = field.text, !newContent.isEmpty else {
                    return
                }
                self?.updateItem(item: item, newContent: newContent)
            }))
            self.present(alert, animated: true)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))
        present(sheet, animated: true)
    }
    
    // Swipe to Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteItem(item: items[indexPath.row])
//            tableView.deleteRows(at: [indexPath], with: .bottom)
            tableView.deleteRows(at: [indexPath], with: .right)
        }
    }
}
