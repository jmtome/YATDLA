//
//  ViewController.swift
//  Yatdl
//
//  Created by Juan Manuel Tome on 28/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import UIKit
import CoreData



class TodoListViewController: UIViewController {
    
    var itemArray: [Item] = [Item]()
    
    //Path to user documents sandbox filepath for the Items.plist file
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    //Get the CoreData Stack Context from the AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    var tableView: UITableView!
    var reuseIdentifier: String = "TodoItemCell"
    
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: .zero, style: .plain)
        self.view = tableView
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //UITableView Setup
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
   
        //We load items from core data
        loadItems()
        
        //Setup NavCon navigation bar properties
        navigationItem.title = "Yatdl"
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9568627451, green: 0.6352941176, blue: 0.3803921569, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItem(_:)))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.rightBarButtonItem?.tintColor = .white
        
    }
    
    
    //MARK: - Action Methods
    @objc private func addNewItem(_ sender: UIBarButtonItem) {
        // Create Alert Controller to prompt the user to input new data
        var textField: UITextField = UITextField()
        
        let ac = UIAlertController(title: "Add new item to the list", message: "", preferredStyle: .alert)
        let newItemAction = UIAlertAction(title: "Add Item", style: .default) { action in
            
            // What happens when the add button is clicked
            
            //We create a new Item with a core data context
            let newItem = Item(context: self.context)
        
            newItem.title = textField.text!
            newItem.done = false
            self.itemArray.append(newItem)
            // Save changes to plist file
            self.saveItems()
            // Could also do reloadTable() but its more costly
            self.tableView.insertRows(at: [IndexPath(row: self.itemArray.count - 1, section: 0) ], with: .left)
        }
        // Add a new textfield to the alert controller to input data
        ac.addTextField { alertTextField in
            textField.placeholder = "Add New Item"
            textField = alertTextField
        }
        ac.addAction(newItemAction)
        present(ac, animated: true, completion: nil)
        
    }
    
    //MARK: - Model manipulation methods
    func saveItems() {
        // Save to PropertyListEncoder
//        let encoder = PropertyListEncoder()
//        do {
//            let data = try encoder.encode(self.itemArray)
//            try data.write(to: self.dataFilePath!)
//        } catch {
//            print("error encoding item array \(error)")
//        }
        
        //New Code for CoreData management
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
        
    }
    func loadItems() {
        //Load items from PropertyListDecoder
//        do{
//            if let data = try? Data(contentsOf: dataFilePath!) {
//                let decoder = PropertyListDecoder()
//                do{
//                    itemArray = try decoder.decode([Item].self, from: data)
//                } catch {
//                    print("error decoding item array \(error)")
//                }
//            }
//        }
        
        //Load disk from CoreData Stack from context
        
        //We create a fetchRequest of type Item
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        do {
            // we try to make a fetch request with the context, with a fetchRequest of type Item
            //we know that the fetch request will return an Item array
            self.itemArray = try context.fetch(request)
            
        } catch {
            print("error fetching data from context")
        }
        
        
    }
    
    
    
}


//MARK: - TableView DataSource Methods
extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Create reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        //Get item
        let item = self.itemArray[indexPath.row]
        //Assign cell properties
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        print("cfra")
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
}
//MARK: - TableView Delegate Methods
extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Select and unselect the checkmark
        itemArray[indexPath.row].done.toggle()
        //Modifying Item attributes is the same as doing this:
//        itemArray[indexPath.row].setValue("NewTitle", forKey: "title")
        //Save checkmark toggle to file
        saveItems()
        //Reload the cell whose checkmark toogle changed
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, _, completion) in
            
            //The order here matters a huge deal:
            
            //1) first we must delete item from the core data permanent store, if we delete the item from the local array first, we will have an error because it will lose the proper row to find it to delete it
            //(because we are using itemArray[indexPath.row] to indicate which object we want to delete from coredata, thus if we delete the item first in the itemArray we cant reference it to delete the coreData object
            self.context.delete(self.itemArray[indexPath.row])
            //2) delete item from local array, ItemArray, this array populates the tableview
            self.itemArray.remove(at: indexPath.row)
            //3) commit changes to the database
            self.saveItems()
            //4) delete rows/ update tableview
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            completion(true)
        }
        deleteAction.backgroundColor = .systemBlue
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        
        return swipeAction
    }
}
