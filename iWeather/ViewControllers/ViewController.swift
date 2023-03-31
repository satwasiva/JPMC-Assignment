//
//  ViewController.swift
//  iWeather
//
//  Created by Vamsi Prakhya
//

import UIKit
import MapKit

class ViewController: UIViewController {

    let lastQueriedKey = "lastQueried"
    
    @IBOutlet weak var querySearchBar: UISearchBar!
    @IBOutlet weak var weatherMapView: MKMapView!
    
    @IBOutlet weak var locationNameLbl: UILabel!
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var curTemperatureLbl: UILabel!
    @IBOutlet weak var currentCondLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    @IBOutlet weak var feelLikeLbl: UILabel!
    @IBOutlet weak var pressureLbl: UILabel!
    @IBOutlet weak var humidityLbl: UILabel!
    
    @IBOutlet weak var windSpeedLbl: UILabel!
    @IBOutlet weak var visibilityLbl: UILabel!
    @IBOutlet weak var cloudinessLbl: UILabel!
    
    @IBOutlet weak var sunriseLbl: UILabel!
    @IBOutlet weak var sunsetLbl: UILabel!
    
    var mapLocationCenter : CLLocation? = nil
    var weatherAnnotation : ConditionAnnotation = ConditionAnnotation(title: nil, condition: nil, coordinate: CLLocationCoordinate2D(), image: nil)
    
    var spinner = UIActivityIndicatorView(style: .medium)
    var lastQueried : String? = nil
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
      var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
      return recognizer
    }()
    
    var searchQueryViewModel : SearchCurrentWeatherInfoViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherMapView.register(ConditionAnnotationView.self, forAnnotationViewWithReuseIdentifier:MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        searchQueryViewModel = SearchCurrentWeatherInfoViewModel(weatherQueryController: WeatherDependencyContainer.shared.weatherQueryController)
        
        // Associating the view Model's properties with the lables' text properties to get updates automatically on updating.
        
        searchQueryViewModel?.weatherImage.associate { [weak self] weatherImage in
            DispatchQueue.main.async {
                self?.conditionImageView.image = weatherImage
                self?.weatherAnnotation.image = weatherImage
            }
        }
        searchQueryViewModel?.mapLocationCenter.associate { mapLocationCenter in
            DispatchQueue.main.async {
                self.mapLocationCenter = mapLocationCenter
                self.weatherMapView.centerToLocation((self.mapLocationCenter)!)
                self.weatherAnnotation = ConditionAnnotation(title: nil, condition: nil, coordinate: mapLocationCenter.coordinate, image: nil)
                
                self.weatherMapView.addAnnotation(self.weatherAnnotation)
            }
        }
        searchQueryViewModel?.locationName.associate { [weak self] locationName in
            DispatchQueue.main.async {
                self?.locationNameLbl.text = locationName
                self?.weatherAnnotation.title = locationName
            }
        }
        searchQueryViewModel?.currentTemperature.associate { [weak self] currentTemperature in
            DispatchQueue.main.async {
                self?.curTemperatureLbl.text = currentTemperature
            }
        }
        searchQueryViewModel?.currentCondition.associate { [weak self] currentCondition in
            DispatchQueue.main.async {
                self?.currentCondLbl.text = currentCondition
            }
        }
        searchQueryViewModel?.conditionDescription.associate { [weak self] conditionDescription in
            DispatchQueue.main.async {
                self?.descriptionLbl.text = conditionDescription
                self?.weatherAnnotation.condition = conditionDescription
            }
        }
        searchQueryViewModel?.feelsLikeInfo.associate { [weak self] feelsLikeInfo in
            DispatchQueue.main.async {
                self?.feelLikeLbl.text = feelsLikeInfo
            }
        }
        searchQueryViewModel?.pressureInfo.associate { [weak self] pressureInfo in
            DispatchQueue.main.async {
                self?.pressureLbl.text = pressureInfo
            }
        }
        searchQueryViewModel?.humidityInfo.associate { [weak self] humidityInfo in
            DispatchQueue.main.async {
                self?.humidityLbl.text = humidityInfo
            }
        }
        searchQueryViewModel?.windSpeedInfo.associate { [weak self] windSpeedInfo in
            DispatchQueue.main.async {
                self?.windSpeedLbl.text = windSpeedInfo
            }
        }
        searchQueryViewModel?.visibilityInfo.associate { [weak self] visibilityInfo in
            DispatchQueue.main.async {
                self?.visibilityLbl.text = visibilityInfo
            }
        }
        searchQueryViewModel?.cloudinessInfo.associate { [weak self] cloudinessInfo in
            DispatchQueue.main.async {
                self?.cloudinessLbl.text = cloudinessInfo
            }
        }
        searchQueryViewModel?.sunRiseInfo.associate { [weak self] sunRiseInfo in
            DispatchQueue.main.async {
                self?.sunriseLbl.text = sunRiseInfo
            }
        }
        searchQueryViewModel?.sunSetInfo.associate { [weak self] sunSetInfo in
            DispatchQueue.main.async {
                self?.sunsetLbl.text = sunSetInfo
            }
        }
        
        if let curLocation = weatherMapView.userLocation.location {
            queryWeatherInfoAt(location: curLocation)
        } else {
            let defaults = UserDefaults.standard
            lastQueried = defaults.string(forKey:lastQueriedKey)
            if lastQueried != nil {
                querySearchBar.text = lastQueried
                self.searchBarSearchButtonClicked(querySearchBar)
            }
        }
    }
    
    func queryWeatherInfoAt( location : CLLocation ) {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        self.view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        searchQueryViewModel?.searchCityInfo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) {
            locationsData in
            
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.spinner.removeFromSuperview()
                
                let defaults = UserDefaults.standard
                defaults.set(locationsData![0].name + "," + locationsData![0].state, forKey:self.lastQueriedKey)
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {
    
    @objc func dismissKeyboard() {
        querySearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        if !searchBar.text!.isEmpty {
            let searchText = searchBar.text!
            
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()
            self.view.addSubview(spinner)
            
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            
            searchQueryViewModel?.searchCityInfo(searchStr:searchText) {
                locationsData in
                
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.spinner.removeFromSuperview()
                }
                
                if locationsData == nil {
                    let alert = UIAlertController(
                        title: "No city found!!",
                        message: "Please check the city name and/or state name and try again",
                        preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(
                        title: "OK",
                        style: UIAlertAction.Style.default,
                        handler: {(_: UIAlertAction!) in
                        }))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                } else if (locationsData!.count > 1) {
                    let alert = UIAlertController(
                        title: "Multiple cities",
                        message: "Please select a city",
                        preferredStyle: .actionSheet)
                    for locData in locationsData! {
                        alert.addAction(UIAlertAction(
                            title: locData.name + " " + locData.state,
                            style: .default,
                            handler: { (_) in
                                searchBar.text = locData.name + "," + locData.state
                                self.searchBarSearchButtonClicked(searchBar)
                            }))
                    }
                    DispatchQueue.main.async {
                        self.present(alert, animated: true)
                    }
                } else {
                    let defaults = UserDefaults.standard
                    defaults.set(searchText, forKey:self.lastQueriedKey)
                }
            }
        }
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
}

private extension MKMapView {
  
    func centerToLocation( _ location: CLLocation, regionRadius: CLLocationDistance = 50000 ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
