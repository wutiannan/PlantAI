//
//  MapNavigationView.swift
//  PlantAI
//
//  Created by nanci on 2025/9/2.
//


import SwiftUI
import MapKit

struct MapNavigationView: UIViewRepresentable {
    @ObservedObject var mapManager: MapManager
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
        
        guard let source = mapManager.currentCoordinate else { return }
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.coordinate = source
        sourceAnnotation.title = "当前位置"
        uiView.addAnnotation(sourceAnnotation)
        
        let destAnnotation = MKPointAnnotation()
        destAnnotation.coordinate = mapManager.destinationCoordinate
        destAnnotation.title = "目的地"
        uiView.addAnnotation(destAnnotation)
        
        if let route = mapManager.route {
            uiView.addOverlay(route.polyline)
            uiView.setRegion(MKCoordinateRegion(route.polyline.boundingMapRect), animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapNavigationView
        init(_ parent: MapNavigationView) { self.parent = parent }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .systemBlue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
