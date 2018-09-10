//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Joao Fernandes on 06/09/2018.
//  Copyright © 2018 Joao Fernandes. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    ////////////////////////////////////////////////
    // MARK: - VARIABLES                         //
    //////////////////////////////////////////////
    var categoryArray = [Category]()
    
    
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
        loadCategories()
        
    }
    
    
    ////////////////////////////////////////////////
    // MARK: - Tableview Datasource Methods      //
    //////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row].name
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categoryArray.count
        
    }
    
    
    ////////////////////////////////////////////////
    // MARK: - Tableview Delegate Methods        //
    //////////////////////////////////////////////
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //loadCategories()
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
            
        }
        
        
    }
    
    
    ////////////////////////////////////////////////
    // MARK: - Add New Items Button              //
    //////////////////////////////////////////////
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            self.saveCategories()
        
        }
        
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Add a new category"
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    ////////////////////////////////////////////////////
    // MARK: - Core Data loadItems() and saveItems() //
    //////////////////////////////////////////////////
    func saveCategories() {

        do {
            try context.save()
        } catch {
            print("Error saving context \(error)!")

        }
        self.tableView.reloadData()

    }


    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) { // "with" - external parameter, "request" - internal parameter and a default value, Item.fetchRequest()

        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }


}


