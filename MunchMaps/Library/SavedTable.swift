//
//  SavedTable.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 3/25/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit

class SavedTable: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FilterTabDelegate {
    
    @IBOutlet weak var saved_search: UISearchBar!
    @IBOutlet weak var saved_table: UITableView!
    var CuisineResults = [Search.Restaurant]()
    var saved_filter_results = [Search.Restaurant]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CuisineResults = Search.GlobalVariables.savedRest
        saved_filter_results = Search.GlobalVariables.savedRest
        saved_table.reloadData()
        setupSearchBar()

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
            saved_filter_results = CuisineResults
            saved_table.reloadData()
            return
        }
        saved_filter_results = CuisineResults.filter({Restaurant->Bool in
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
        saved_search.showsBookmarkButton = true
        saved_search.setImage(UIImage(named: "Filterbutton"), for: .bookmark, state: .normal)
    }
    
    func searchBarSearchButtonClicked(_ saved_search: UISearchBar) {
        saved_search.resignFirstResponder()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterMenu") as! FilterTab
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        popOverVC.delegate = self
        if (saved_search.isFirstResponder)
        {
            saved_search.resignFirstResponder()
        }
    }
    
    func popupDidDisappear() {
        if (FilterTab.CuisineGlobal.SavedCuisine.count == 0 && FilterTab.CuisineGlobal.removeCuisine.count == 0)
        {
            print("empty?")
            CuisineResults = Search.GlobalVariables.savedRest
            saved_filter_results = CuisineResults
            saved_table.reloadData()
        }
        else if (FilterTab.CuisineGlobal.SavedCuisine.count == 0)
        {
            CuisineResults = Search.GlobalVariables.savedRest
            for i in CuisineResults
            {
                outerloop: for j in i.cuisine
                {
                    for k in FilterTab.CuisineGlobal.removeCuisine
                    {
                        if (j == k)
                        {
                            CuisineResults = CuisineResults.filter {$0.name != i.name}
                            break outerloop
                        }
                    }
                }
            }
            saved_filter_results = CuisineResults
            saved_table.reloadData()
        }
        else
        {
            
            print(FilterTab.CuisineGlobal.SavedCuisine.count)
            CuisineResults.removeAll()
            for i in Search.GlobalVariables.savedRest
            {
                outerLoop: for j in i.cuisine
                {
                    for k in FilterTab.CuisineGlobal.SavedCuisine
                    {
                        if (j == k)
                        {
                            CuisineResults.append(i)
                            break outerLoop
                        }
                    }
                }
            }
            for i in CuisineResults
            {
                outerLoop: for j in i.cuisine
                {
                    for k in FilterTab.CuisineGlobal.removeCuisine
                    {
                        if (j == k)
                        {
                            CuisineResults = CuisineResults.filter {$0.name != i.name}
                            break outerLoop
                        }
                    }
                }
            }
            saved_filter_results = CuisineResults
            saved_table.reloadData()
        }
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
