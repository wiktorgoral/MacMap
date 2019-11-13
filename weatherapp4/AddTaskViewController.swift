//
//  AddTaskViewController.swift
//  weatherapp4
//
//  Created by Wiktor Góral on 05/11/2019.
//  Copyright © 2019 Wiktor Góral. All rights reserved.
//

import UIKit
import CoreLocation

protocol DataPass : NSObjectProtocol {
    func pass(data: String)
}

class AddTaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    private let locationManager = LocationManager()
    var cities = NSMutableArray()
    var delegate : DataPass?
    var current = String()
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var searchName: UITextField!
    @IBAction func searchCity(_ sender: Any) {
        print("ddddddddddddd")
        self.searchh(name: searchName.text!){(value) in
            self.cities = value
            if self.searchName.placeholder != nil{
               
                self.searchh(name: self.current){(value1) in
                    self.cities.addObjects(from: value1 as! [Any])
                    print(self.cities)
                }
                
            }
            else{
                self.getNames(){(value1) in
                    self.cities.addObjects(from: value1 as! [Any])
                    print(self.cities)
                }
            }
        }
    }
    
    func getNames(completion: @escaping ( _ result: NSMutableArray) -> () ){
        var w = [String]()
        let url = URL(string: "https://www.metaweather.com/api/location/search/?lattlong=\(String(describing: self.locationManager.exposedLocation?.coordinate.latitude)),\(String(describing: self.locationManager.exposedLocation?.coordinate.longitude))")!
            let session = URLSession.shared.dataTask(with: url, completionHandler:  { (data, response, error) -> Void in DispatchQueue.main.async {
                if let data = data {
                    if let citiess = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)as? NSArray {
                        for i in 0...citiess.count-1{
                            let city = citiess[i] as! NSDictionary
                            w.append(city.value(forKey: "title") as! String)
                        }
                        completion(w as! NSMutableArray)
                }
                }
            }
            }
            )
            session.resume()
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    func searchh(name: String, completion: @escaping (_ result: NSMutableArray) -> () ){
        let name = "https://www.metaweather.com/api/location/search/?query=" + name
        let url = URL(string: name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        let session = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in DispatchQueue.main.async {
            if let data = data{
                if let all = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)as? NSArray{
                    completion(all.mutableCopy() as! NSMutableArray)
                    self.table.reloadData()
                }
            }
            }
        }
        )
        session.resume()
        
    }
    override func viewDidLoad() {
        self.table.delegate = self
        self.table.dataSource = self
        super.viewDidLoad()
        
        guard let exposedLocation = self.locationManager.exposedLocation else {
            print("*** Error in \(#function): exposedLocation is nil")
            return
        }
        
        self.locationManager.getPlace(for: exposedLocation) { placemark in
            guard let placemark = placemark else { return }
            
            self.searchName.placeholder = "You are in " + placemark.locality! + ", " + placemark.country!
            self.current = placemark.locality!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indexPath = table.indexPathForSelectedRow {
            let cell = table.cellForRow(at: indexPath) as! UITableViewCell
            self.delegate!.pass(data: cell.textLabel!.text!)
        }
        dismiss(animated: false, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let city = cities[indexPath.row] as! NSDictionary
        cell.textLabel?.text = city.value(forKey: "title") as? String
        return cell
    }
}
