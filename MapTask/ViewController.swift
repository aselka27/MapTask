//
//  ViewController.swift
//  MapTask
//
//  Created by саргашкаева on 27.02.2023.
//

import UIKit
import MapKit
import SnapKit
import CoreLocation

class ViewController: UIViewController {
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        return mapView
    }()

    let addAdressButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add adress", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 12
        return button
    }()
    
    let routeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Route", for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 12
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 12
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        return button
    }()
    
    var annotationArray = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraints()
        addAdressButton.addTarget(self, action: #selector(addAddressButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addAddressButtonTapped() {
        alertAddAdress(title: "Add", placeholder: "Enter address") { [weak self] text in
            self?.setupPlacemark(addressPlace: text)
        }
    }
    @objc private func routeButtonTapped() {
        for index in 0...annotationArray.count-1 {
            createDirectionRequest(startCoordinate: annotationArray[index].coordinate, destinationCoordinate: annotationArray[index+1].coordinate)
        }
        mapView.showAnnotations(annotationArray, animated: true)
    }
    @objc private func resetButtonTapped() {
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        annotationArray = [MKPointAnnotation]()
        resetButton.isHidden = true
        routeButton.isHidden = true 
    }
    
    private func setupPlacemark(addressPlace: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressPlace) { [self] placemarks, error in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = addressPlace
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            annotationArray.append(annotation)
            
            if annotationArray.count > 2 {
                routeButton.isHidden = false
                resetButton.isHidden = false
            }
            mapView.showAnnotations(annotationArray, animated: true)
            
        }
    }
    
    private func createDirectionRequest(startCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        let startLocation = MKPlacemark(coordinate: startCoordinate)
        let destinationLocation = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { response, error in
            if let error = error {
                print(error)
            }
            guard let response = response else { return }
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .red
        return render
    }
}


extension ViewController {
    
    func setConstraints() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        mapView.addSubview(addAdressButton)
        mapView.addSubview(resetButton)
        mapView.addSubview(routeButton)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addAdressButton.snp.makeConstraints { make in
            make.top.equalTo(mapView.snp.top).offset(50)
            make.trailing.equalTo(mapView.snp.trailing).inset(20)
            make.height.equalTo(50)
            make.width.equalTo(100)
        }
        routeButton.snp.makeConstraints { make in
            make.leading.equalTo(mapView.snp.leading).offset(20)
            make.bottom.equalTo(mapView.snp.bottom).inset(30)
            make.height.equalTo(50)
            make.width.equalTo(90)
        }
        routeButton.snp.makeConstraints { make in
            make.trailing.equalTo(mapView.snp.trailing).inset(-20)
            make.bottom.equalTo(mapView.snp.bottom).inset(30)
            make.height.equalTo(50)
            make.width.equalTo(90)
        }
    }
}
