//
//  ViewController.swift
//  Yatdl
//
//  Created by Juan Manuel Tome on 28/07/2020.
//  Copyright © 2020 Juan Manuel Tome. All rights reserved.
//

import UIKit

class TodoListViewController: UIViewController {

    let itemArray: [String] = ["Buy milk", "Buy eggs", "Make cake", "Profit"]
    
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

        //Setup NavCon navigation bar properties
        navigationItem.title = "Yatdl"
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9568627451, green: 0.6352941176, blue: 0.3803921569, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
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
