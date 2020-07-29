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
    
    let flatColors: [UIColor] = [#colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1),#colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1),#colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1),#colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1),#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1),#colorLiteral(red: 0.8321695924, green: 0.985483706, blue: 0.4733308554, alpha: 1),#colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1),#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1),#colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1),#colorLiteral(red: 1, green: 0.1857388616, blue: 0.5733950138, alpha: 1),#colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1),#colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 1),#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1),#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1),#colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1),#colorLiteral(red: 0, green: 0.9810667634, blue: 0.5736914277, alpha: 1),#colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1),#colorLiteral(red: 0.9994240403, green: 0.9855536819, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1),#colorLiteral(red: 0.5808190107, green: 0.0884276256, blue: 0.3186392188, alpha: 1),#colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)]
    
    var itemArray: [Item] = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    //Get the CoreData Stack Context from the AppDelegate
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var reuseIdentifier: String = "TodoItemCell"
       
    var tableView: UITableView!
    let searchController: UISearchController! = UISearchController(searchResultsController: nil)
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //This is needed so that the searchbar from the searchcontroller starts hidden
        tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
    }
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
        //UISearchBar Setup
        setupSearchController()
        //We load items from core data
        loadItems()
        //Setup NavCon navigation bar properties
        setupNavBar()
        definesPresentationContext = true
        
    }
    
   
    //MARK: - UI Setup
    func setupNavBar() {
        navigationItem.title = "Items"
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9568627451, green: 0.6352941176, blue: 0.3803921569, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewItem(_:)))
        navigationItem.rightBarButtonItem = addButton
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    func tableViewSetup() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        //apparently the estimated row height was the responsible for the extra space at the bottom of the table view
        tableView.estimatedRowHeight = 0;
        
//        tableView.estimatedSectionHeaderHeight = 0;
//        tableView.estimatedSectionFooterHeight = 0
    }
   
    func setupSearchController() {
        //SearchController
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        // searchController.searchBar.barStyle = .black
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search Here"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
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
            newItem.parentCategory = self.selectedCategory
            newItem.colorString = self.flatColors.randomElement()?.toHexString()

            self.itemArray.append(newItem)
            // Save changes to core data
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
    
    //MARK: - Data manipulation methods
    func saveItems() {
        //New Code for CoreData management
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
    //we give the method a default item so that if no parameter is passed, it uses the default parameter
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil ) {
        //Load disk from CoreData Stack from context
        
        //we create a predicate to form a fetch request that asks for the items with a common parent category (the one clicked in CategoryViewController)
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        //we create a compound Predicate, which will be the passed predicate (if it exists) and a category predicate
        if let additionalPredicate = predicate {
            //we set the request predicate to a compound predicate, which is nothing more than many predicates joined with an AND
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            // if there is no additional predicate, then we just set the predicate to the category sort by default
            request.predicate = categoryPredicate
        }
        
        //We create a fetchRequest of type Item to fetch the data matching the predicates that the request has
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
        cell.backgroundColor = UIColor(hex: item.colorString!)
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
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash")
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeAction.performsFirstActionWithFullSwipe = true
        
        return swipeAction
    }
}


extension TodoListViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text!)
        print("pepe1")
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //we prepare a request to search for an item in order to read from the database
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        //now we need to set a predicate to query objects,
        //the format here says: search for the "title" attribute of each of our items, and look for titles containing the text passed by searchbar.text
        //[cd] : case insensitive, diacritic insensitive
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        //assign the predicate to the request predicate
        //Note: since now im passing a predicate and a request to the loadItems method, i will not set the request predicate here, for it will be done inside the loadItems method.
//        request.predicate = predicate
        //we now want to sort the data we get back with a sort descriptor
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        //now we add the sort descriptor to our request
        request.sortDescriptors = [sortDescriptor]
        //we now try, using the fetch request we just crafted, we load the items with the request
        self.loadItems(with: request, predicate: predicate)
        //finally, we now DO, reload our tableview
        self.tableView.reloadData()
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //check if the searchbar text value is zero, if so, show the original list of items
        if searchBar.text?.count == 0 {
            //load list with default fetch request
            loadItems()
            //reload the tableview
            self.tableView.reloadData()
            //resign first responder from searchbar
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
                //TODO: - Check this out, i want to resign the first responder, but the cancel button wont go away, so the only way i've found to do this is by dismissing the view (searchController) im not sure whats the appropriate way to do this.
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //TODO: - I need to do the same as in the method above
    }
    
}


extension UIColor {
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int = (Int)(red * 255) << 24 | (Int)(green * 255) << 16 | (Int)(blue * 255) << 8 | (Int)(alpha * 255) << 0
        return String(format: "#%08x", rgb)
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}




//old code
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
 
//old code
// Save to PropertyListEncoder
//        let encoder = PropertyListEncoder()
//        do {
//            let data = try encoder.encode(self.itemArray)
//            try data.write(to: self.dataFilePath!)
//        } catch {
//            print("error encoding item array \(error)")
//        }
        
