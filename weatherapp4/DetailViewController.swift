//
//  DetailViewController.swift
//  weatherapp4
//
//  Created by Wiktor Góral on 05/11/2019.
//  Copyright © 2019 Wiktor Góral. All rights reserved.
//

import UIKit


class DetailViewController: UIViewController {
    
    
    var curr = 0
    var max = 0
    var name = String()
    var weathers = NSArray()
    var weather = NSDictionary()

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var temperatura: UILabel!
    @IBOutlet weak var wiatr: UILabel!
    @IBOutlet weak var rain: UILabel!
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var prev: UIButton!
    @IBAction func prevAction(_ sender: Any) {
        if self.curr != 0 {
            curr-=1
            self.updateView()
        }
    }
    @IBOutlet weak var nextt: UIButton!
    @IBAction func nextAction(_ sender: Any) {
        if self.curr != self.max{
            curr+=1
            self.updateView()
        }
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
    
    func updateView(){
        if self.curr==0{
            self.prev.isEnabled=false
        }
        else if self.curr==self.max{
            self.nextt.isEnabled=false
        }
        else{
            self.nextt.isEnabled=true
            self.prev.isEnabled=true
        }
        self.weather = self.weathers[self.curr] as! NSDictionary
        self.getImage(short:  self.weather.value(forKey: "weather_state_abbr") as! String){(value2) in
            self.image.image = value2
            self.data.text = "Date \(String(describing: self.weather.value(forKey: "applicable_date") as! String))"
            self.type.text = "Type \(String(describing: self.weather.value(forKey: "weather_state_name") as! String))"
            self.temperatura.text = "Tempreture \(String(format:"%.0f", self.weather.value(forKey: "min_temp") as! Double))℃ - \(String(format:"%.0f", self.weather.value(forKey: "max_temp") as! Double))℃"
            self.wiatr.text = "Wind \(String(self.weather.value(forKey: "wind_direction_compass") as! String)) \(String(format:"%.0f", self.weather.value(forKey: "wind_speed") as! Double)) mph"
            self.rain.text = "Humidity \(String(describing: self.weather.value(forKey: "humidity") as! Int))%"
            self.pressure.text = "Pressure \(String(format:"%.0f", self.weather.value(forKey: "air_pressure") as! Double)) mbar"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = name
        print(name)
        self.max = self.weathers.count - 1
        if self.weathers.firstObject != nil{
            self.updateView()
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapVieww" {
            let vc = segue.destination as! MapViewController
            vc.city = self.name
        }
    }
    
    
    
}

