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
        let alert = UIAlertController(title: "New list",
                                      message: nil,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add",
                                   style: .default) { [weak self] (action) in
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                return
            }
            self?.createItem(content: text)
        }
        alert.addTextField { field in
            field.placeholder = "Name of the list"
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Table View Delegate and Data Source
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
    
    // Swipe to Delete
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let list = lists[indexPath.row]
            let alert = UIAlertController(title: "Delete list", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
              self?.deleteItem(item: list)
              self?.tableView.deleteRows(at: [indexPath], with: .right)
            }))
            present(alert, animated: true)
          }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cell1Identifier, for: indexPath)
        cell.textLabel?.text = lists[indexPath.row].list
        return cell
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
