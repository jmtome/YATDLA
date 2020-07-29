 //
 //  CategoryViewController.swift
 //  Yatdl
 //
 //  Created by Juan Manuel Tome on 29/07/2020.
 //  Copyright © 2020 Juan Manuel Tome. All rights reserved.
 //
 
 import UIKit
 import CoreData
 
 class CategoryViewController: UIViewController {
    
    var categories: [Category] = [Category]()
    
    var reuseIdentifier: String = "CategoryCell"
    var tableView: UITableView!
    
    //Get the CoreData Stack Context from the AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func loadView() {
        super.loadView()
        //Assign tableView to the viewController's view
        tableView = UITableView(frame: .zero, style: .plain)
        view = tableView
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UITableView Setup
        tableViewSetup()
        //We load items from core data
        loadCategories()
        //Setup NavCon navigation bar properties
        setupNavBar()
        definesPresentationContext = true
        
    }
    
    
    //MARK: - UI Setup
    func setupNavBar() {
        navigationItem.title = "Yet another todo list app"
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9568627451, green: 0.6352941176, blue: 0.3803921569, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewCategory(_:)))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    func tableViewSetup() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        //apparently the estimated row height was the responsible for the extra space at the bottom of the table view
        tableView.estimatedRowHeight = 0;
    }
    
    
    
    //MARK: - Action Methods
    @objc func addNewCategory(_ sender: UIBarButtonItem) {
        var textField: UITextField! = UITextField(frame: .zero)
        let ac = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { action in

            //We create a new Category with a core data context
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text
            
            self.categories.append(newCategory)
            // Save changes to core data
            self.saveCategories()
            // Could also do reloadTable() but its more costly
            self.tableView.insertRows(at: [IndexPath(item: self.categories.count - 1, section: 0)], with: .automatic)
        }
        ac.addAction(action)
        
        ac.addTextField { field in
            textField = field
            textField.placeholder = "Add a new category"
        }
        
        present(ac, animated: true)
    }
    
    //MARK: - Data Manipulation Methods
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("error saving category: \(error)")
        }
    }
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            self.categories = try context.fetch(request)
        } catch {
            print("error trying to load categories \(error)")
        }
    }
    
 }

 extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let todoListViewController = TodoListViewController()
        todoListViewController.selectedCategory = categories[indexPath.row]
        navigationController?.pushViewController(todoListViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, _, completion) in
            
            //The order here matters a huge deal:
            
            //1) first we must delete item from the core data permanent store, if we delete the item from the local array first, we will have an error because it will lose the proper row to find it to delete it
            //(because we are using categories[indexPath.row] to indicate which object we want to delete from coredata, thus if we delete the category first in the categories array we cant reference it to delete the coreData object
            self.context.delete(self.categories[indexPath.row])
            //2) delete item from local array, categories, this array populates the tableview
            self.categories.remove(at: indexPath.row)
            //3) commit changes to the database
            self.saveCategories()
            //4) delete rows/ update tableview
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        
        return swipeAction
    }
    
 }
 
 extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    
 }
