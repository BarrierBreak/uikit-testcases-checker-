import UIKit
import MapKit

/// MAP TEXT ALTERNATIVE — Pass tier.
///
/// Both maps say what they show.
///
/// Elements covered (2) — none is a defect:
///   1. Store map    — accessibilityLabel "Map of store locations in Mumbai"  → BB40141 Pass
///   2. Delivery map — accessibilityLabel "Delivery area for Pune"            → BB40141 Pass
final class AccessibleMapPassViewController: NewRuleScreen {

    override var screenTitle: String { "Map (Pass)" }

    private func map(latitude: Double, longitude: Double, label: String?, tag: Int) -> MKMapView {
        let map = MKMapView().srcLine()
        map.tag = tag
        map.setRegion(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)), animated: false)
        map.accessibilityLabel = label
        return map
    }

    override func build() {
        place(map(latitude: 19.0760, longitude: 72.8777, label: "Map of store locations in Mumbai", tag: 0), height: 200)
        place(map(latitude: 18.5204, longitude: 73.8567, label: "Delivery area for Pune", tag: 1), height: 200)
    }
}
