//
//  ViewController.swift
//  Yatdl
//
//  Created by Juan Manuel Tome on 28/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import UIKit

class TodoListViewController: UIViewController {

    var itemArray: [String] = ["Buy milk", "Buy eggs", "Make cake", "Profit"]
    //UserDefaults saves to a Plist file
    let defaults = UserDefaults.standard
    
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
        
        //If we have saved info on UserDefaults, load it, if not, we still have the default itemArray 
        if let items = defaults.object(forKey: "TodoListArray") as? [String] {
            itemArray = items
        }

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
            self.itemArray.append(textField.text!)
            // Save to UserDefaults
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
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

}

//MARK: - TableView DataSource Methods
extension TodoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let item = self.itemArray[indexPath.row]
        cell.textLabel?.text = item
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
        
}
//MARK: - TableView Delegate Methods
extension TodoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
