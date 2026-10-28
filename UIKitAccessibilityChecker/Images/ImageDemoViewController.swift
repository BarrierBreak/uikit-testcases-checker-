import UIKit

/// Shared layout for the three Image screens. Each item is a picture and what the app told
/// VoiceOver about it: a description, nothing, or that the picture is decoration.
class ImageDemoViewController: UIViewController {

    enum Alternative {
        /// Exposed to VoiceOver with this description.
        case described(String)
        /// Exposed to VoiceOver with no description at all.
        case none
        /// Kept out of the accessibility tree: decoration.
        case decorative
    }

    struct Item {
        let symbol: String
        let alternative: Alternative
        var width: CGFloat = 56
    }

    var screenTitle: String { "" }
    var items: [Item] { [] }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = .systemBackground
        var y: CGFloat = 24
        for (index, item) in items.enumerated() {
            let imageView = UIImageView(image: UIImage(systemName: item.symbol)).srcLine()
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .systemBlue
            // The pictures are built in one loop, so they share a source line; the tag is what
            // keeps one picture's finding from being merged into another's.
            imageView.tag = index
            switch item.alternative {
            case .described(let text):
                imageView.isAccessibilityElement = true
                imageView.accessibilityLabel = text
            case .none:
                imageView.isAccessibilityElement = true
                // A real (blank) picture rather than no image: a nil image would also draw
                // the image-role rule's "no image content" Fail, which is not this screen's point.
                imageView.image = UIGraphicsImageRenderer(size: CGSize(width: item.width, height: 56)).image { _ in }
                imageView.backgroundColor = .systemGray4
                imageView.accessibilityLabel = nil
            case .decorative:
                imageView.isAccessibilityElement = false
            }
            imageView.frame = CGRect(x: 24, y: y, width: item.width, height: 56)
            view.addSubview(imageView)
            y += 72
        }
    }
}
