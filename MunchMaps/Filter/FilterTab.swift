//
//  FilterTab.swift
//  MunchMaps
//
//  Created by Varun Narayanswamy on 4/9/19.
//  Copyright © 2019 Varun Narayanswamy LPC. All rights reserved.
//

import UIKit

class FilterTab: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    public var delegate: FilterTabDelegate?
    @IBOutlet weak var Searchbar: UISearchBar!
    @IBOutlet weak var CuisineTable: UITableView!
    struct cuisine {
        var name: String
        var saved: String
        
        init(name: String, saved: String) {
            self.name = name
            self.saved = saved
        }
    }
    var filterArray = [cuisine]()
    struct CuisineGlobal
    {
        static var SavedCuisine = [String]()
        static var removeCuisine = [String]()
        static var CuisineArray = [cuisine(name: "American", saved: "unpressed"), cuisine(name: "Asian", saved: "unpressed"), cuisine(name: "Burger", saved: "unpressed"), cuisine(name: "Bagels", saved: "unpressed"), cuisine(name: "Bakery", saved: "unpressed"),cuisine(name: "Bar Food", saved: "unpressed"), cuisine(name: "Burger", saved: "unpressed"), cuisine(name: "Cafe", saved: "unpressed"), cuisine(name: "Chinese", saved: "unpressed"), cuisine(name: "Deli", saved: "unpressed"),cuisine(name: "Fast Food", saved: "unpressed"), cuisine(name: "French", saved: "unpressed"), cuisine(name: "Frozen Yogurt", saved: "unpressed"), cuisine(name: "Greek", saved: "unpressed"), cuisine(name: "Healthy Food", saved: "unpressed"), cuisine(name: "Ice Cream", saved: "unpressed"), cuisine(name: "Indian", saved: "unpressed"), cuisine(name: "Italian", saved: "unpressed"), cuisine(name: "Japanese", saved: "unpressed"), cuisine(name: "Korean", saved: "unpressed"), cuisine(name: "Mediterranean", saved: "unpressed"), cuisine(name: "Mexican", saved: "unpressed"), cuisine(name: "Nepalese", saved: "unpressed"), cuisine(name: "Pizza", saved: "unpressed"), cuisine(name: "Salad", saved: "unpressed"), cuisine(name: "Sandwich", saved: "unpressed"), cuisine(name: "Spanish", saved: "unpressed"), cuisine(name: "Steak", saved: "unpressed"), cuisine(name: "Sushi", saved: "unpressed"), cuisine(name: "Taco", saved: "unpressed"), cuisine(name: "Tapas", saved: "unpressed"), cuisine(name: "Thai", saved: "unpressed"), cuisine(name: "Vegetarian", saved: "unpressed")]
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
        Searchbar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            filterArray = CuisineGlobal.CuisineArray
            CuisineTable.reloadData()
            print("empty")
            return
        }
        
        /*filterArray = CuisineArray.filter({Restaurant->Bool in
            Restaurant.name.contains(searchText)})*/
        print("typing")
        filterArray = CuisineGlobal.CuisineArray.filter{$0.name.contains(searchText)}
        CuisineTable.reloadData()
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
        let cell = self.CuisineTable.cellForRow(at: indexPath) as! FilterCellTableViewCell
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

protocol FilterTabDelegate {
    func popupDidDisappear()
}


