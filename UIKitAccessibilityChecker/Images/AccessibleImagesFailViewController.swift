import UIKit

/// IMAGES — Fail tier.
///
/// Every picture is exposed to VoiceOver with a "description" that describes nothing. Each
/// reports BB40126 "Non-descriptive textual description provided for image".
///
/// Elements covered (5) — every one fails:
///   1. "image"              — a generic term
///   2. "photo.png"          — a file name
///   3. "IMG_0423"           — an asset name
///   4. "20240915"           — only digits
///   5. "hero_banner"        — an identifier
final class AccessibleImagesFailViewController: ImageDemoViewController {

    override var screenTitle: String { "Images (Fail)" }

    override var items: [Item] {
        [
            Item(symbol: "photo", alternative: .described("image")),
            Item(symbol: "photo.fill", alternative: .described("photo.png")),
            Item(symbol: "camera.fill", alternative: .described("IMG_0423")),
            Item(symbol: "calendar", alternative: .described("20240915")),
            Item(symbol: "rectangle.fill", alternative: .described("hero_banner")),
        ]
    }
}
