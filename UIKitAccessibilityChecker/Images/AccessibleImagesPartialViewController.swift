import UIKit

/// IMAGES — Partial tier.
///
/// A mix: some pictures are described well, some are exposed with no description, and one
/// has a description that is not one.
///
/// Elements covered (5):
///   1. Star rating     — "Five-star rating"                    → BB40045 Validate
///   2. Profile photo   — "Profile photo of Alex Morgan"        → BB40045 Validate
///   3. Placeholder     — exposed, no description               → BB40044 Validate
///   4. Banner          — exposed, no description (a wider picture, so it
///                        reads as its own row)                 → BB40044 Validate
///   5. Header image    — "image"                               → BB40126 Fail
final class AccessibleImagesPartialViewController: ImageDemoViewController {

    override var screenTitle: String { "Images (Partial)" }

    override var items: [Item] {
        [
            Item(symbol: "star.fill", alternative: .described("Five-star rating")),
            Item(symbol: "person.crop.circle", alternative: .described("Profile photo of Alex Morgan")),
            Item(symbol: "photo", alternative: .none),
            Item(symbol: "rectangle.fill", alternative: .none, width: 160),
            Item(symbol: "photo.fill", alternative: .described("image")),
        ]
    }
}
