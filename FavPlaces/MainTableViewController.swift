//
//  MainTableViewController.swift
//  FavPlaces
//
//  Created by Алексей Зимовец on 11.07.2020.
//  Copyright © 2020 Алексей Зимовец. All rights reserved.
//

import UIKit
import RealmSwift

class MainTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let searchController = UISearchController(searchResultsController: nil)
    private var places: Results<Places>!
    private var filteredPlaces: Results<Places>!
    private var ascendingSorting = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    
    private var isFiltering: Bool{
        return searchController.isActive && !searchBarIsEmpty
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversSortingButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = realm.objects(Places.self)
        
        //Setup the search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering{
            return filteredPlaces.count
        }
        return places.isEmpty ? 0 : places.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        var place = Places()
        if isFiltering{
             place = filteredPlaces[indexPath.row]
        } else{
            place = places[indexPath.row]
        }
        
        cell.LabelName.text = place.name
        cell.LabelLocation.text = place.location
        cell.LabelType.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.height / 2
        cell.imageOfPlace.clipsToBounds = true
        
        return cell
    }
    // MARK: Table view deligate
    
     func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let palce = places[indexPath.row]
        let contextItem = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            StorageManager.deliteObject(palce)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

        return swipeActions
    }
    
     // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let place: Places
            if isFiltering{
                place = filteredPlaces[indexPath.row]
            } else {
                place = places[indexPath.row]
            }
            let newPlaceVC = segue.destination as! NewPlacesTableViewController
            newPlaceVC.currentPlace = place
        }
    }
    

    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlacesVC = segue.source as? NewPlacesTableViewController else {return}
        newPlacesVC.savePlaces()
        tableView.reloadData()
    }
    
    @IBAction func sortingReversButton(_ sender: Any) {
        
        ascendingSorting.toggle()
        
        if ascendingSorting{
            reversSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else{
            reversSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        sorting()
    }
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        
        sorting()
    }
    
    private func sorting (){
        
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
            } else {
                places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
            tableView.reloadData()
        }
    }
extension MainTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String){
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
}
