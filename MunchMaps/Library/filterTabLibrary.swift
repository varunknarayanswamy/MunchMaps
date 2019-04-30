//
//  filterTabLibrary.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 4/28/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit

class filterTabLibrary: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    public var delegate: filterTabLibraryDelegate?
    @IBOutlet weak var FilterSearch: UISearchBar!
    @IBOutlet weak var FilterTable: UITableView!
    struct cuisine {
        var name: String
        var saved: String
        var id: String
        
        init(name: String, saved: String, id: String) {
            self.name = name
            self.saved = saved
            self.id = id
        }
    }
    var filterArray = [cuisine]()
    struct CuisineGlobal
    {
        static var sortby: String = "cost"
        static var order: String = "asc"
        static var SavedCuisine = [String]()
        static var removeCuisine = [String]()
        static var CuisineArray = [cuisine(name: "American", saved: "unpressed", id: "1"), cuisine(name: "Asian", saved: "unpressed", id: "3"), cuisine(name: "Bagels", saved: "unpressed", id: "955"), cuisine(name: "Bakery", saved: "unpressed", id: "5"),cuisine(name: "Bar Food", saved: "unpressed", id: "227"), cuisine(name: "Burger", saved: "unpressed", id: "168"), cuisine(name: "Cafe", saved: "unpressed", id: "30"), cuisine(name: "Chinese", saved: "unpressed", id: "25"), cuisine(name: "Deli", saved: "unpressed", id: "192"),cuisine(name: "Fast Food", saved: "unpressed", id: "40"), cuisine(name: "French", saved: "unpressed", id: "45"), cuisine(name: "Frozen Yogurt", saved: "unpressed", id: "501"), cuisine(name: "Greek", saved: "unpressed", id: "156"), cuisine(name: "Healthy Food", saved: "unpressed", id: "143"), cuisine(name: "Ice Cream", saved: "unpressed", id: "233"), cuisine(name: "Indian", saved: "unpressed", id: "148"), cuisine(name: "Italian", saved: "unpressed", id: "55"), cuisine(name: "Japanese", saved: "unpressed", id: "60"), cuisine(name: "Korean", saved: "unpressed", id: "67"), cuisine(name: "Mediterranean", saved: "unpressed", id: "70"), cuisine(name: "Mexican", saved: "unpressed", id: "73"), cuisine(name: "Nepalese", saved: "unpressed", id: "117"), cuisine(name: "Pizza", saved: "unpressed", id: "82"), cuisine(name: "Salad", saved: "unpressed", id: "998"), cuisine(name: "Sandwich", saved: "unpressed", id: "304"), cuisine(name: "Spanish", saved: "unpressed", id: "89"), cuisine(name: "Steak", saved: "unpressed", id: "141"), cuisine(name: "Sushi", saved: "unpressed", id: "177"), cuisine(name: "Taco", saved: "unpressed", id: "997"), cuisine(name: "Tapas", saved: "unpressed", id: "179"), cuisine(name: "Thai", saved: "unpressed", id: "95"), cuisine(name: "Vegetarian", saved: "unpressed", id: "308")]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("is this working")
        filterArray = CuisineGlobal.CuisineArray
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        setupSearchBar()
        // Do any additional setup after loading the view.
    }
    
    private func setupSearchBar()
    {
        FilterSearch.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filterArray = CuisineGlobal.CuisineArray
            FilterTable.reloadData()
            print("empty")
            return
        }
        
        /*filterArray = CuisineArray.filter({Restaurant->Bool in
         Restaurant.name.contains(searchText)})*/
        print("typing")
        filterArray = CuisineGlobal.CuisineArray.filter{$0.name.contains(searchText)}
        FilterTable.reloadData()
    }
    
    
    
    @IBAction func CloseTab(_ sender: Any) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
        self.view.removeFromSuperview()
        delegate?.popupDidDisappear()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CuisineCell") as? FilterCellTableViewCell else {return UITableViewCell()}
        cell.CuisineLabel.text = filterArray[indexPath.row].name
        if (filterArray[indexPath.row].saved == "unpressed")
        {
            cell.Circle.image = UIImage(named: "circle")
            cell.state = "unpressed"
        }
        else if (filterArray[indexPath.row].saved == "selected")
        {
            cell.Circle.image = UIImage(named: "circleselected")
            cell.state = "selected"
        }
        else
        {
            cell.Circle.image = UIImage(named: "circleDeselected")
            cell.state = "deselected"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = self.FilterTable.cellForRow(at: indexPath) as! FilterCellTableViewCell
        let ind = CuisineGlobal.CuisineArray.firstIndex(where: {$0.name == filterArray[indexPath.row].name})
        if (cell.state == "unpressed")
        {
            cell.Circle.image = UIImage(named: "circleselected")
            cell.state = "selected"
            CuisineGlobal.SavedCuisine.append(filterArray[indexPath.row].name)
            CuisineGlobal.CuisineArray[ind!].saved = "selected"
        }
        else if (cell.state == "selected")
        {
            cell.Circle.image = UIImage(named: "circleDeselected")
            cell.state = "deselected"
            CuisineGlobal.SavedCuisine = CuisineGlobal.SavedCuisine.filter{$0 != filterArray[indexPath.row].name}
            for i in CuisineGlobal.SavedCuisine
            {
                print(i)
            }
            CuisineGlobal.removeCuisine.append(filterArray[indexPath.row].name)
            CuisineGlobal.CuisineArray[ind!].saved = "deselected"
        }
        else
        {
            cell.Circle.image = UIImage(named: "circle")
            cell.state = "unpressed"
            CuisineGlobal.removeCuisine = CuisineGlobal.removeCuisine.filter{$0 != filterArray[indexPath.row].name}
            CuisineGlobal.CuisineArray[ind!].saved = "unpressed"
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

protocol filterTabLibraryDelegate {
    func popupDidDisappear()
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

