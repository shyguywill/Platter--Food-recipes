//
//  SavedMealsViewController.swift
//  Platter
//
//  Created by Oluwasayofunmi Williams on 11/12/2018.
//  Copyright © 2018 Oluwasayofunmi Williams. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage


class SavedMealsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var savedMealTable: UITableView!
    
    var mealItem : Results<Meal>?
    let realm = try! Realm()
    var mealURL = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logo = UIImage(named: "logo")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        self.navigationItem.backBarButtonItem?.title = " "
        
        savedMealTable.delegate = self
        savedMealTable.dataSource = self
        
        savedMealTable.register(UINib(nibName: "CustomRecipes", bundle: nil), forCellReuseIdentifier: "CustomRecipesViewCell")
        
        savedMealTable.rowHeight = 130
        
        
        // Do any additional setup after loading the view.
    }
    
    //Reload items in database
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadMeals()
        
    }
    
    
    //MARK: - Table Datasource methods
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealItem?.count ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomRecipesViewCell", for: indexPath) as? CustomRecipesViewCell else{ fatalError("Unexpected cell type")}
        
        if let meal = mealItem{
            
            cell.mealName.text = meal[indexPath.row].title
            
            let imageURL = meal[indexPath.row].image_url
            
            cell.mealImage.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(named: "logo"))
            
            cell.ingredientCompleteness.text = nil
            
            cell.calorieCount.text = nil
            
            cell.publisherName.text = "Publisher: \(meal[indexPath.row].publisher)"
            
        }
        
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let meal = mealItem{
            
            mealURL = meal[indexPath.row].meal_url
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard Connectivity.isConnectedToInternet else{ return Connectivity.handleNotConnected(view: self)}
        
        performSegue(withIdentifier: "displaySavedMeal", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { (delete, indexpath) in
            
            if let meal = self.mealItem{
                
                let item = meal[indexPath.row]
                
                Platter.delete(deleteItem: item)
                
            }
            
            self.loadMeals()
            
        }
        
    
        return [delete]
    }
    
    //MARK: - Realm methods
    
    func loadMeals() {
        
        mealItem = realm.objects(Meal.self)
        
        savedMealTable.reloadData()
    }
    
    
    //MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? RecipePageController{
            
            destinationVC.savedMealDetails = mealURL
            destinationVC.identifier = 1
            
            
        }
        
    }
    
    

}


extension SavedMealsViewController: UISearchBarDelegate{
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
         searchBar.showsCancelButton = true
        
        return true
    }
    
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
  
        // Hide the cancel button
        searchBar.showsCancelButton = false
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
        
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        mealItem = mealItem?.filter("title CONTAINS[cd] %@",searchBar.text!)
        
        print ("Searching ...")
        savedMealTable.reloadData()
    }
    
  
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchBar.showsCancelButton = false
        
        if searchBar.text?.count == 0{
            
            loadMeals()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
        
        
    }
    
    
    
    
    
}
