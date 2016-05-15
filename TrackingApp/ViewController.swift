//
//  ViewController.swift
//  TrackingApp
//
//  Created by Mikel Aguirre on 11/5/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    
    private let manejador = CLLocationManager()
    private var distanciaRecorrida :Int = 0
    private var usuarioLocalizado :Bool = false
    var localizacionInicio : CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
        
    }
    
    func centrarMapaPosicionUsuario(){
        if manejador.location != nil{
            mapa.setCenterCoordinate(manejador.location!.coordinate, animated: true)
        }else{
            print("Localización no recibida")
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            manejador.startUpdatingLocation()
            mapa.showsUserLocation = true
        }else{
            manejador.stopUpdatingLocation()
            mapa.showsUserLocation = false
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Si se trata de la primera lectura, centramos la posición del usuario en el mapa
        if !usuarioLocalizado{
            self.centrarMapaPosicionUsuario()
            usuarioLocalizado = true
        }
        
        let ultimaLocalizacion = manejador.location
        
        if localizacionInicio == nil {
            localizacionInicio = ultimaLocalizacion
        }
        
        let distancia = ultimaLocalizacion!.distanceFromLocation(localizacionInicio)
        
        //Si la distancia entre la localización actual y la inicial es mayor o igual a 50m,
        //sumamos distancia total recorrida, creamos el pin y lo pinchamos en el mapa
        //Reiniciamos la referencia a la localización inicial con la última localización para utilizar esta última como nueva referencia
        
        if distancia >= 50{
            distanciaRecorrida += Int(distancia)
            print("50 metros o más")
            let pin = MKPointAnnotation()
            pin.coordinate = ultimaLocalizacion!.coordinate
            pin.title = "Lat:\(ultimaLocalizacion!.coordinate.latitude) - Long:\(ultimaLocalizacion!.coordinate.longitude)"
            pin.subtitle = "\(distanciaRecorrida) metros recorridos"
            mapa.addAnnotation(pin)
            localizacionInicio = ultimaLocalizacion
        }
          
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alerta = UIAlertController(title: "ERROR", message: "Error \(error.code)", preferredStyle: .Alert)
        let accionOK = UIAlertAction (title: "OK", style: .Default, handler: {accion in
            //..
        })
        alerta.addAction(accionOK)
        self.presentViewController(alerta, animated: true, completion: nil)
    }

    @IBAction func seleccionarTipoMapa(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            mapa.mapType = .Standard
        }else if sender.selectedSegmentIndex == 1{
            mapa.mapType = .Satellite
        }else if sender.selectedSegmentIndex == 2{
            mapa.mapType = .Hybrid
        }
    }

    @IBAction func realizarZoomIn() {
        //Preparamos un objeto región para realizar el ZoomIn utilizando como centro la posición actual y un Span de 0.005 grados X e Y
        
        if manejador.location != nil{
            let latDelta:CLLocationDegrees = 0.005
            let lonDelta:CLLocationDegrees = 0.005
        
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        
            let region = MKCoordinateRegion(center: manejador.location!.coordinate, span: span)
        
            mapa.setRegion(region, animated: true)
        }else{
            print("Localización no recibida")
        }
    }
   
}

