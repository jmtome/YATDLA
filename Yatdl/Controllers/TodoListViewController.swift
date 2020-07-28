//
//  ViewController.swift
//  Yatdl
//
//  Created by Juan Manuel Tome on 28/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import UIKit




class TodoListViewController: UIViewController {
    
    var itemArray: [Item] = [Item]()
    
    //Path to user documents sandbox filepath for the Items.plist file
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    
    var tableView: UITableView!
    var reuseIdentifier: String = "TodoItemCell"
    
    override func loadView() {
        super.loadView()
        tableView = UITableView(frame: .zero, style: .plain)
        self.view = tableView
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //dataFilePath = directory?.appendingPathComponent("Items.plist")
        
        //UITableView Setup
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        let newItem = Item()
        newItem.title = "Find Mike"
        itemArray.append(newItem)
        
        //We load items from plist file
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
            let newItem = Item()
            newItem.title = textField.text!
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
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
        } catch {
            print("error encoding item array \(error)")
        }
    }
    func loadItems() {
        do{
            if let data = try? Data(contentsOf: dataFilePath!) {
                let decoder = PropertyListDecoder()
                do{
                    itemArray = try decoder.decode([Item].self, from: data)
                } catch {
                    print("error decoding item array \(error)")
                }
            }
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
        //Save checkmark toggle to file
        saveItems()
        //Reload the cell whose checkmark toogle changed
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
