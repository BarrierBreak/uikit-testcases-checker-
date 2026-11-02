import UIKit
import MapKit

/// MAP TEXT ALTERNATIVE — Fail tier.
///
/// Neither map tells a VoiceOver user what it shows.
///
/// Elements covered (2) — every one is a defect:
///   1. Store map    — no accessibilityLabel             → BB40140 Fail
///   2. Delivery map — accessibilityLabel of whitespace   → BB40140 Fail
final class AccessibleMapFailViewController: NewRuleScreen {

    override var screenTitle: String { "Map (Fail)" }

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
        place(map(latitude: 19.0760, longitude: 72.8777, label: nil, tag: 0), height: 200)
        place(map(latitude: 18.5204, longitude: 73.8567, label: "   ", tag: 1), height: 200)
    }
}
