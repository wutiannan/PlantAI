//
//  MapManager.swift
//  PlantAI
//
//  Created by nanci on 2025/9/2.
//


import SwiftUI
import MapKit
import CoreLocation
import Combine

class MapManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentCoordinate: CLLocationCoordinate2D?
    @Published var route: MKRoute?
    
    @Published var totalDistanceText: String = ""
    @Published var remainingDistanceText: String = ""
    
    private let locationManager = CLLocationManager()
    @Published var useMockLocation = false
    
    private let mockLocation = CLLocationCoordinate2D(latitude: 30.67, longitude: 104.06)
    let destinationCoordinate: CLLocationCoordinate2D
    
    override init() {
        destinationCoordinate = CLLocationCoordinate2D(latitude: 30.66, longitude: 104.0615)
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func startUpdating() {
        if useMockLocation {
            currentCoordinate = mockLocation
            updateRoute()
        } else {
            locationManager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    func setUseMock(_ mock: Bool) {
        useMockLocation = mock
        if mock {
            locationManager.stopUpdatingLocation()
            currentCoordinate = mockLocation
            updateRoute()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    /// 计算路线
    func updateRoute() {
        guard let source = currentCoordinate else { return }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            if let route = response?.routes.first {
                DispatchQueue.main.async {
                    self.route = route
                    let km = route.distance / 1000
                    self.totalDistanceText = String(format: "全程 %.2f km", km)
                    self.updateRemainingDistance()
                }
            }
        }
    }
    
    /// 更新剩余距离
    func updateRemainingDistance() {
        guard let current = currentCoordinate else { return }
        let currentLocation = CLLocation(latitude: current.latitude, longitude: current.longitude)
        let destLocation = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
        let distance = currentLocation.distance(from: destLocation) / 1000
        remainingDistanceText = String(format: "剩余 %.2f km", distance)
        
        // 每次位置更新后刷新路线
        updateRoute()
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.currentCoordinate = location.coordinate
            self.updateRemainingDistance()
        }
    }
}

