//
//  ConditionAnnotation.swift
//  iWeather
//
//  Created by Vamsi Prakhya
//

import Foundation
import MapKit

class ConditionAnnotation : NSObject, MKAnnotation {
    var title : String?
    var condition : String?
    var coordinate : CLLocationCoordinate2D
    var image : UIImage?

    init( title : String?, condition : String?, coordinate : CLLocationCoordinate2D, image : UIImage? ) {
        self.title = title
        self.condition = condition
        self.image = image
        self.coordinate = coordinate
        
        super.init()
    }

    var subtitle: String? {
        return condition
    }
}

class ConditionAnnotationView: MKAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      guard let conditionAnnotation = newValue as? ConditionAnnotation else {
        return
      }

      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
      rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

      image = conditionAnnotation.image
    }
  }
}
