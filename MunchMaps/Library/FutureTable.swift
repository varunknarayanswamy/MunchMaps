//
//  FutureTable.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 4/15/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit

class FutureTable: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, FilterTabDelegate {

    @IBOutlet weak var FutureSearchBar: UISearchBar!
    @IBOutlet weak var FutureTable: UITableView!
    
    var CuisineResults = [Search.Restaurant]()
    var future_Search_results = [Search.Restaurant]()
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in Search.GlobalVariables.futureRest
        {
            print(i.name)
        }
        future_Search_results = Search.GlobalVariables.futureRest
        CuisineResults = Search.GlobalVariables.futureRest
        setupSearchBar()
        FutureTable.reloadData()
    }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return future_Search_results.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = FutureTable.dequeueReusableCell(withIdentifier: "saved_cell") as? TableClass else {return UITableViewCell()}
            print("in cell")
            print(future_Search_results[indexPath.row].name)
            cell.restname.text = future_Search_results[indexPath.row].name
            cell.address.text = future_Search_results[indexPath.row].address
            return cell
        }
    
        private func setupSearchBar()
        {
            FutureSearchBar.delegate = self
            FutureSearchBar.showsBookmarkButton = true
            FutureSearchBar.setImage(UIImage(named: "Filterbutton"), for: .bookmark, state: .normal)
        }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            future_Search_results = CuisineResults
            FutureTable.reloadData()
            return
        }
        future_Search_results = CuisineResults.filter({Restaurant->Bool in
            Restaurant.name.contains(searchText)})
        FutureTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "future_restaurant", sender: future_Search_results[indexPath.row])
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FilterMenu") as! FilterTab
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        popOverVC.delegate = self
        if (FutureSearchBar.isFirstResponder)
        {
            FutureSearchBar.resignFirstResponder()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let svc = segue.destination as! RestaurantPage
        svc.rest_info = sender as! Search.Restaurant
    }
    
    func popupDidDisappear() {
        if (FilterTab.CuisineGlobal.SavedCuisine.count == 0 && FilterTab.CuisineGlobal.removeCuisine.count == 0)
        {
            print("empty?")
            CuisineResults = Search.GlobalVariables.futureRest
            future_Search_results = CuisineResults
            FutureTable.reloadData()
        }
        else if (FilterTab.CuisineGlobal.SavedCuisine.count == 0)
        {
            CuisineResults = Search.GlobalVariables.futureRest
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
            future_Search_results = CuisineResults
            FutureTable.reloadData()
        }
        else
        {
            
            print(FilterTab.CuisineGlobal.SavedCuisine.count)
            CuisineResults.removeAll()
            for i in Search.GlobalVariables.futureRest
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
            future_Search_results = CuisineResults
            FutureTable.reloadData()
        }
    }
    
    
    
        
    
        
    
        // Do any additional setup after loading the view.
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
