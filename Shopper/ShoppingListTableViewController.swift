//
//  ShoppingListTableViewController.swift
//  Shopper
//
//  Created by Lyons, Joseph John on 11/14/19.
//  Copyright © 2019 Lyons, Joseph John. All rights reserved.
//
import UIKit
import CoreData
import UserNotifications

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
        
        // make row height larger
        self.tableView.rowHeight = 84.0
        
    }
    
    func setTitle(){
        
        // declare local variable to store total cost of shopping list and initialize it to zero
        var totalCost = 0.0
        
        for list in shoppingListItems {
            totalCost += Double(list.price) * Double(list.quantity)
        }
        
        // if we have valid shopping list
        if let selectedShoppingList = selectedShoppingList {
            // get the shopping list name and set the title
            title = selectedShoppingList.name! + String(format: " $%.2f", totalCost)
        } else {
            // set the title to shopping list items
            title = "Shopping List Items"
        }
        
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
        } catch {
            print("Error deleting ShoppingListItems from core data!")
        }
        loadShoppingListItems()
    }
    
    func shoppingListDoneNotification() {
        
        var done = true
        
        // loop through shopping list items
        for item in shoppingListItems {
            // check if any of purchase attributes are false
            if item.purchased == false {
                // set done to false
                done = false
            }
        }
        
        // check if done is true
        if done == true {
            
            // create content objejct that controls the content and sound of the notification
            let content = UNMutableNotificationContent()
            content.title = "Shopper"
            content.body = "Shopping List Complete"
            content.sound = UNNotificationSound.default
            
            // create trigger object that defines when the notification will be sent and if it
            // should be sent repeatidly
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            // create request object that is responsible for creating the notification
            let request = UNNotificationRequest(identifier: "shopperIdentifier", content: content, trigger: trigger)
            
            // post the notification
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
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
                
                self.setTitle()
                
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
    
    // MARK: - Table view data source
       override func numberOfSections(in tableView: UITableView) -> Int {
           // return the number of sections
           return 1
       }

       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           // return the number of rows
           // we will have as many rows as there are shopping list items
           return shoppingListItems.count
       }

       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           
           let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListItemCell", for: indexPath)

           // Configure the cell...
           let shoppingListItem = shoppingListItems[indexPath.row]
           
           // set the cell title equal to the shopping list item name
           cell.textLabel?.text = shoppingListItem.name!
           // set detailTextLable numberOfLines property to zero
           cell.detailTextLabel!.numberOfLines = 0
           
           // set the cell subtitle equal to the shopping list item quantity and price
           cell.detailTextLabel?.text = String(shoppingListItem.quantity) + "\n" + String(shoppingListItem.price)
           
           // set the cell accessory type to checkmark if purchased is equal to true, else set it to none
           if (shoppingListItem.purchased == false){
               cell.accessoryType = .none
           } else {
               cell.accessoryType = .checkmark
           }

           return cell
       }
    
    
      // Override to support conditional editing of the table view.
      override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
          // Return false if you do not want the specified item to be editable.
          return true
      }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListItemCell", for: indexPath)

        // getting selected shopping list item
        let shoppingListItem = shoppingListItems[indexPath.row]
        
        // get quantity, price, and purchased indicator for selector shopping list item
        let sQuantity = String(shoppingListItem.quantity)
        let sPrice = String(shoppingListItem.price)
        let purchased = shoppingListItem.purchased
        
        if (purchased == true) {
            // if purchased indicator is true, set it to false and remove checkmark
            cell.accessoryType = .none
            shoppingListItem.purchased = false
            // if purchased indicator is false, set it to true and add checkmark
        } else {
            cell.accessoryType = .checkmark
        }
        
        // configure the table view cell
        cell.textLabel?.text = shoppingListItem.name
        cell.detailTextLabel!.numberOfLines = 0
        cell.detailTextLabel?.text = sQuantity + "\n" + sPrice
        
        // save update to purchased indicator
        self.saveShoppingListIems()
        
        // call deselectRow method to allow update to be visible in table view controller
        tableView.deselectRow(at: indexPath, animated: true)
        
        shoppingListDoneNotification()
        
      }
      
      
      // Override to support editing the table view.
      override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              // Delete the row from the data source
            let item = shoppingListItems[indexPath.row]
            deleteShoppingListItem(item: item)
            setTitle()
          }
          }
      
      
    

      /*
      // Override to support conditional rearranging of the table view.
      override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
          // Return false if you do not want the item to be re-orderable.
          return true
      }
      */
   
}
