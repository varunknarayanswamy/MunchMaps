//
//  SavedTable.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 3/25/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit

class SavedTable: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var saved_search: UISearchBar!
    @IBOutlet weak var saved_table: UITableView!
    var saved_filter_results = [Search.Restaurant]()
    
    override func viewDidLoad() {
        for i in Search.GlobalVariables.savedRest
        {
            print(i.name)
        }
        saved_filter_results = Search.GlobalVariables.savedRest
        saved_table.reloadData()
        setupSearchBar()
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ saved_table: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = saved_table.dequeueReusableCell(withIdentifier: "saved_cell") as? TableClass else {return UITableViewCell()}
    print("in cell")
    print(saved_filter_results[indexPath.row].name)
    cell.restname.text = saved_filter_results[indexPath.row].name
    cell.address.text = saved_filter_results[indexPath.row].address
    return cell
    }
    
    func searchBar(_ saved_search: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            print("hello")
            saved_filter_results = Search.GlobalVariables.savedRest
            saved_table.reloadData()
            return
        }
        print("hello")
        saved_filter_results = Search.GlobalVariables.savedRest.filter({Restaurant->Bool in
            Restaurant.name.contains(searchText)})
            saved_table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return saved_filter_results.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "saved_restaurant", sender: saved_filter_results[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let svc = segue.destination as! RestaurantPage
        svc.rest_info = sender as! Search.Restaurant
    }
    
    private func setupSearchBar()
    {
        saved_search.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ saved_search: UISearchBar) {
        saved_search.resignFirstResponder()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
