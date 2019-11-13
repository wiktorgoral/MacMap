//
//  MasterViewController.swift
//  weatherapp4
//
//  Created by Wiktor Góral on 05/11/2019.
//  Copyright © 2019 Wiktor Góral. All rights reserved.
//

import UIKit
import CoreLocation


class CustomCell : UITableViewCell{
    
    
    @IBOutlet weak var imagee: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    
}



class MasterViewController: UITableViewController, DataPass {
    
    
    var detailViewController: DetailViewController? = nil
    var cities = ["San Francisco", "London", "Warsaw"]
    var woeids = [Int](repeating: 0, count: 3)
    var weathers = [NSArray](repeating: NSArray(array: [NSDictionary()]), count: 3)
    var images = [UIImage](repeating: UIImage(), count: 3)
    let sema = DispatchSemaphore(value: 1)
    
    
    func pass(data: String) {
        cities.append(data)
        getWoeid(city: cities[cities.count-1]){(value) in
            self.woeids.append(value)
            self.getWeather(woeid: self.woeids[self.woeids.count-1]){(value1) in
                self.weathers.append(value1)
                let wether_abr: NSDictionary = self.weathers[self.weathers.count-1][0] as! NSDictionary
                self.getImage(short: wether_abr.value(forKey: "weather_state_abbr") as! String){(value2) in
                    self.images.append(value2)
                    
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            for i in 0...self.cities.count-1{
                self.getWoeid(city: self.cities[i]){(value) in
                    self.woeids[i]=value
                    self.getWeather(woeid: self.woeids[i]){(value1) in
                        self.weathers[i] = value1
                        let wether_abr: NSDictionary = self.weathers[i][0] as! NSDictionary
                        self.getImage(short: wether_abr.value(forKey: "weather_state_abbr") as! String){(value2) in
                            self.images[i]=value2
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.name = cities[indexPath.row] 
                controller.weathers = weathers[indexPath.row] 
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        if segue.identifier == "addTask"{
            let vc = segue.destination as! AddTaskViewController
            vc.delegate = self
        }
    }
    
    // Mark: func for weather
    
    func getWoeid(city: String, completion: @escaping (_ result: Int) -> () ){
        var w = Int()
        let ss = "https://www.metaweather.com/api/location/search/?query="+city
        let url = URL(string: ss.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        let session = URLSession.shared.dataTask(with: url, completionHandler:  { (data, response, error) -> Void in DispatchQueue.main.async {
            if let data = data {
                if let cities = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)as? NSArray {
                    if let city = cities.firstObject as? NSDictionary{
                        w = (city.value(forKey: "woeid") as? Int)!
                        completion(w)
                    }
                }
            }
            }
        }
        )
        session.resume()
    }
    
    
    func getWeather(woeid: Int, completion: @escaping ( _ result: NSArray)->()){
        var weathers:NSArray = NSArray()
        let url = URL(string: "https://www.metaweather.com/api/location/\(woeid)/")!
        let session = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in DispatchQueue.main.async {
            if let data = data{
                if let all = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)as? NSDictionary {
                    weathers = all.value(forKey: "consolidated_weather") as! NSArray
                    completion(weathers)
                }
            }
            }
        }
        )
        session.resume()
    }
    func getImage(short: String, completion: @escaping ( _ result: UIImage)->()){
        var image = UIImage()
        let url = URL(string: "https://www.metaweather.com/static/img/weather/png/64/\(short).png")!
        let session = URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) -> Void in DispatchQueue.main.async {
            if let data = data{
                image = UIImage(data: data)!
                completion(image)
            }
            }
        }
        )
        session.resume()
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomCell
        cell.name.text = cities[indexPath.row]
        cell.imagee.image = images[indexPath.row]
        cell.detail.text = String(format:"%.0f", (self.weathers[indexPath.row][0] as? NSDictionary)?.value(forKey: "the_temp") as? Double ?? 0)+"℃"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            woeids.remove(at: indexPath.row)
            images.remove(at: indexPath.row)
            weathers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
}

