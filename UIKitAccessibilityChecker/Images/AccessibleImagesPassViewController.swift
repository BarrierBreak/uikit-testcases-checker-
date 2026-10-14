import UIKit

/// IMAGES — Pass tier.
///
/// Every informative picture has a real description, and the decoration is kept out of the
/// accessibility tree. Each described picture reports BB40045 "Check if image has correct
/// textual description" — a Validate row, because only a person looking at the picture can say
/// the words are the right ones. The decoration reports nothing.
///
/// Elements covered (6):
///   1. Star rating     — "Five-star rating"                          → BB40045
///   2. Weather         — "Sunny with a light breeze, 22 degrees"     → BB40045
///   3. Profile photo   — "Profile photo of Alex Morgan"              → BB40045
///   4. Map pin         — "Map pin marking the cafe entrance"         → BB40045
///   5. Sparkles        — decoration, hidden from VoiceOver           → not reported
///   6. Divider         — decoration, hidden from VoiceOver           → not reported
final class AccessibleImagesPassViewController: ImageDemoViewController {

    override var screenTitle: String { "Images (Pass)" }

    override var items: [Item] {
        [
            Item(symbol: "star.fill", alternative: .described("Five-star rating")),
            Item(symbol: "cloud.sun.fill", alternative: .described("Sunny with a light breeze, 22 degrees")),
            Item(symbol: "person.crop.circle", alternative: .described("Profile photo of Alex Morgan")),
            Item(symbol: "mappin.circle", alternative: .described("Map pin marking the cafe entrance")),
            Item(symbol: "sparkles", alternative: .decorative),
            Item(symbol: "line.horizontal.3", alternative: .decorative),
        ]
    }
}
