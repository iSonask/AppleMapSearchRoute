//
//  AppleMapController.swift
//  AnimatedMapDirection
//
//  Created by SHANI SHAH on 20/12/18.
//  Copyright © 2018 SHANI SHAH. All rights reserved.
//
// https://github.com/ashish0593/Search-Nearby-Places-IOS-Application
import UIKit
import CoreLocation
import MapKit

protocol DataTransferProtocol {
    func dropPinZoomIn(placemark:MKPlacemark)
}


class AppleMapController: UIViewController,MKMapViewDelegate,MKLocalSearchCompleterDelegate,UISearchControllerDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    var camera = MKMapCamera()
    
    lazy var searchCompleter: MKLocalSearchCompleter = {
        let sC = MKLocalSearchCompleter()
        sC.delegate = self
        return sC
    }()
    var selectedPin: MKPlacemark?
    var searchSource: [String]?
    
    
    var controladorDeBusca: UISearchController!
    
    var resultsTableViewController: SearchTableController?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        camera = MKMapCamera(lookingAtCenter: Global.shared.locations, fromEyeCoordinate: Global.shared.locations, eyeAltitude: 400.0)
        mapView.camera = camera
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.showsTraffic = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeLocation), name: NSNotification.Name(rawValue: "handleNewNotification"), object: nil)
    
//        addBottomSheetView()
        resultsTableViewController = storyboard!.instantiateViewController(withIdentifier: "SearchTableController") as? SearchTableController
        resultsTableViewController?.delegate = self
        resultsTableViewController?.mapView = mapView
        configurarControladorDeBusca()
    }
    
    func configurarControladorDeBusca() {
        
        controladorDeBusca = UISearchController(searchResultsController: resultsTableViewController)
        controladorDeBusca.delegate = self
        controladorDeBusca.searchResultsUpdater = resultsTableViewController
        controladorDeBusca.dimsBackgroundDuringPresentation = true
        
        definesPresentationContext = true
        
        controladorDeBusca.loadViewIfNeeded()
        
        //Configura a barra do Controlador de busca
        controladorDeBusca.searchBar.delegate = resultsTableViewController
        controladorDeBusca.hidesNavigationBarDuringPresentation = false
        controladorDeBusca.searchBar.placeholder = "Search place"
        controladorDeBusca.searchBar.sizeToFit()
        controladorDeBusca.searchBar.barTintColor = navigationController?.navigationBar.barTintColor
        controladorDeBusca.searchBar.tintColor = self.view.tintColor
        
        //Adiciona a barra do Controlador de Busca a barra do navegador
        navigationItem.titleView = controladorDeBusca.searchBar
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func addBottomSheetView() {
        let bottomSheetVC = ScrollableBottomSheetViewController()
        bottomSheetVC.delegate = self
        bottomSheetVC.mapView = self.mapView
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }
    
    let destination = CLLocationCoordinate2D(latitude: 18.5204, longitude: 73.8567)
    
    @objc func changeLocation()  {
        camera = MKMapCamera(lookingAtCenter: Global.shared.locations, fromEyeCoordinate: Global.shared.locations, eyeAltitude: 400.0)
//        showRouteOnMap(pickupCoordinate: Global.shared.locations, destinationCoordinate: destination)
        
        mapView.setCamera(camera, animated: true)
    }
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView!.showAnnotations([destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            let route = response.routes[0]
            let overlays = self.mapView.overlays
            self.mapView.removeOverlays(overlays)
            self.mapView!.addOverlay((route.polyline), level: MKOverlayLevel.aboveLabels)
            let rect = route.polyline.boundingMapRect
            self.mapView!.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    //https://github.com/gm6379/MapKitAutocomplete
    //https://stackoverflow.com/questions/33380711/how-to-implement-auto-complete-for-address-using-apple-map-kit
    //https://stackoverflow.com/questions/29319643/how-to-draw-a-route-between-two-locations-using-mapkit-in-swift
    //https://stackoverflow.com/questions/27558912/draw-polyline-using-swift
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.searchSource = completer.results.map { $0.title }
        print(searchSource!)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //handle the error
        print(error.localizedDescription)
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("tapped")
        
        showRouteOnMap(pickupCoordinate: Global.shared.locations, destinationCoordinate: selectedPin!.coordinate)
    }
}
extension AppleMapController: DataTransferProtocol {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name

        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}
