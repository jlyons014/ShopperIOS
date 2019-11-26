//
//  ShoppingListTableViewController.swift
//  Shopper
//
//  Created by Lyons, Joseph John on 11/14/19.
//  Copyright © 2019 Lyons, Joseph John. All rights reserved.
//
import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController {
    // create a reference to a context
    let context = (UIApplication.shared.delegate as!
        AppDelegate).persistentContainer.viewContext
    
    // create a variable that will contain the row of the selected shopping list
    var selectedShoppingList: ShoppingList?

    // create an array of ShoppingListItems
    var shoppingListItems = [ShoppingListItem] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call load shoppinh list items method
        loadShoppingListItems()
        

        // if we have valid shopping list
        if let selectedShoppingList = selectedShoppingList {
            // get the shopping list name and set the title
            title = selectedShoppingList.name!
        } else {
            // set the title to shopping list items
            title = "Shopping List Items"
        }
        
        // make row height larger
        self.tableView.rowHeight = 84.0
        
        
    }
    
     func loadShoppingListItems (){
            // check if shopper table view controller has passed a valid shopping list
            if let list = selectedShoppingList {
                if let listItems = list.items?.allObjects as? [ShoppingListItem] {
                    //store constant in ShoppingListItems array
                    shoppingListItems = listItems
                    
                }
            }
            // reload fetched data in table view controller
            tableView.reloadData()
    }
       
       // save shoppingList entity
       func saveShoppingListIems () {
           do {
               // use context to save ShoppingLists into Core Data
               try context.save()
           } catch {
               print("Error saving ShoppingListItems to Core Data!")
           }
           
           // reload the data in the Table View Controller
           tableView.reloadData()
           
       }
       
    func deleteShoppingListItem(item: ShoppingListItem){
        context.delete(item)
        do{
            try context.save()
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // declare Text Field variables for the input of the name, store, and date
            var nameTextField = UITextField()
            var priceTextField = UITextField()
            var quantityTextField = UITextField()
            
            // create an Alert controllerr
            let alert = UIAlertController(title: "Add Shopping List", message: "", preferredStyle: .alert)
            
            // define an action that will occur when the Add List button is pushed
            let action = UIAlertAction(title: "Add List", style: .default, handler: { (action) in
                
                // create an instance of a shoppingList entity
                let newShoppingListItem = ShoppingListItem(context: self.context)
                
                // get name, store, and date input by the user and store them in ShoppingList entity
                newShoppingListItem.name = nameTextField.text!
                newShoppingListItem.price = Double(priceTextField.text!)!
                newShoppingListItem.quantity = Int64(quantityTextField.text!)!
                newShoppingListItem.purchased = false
                newShoppingListItem.shoppingList = self.selectedShoppingList
                
                // add shoppingList entity into array
                self.shoppingListItems.append(newShoppingListItem)
                
                // save ShoppingLists into core data
                self.saveShoppingListIems()
                
            })
            
            // disable the action that will occur when the Add List button is pushrd
            action.isEnabled = false
            
            // define an action that will occur when the Cancel is pushed
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { (cancelAction) in
                
                
            })
            
            // add actions into Alert controler
            alert.addAction(action)
            alert.addAction(cancelAction)
            
            // add the text fields into the alert controller
            alert.addTextField(configurationHandler: { (field) in
                nameTextField = field
                nameTextField.placeholder = "Enter Name"
                nameTextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
            })
            // add the text fields into the alert controller
            alert.addTextField(configurationHandler: { (field) in
                priceTextField = field
                priceTextField.placeholder = "Enter Price"
                priceTextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
            })
            // add the text fields into the alert controller
            alert.addTextField(configurationHandler: { (field) in
                quantityTextField = field
                quantityTextField.placeholder = "Enter Quantity"
                quantityTextField.addTarget(self, action: #selector((self.alertTextFieldDidChange)), for: .editingChanged)
            })
            
            // display the alert controller
            present(alert, animated: true, completion: nil)
            
        }
        
        @objc func alertTextFieldDidChange() {
            
            // get a reference to the Alert Controller
            let alertController = self.presentedViewController as! UIAlertController
            
            // get a reference to the action that allows the user to add a ShoppingList
            let action = alertController.actions[0]
            
            // get references to the text in the Text Fields
            if let name = alertController.textFields![0].text, let
                price = alertController.textFields![1].text, let
                quantity = alertController.textFields![2].text {
                
                //trim whitespaces from the text
                let trimmedName = name.trimmingCharacters(in: .whitespaces)
                let trimmedPrice = price.trimmingCharacters(in: .whitespaces)
                let trimmedQuantity = quantity.trimmingCharacters(in: .whitespaces)
                
                // check if the trimmed text isnt empty and if it isnt, enable the action
                // that allows the user to add a ShoppingList
                if(!trimmedName.isEmpty && !trimmedPrice.isEmpty && !trimmedQuantity.isEmpty) {
                    action.isEnabled = true
                }
            }
    }
    
    
      // Override to support conditional editing of the table view.
      override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
          // Return false if you do not want the specified item to be editable.
          return true
      }
      
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListItemCell", for: indexPath)
    }

      /*
      // Override to support editing the table view.
      override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              // Delete the row from the data source
              tableView.deleteRows(at: [indexPath], with: .fade)
          } else if editingStyle == .insert {
              // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
          }
      }
      */

      /*
      // Override to support conditional rearranging of the table view.
      override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
          // Return false if you do not want the item to be re-orderable.
          return true
      }
      */
   
}
