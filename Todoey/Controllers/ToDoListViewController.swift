//
//  ViewController.swift
//  Todoey
//
//  Created by Joao Fernandes on 04/09/2018.
//  Copyright © 2018 Joao Fernandes. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    
    ////////////////////////////////////////////////
    // MARK: - VARIABLES                         //
    //////////////////////////////////////////////
    var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    
    ////////////////////////////////////////////////
    // MARK: - CONSTANTS                         //
    //////////////////////////////////////////////
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    ////////////////////////////////////////////////
    // MARK: - viewDidLoad() method              //
    //////////////////////////////////////////////
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
       
        
    }
    
    
    ////////////////////////////////////////////////
    // MARK: - Tableview Datasource Methods      //
    //////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
        
    }
    
    
    ////////////////////////////////////////////////
    // MARK: - Tableview Delegate Methods        //
    //////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        // order of instructions is important to delete items
        // context.delete(itemArray[indexPath.row])
        // itemArray.remove(at: indexPath.row)
        // itemArray[indexPath.row].setValue("Completed", forKey: "title")
        
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
   
    }
    
    
    ////////////////////////////////////////////////
    // MARK: - Add New Items Button              //
    //////////////////////////////////////////////
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in

            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
           // self.defaults.set(self.itemArray, forKey: "TodoListArray")
            self.saveItems()
 
        }
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    ////////////////////////////////////////////////////
    // MARK: - Core Data loadItems() and saveItems() //
    //////////////////////////////////////////////////
    func saveItems() {

        do {
            try context.save()
        } catch {
            print("Error saving context \(error)!")
          
        }
        self.tableView.reloadData()
        
    }

    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) { // "with" - external parameter, "request" - internal parameter and a default value, Item.fetchRequest()
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
             itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }

    
}


////////////////////////////////////////////////////
// MARK: - Extensions                            //
//////////////////////////////////////////////////
extension ToDoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)
   
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
         
        }
    }
    
}

