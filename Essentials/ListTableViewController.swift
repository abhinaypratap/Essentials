//
//  ListTableViewController.swift
//  Essentials
//
//  Created by Abhinay Pratap on 25/06/22.
//
// TODO: stop user from making 2 or more lists or list items with same name

import UIKit
import CoreData

class ListTableViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var lists = [Lists]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        title = "Lists"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add New Item",
                                      message: "",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add",
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
        return lists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cell1Identifier, for: indexPath)
        cell.textLabel?.text = lists[indexPath.row].list
        return cell
    }

}

// MARK: - Table View Delegate
extension ListTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.segue1Identifier, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ListItemsTableViewController
        if let indexPath = tableView.indexPathForSelectedRow {
                destination.selectedList = lists[indexPath.row]
        }
    }
}



extension ListTableViewController {
    
    func getAllItems() {
        do {
            lists = try context.fetch(Lists.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error fetching data from context \(error)")
        }
    }
    
    func createItem(content: String) {
        let newItem = Lists(context: context)
        newItem.list = content
        do {
            try context.save()
            getAllItems()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func updateItem(item: Lists, newContent: String) {
        item.list = newContent
        do {
            try context.save()
            getAllItems()
        } catch {
            print("Error saving context \(error)")
        }
    }
    
    func deleteItem(item: Lists) {
        context.delete(item)
        do {
            try context.save()
            getAllItems()
        } catch {
            print("Error saving context \(error)")
        }
    }
}

extension ListTableViewController {
    // Swipe to Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteItem(item: lists[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .right)
        }
    }
}
