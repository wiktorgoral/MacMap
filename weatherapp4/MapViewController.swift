//
//  MapViewController.swift
//  weatherapp4
//
//  Created by Wiktor Góral on 12/11/2019.
//  Copyright © 2019 Wiktor Góral. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    

    var city = String()
    @IBOutlet weak var name: UINavigationItem?
    @IBOutlet weak var mapView: MKMapView?
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name?.title = city
        setMapLocation()

    }
    
    func searchh(name: String, completion: @escaping (_ result: NSMutableArray) -> () ){
        print(name)
        let name = "https://www.metaweather.com/api/location/search/?query=" + name
        let url = URL(string: name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        let session = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in DispatchQueue.main.async {
            if let data = data{
                if let all = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)as? NSArray{
                    completion(all.mutableCopy() as! NSMutableArray)
                    print(all)
                }
            }
            }
        }
        )
        session.resume()
        
    }
    
    private func setMapLocation() {
        searchh(name: self.name!.title!){(value) in
            let dat = value[0] as! NSDictionary
            let lat = Double((dat.value(forKey: "latt_long") as! String).components(separatedBy: ",")[0])
            let lon = Double((dat.value(forKey: "latt_long") as! String).components(separatedBy: ",")[1])
            let latiude = CLLocationDegrees(exactly: lat!)
            let longitude = CLLocationDegrees(exactly: lon!)
            let center = CLLocationCoordinate2D(latitude: latiude!, longitude: longitude!)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.50, longitudeDelta: 0.50))
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latiude!, longitude: longitude!)
            self.mapView!.addAnnotation(annotation)
            self.mapView!.setRegion(region, animated: true)
            
            
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
