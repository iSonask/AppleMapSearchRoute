//
//  SearchTableController.swift
//  AnimatedMapDirection
//
//  Created by SHANI SHAH on 20/12/18.
//  Copyright © 2018 SHANI SHAH. All rights reserved.
//

import UIKit
import MapKit

class SearchTableController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate {

    @IBOutlet weak var mytableView: UITableView!
    var matchingItems: [MKMapItem] = []
    var delegate : DataTransferProtocol?
    var mapView: MKMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return matchingItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let selectedItem = matchingItems[indexPath.row].placemark
        

        cell.textLabel?.text = selectedItem.name

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = matchingItems[indexPath.row].placemark
        delegate?.dropPinZoomIn(placemark: selectedItem)
        
        matchingItems.removeAll()
        mytableView.reloadData()
        self.view.isHidden = true
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchController.searchBar.text!
        request.region = mapView!.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.mytableView.reloadData()
        }

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text!
        request.region = mapView!.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.mytableView.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        matchingItems.removeAll()
        mytableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        matchingItems.removeAll()
        mytableView.reloadData()
        return true
    }


}
