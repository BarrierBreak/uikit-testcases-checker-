import UIKit

/// Shared layout for the three Link screens. Each item is a sentence with a link in the
/// middle of it, and how that link is styled: underlined, heavier, or neither (colour only).
class LinkDemoViewController: UIViewController {

    enum Style {
        case underlined
        case bold
        case colourOnly
    }

    struct Sentence {
        let before: String
        let link: String
        let after: String
        let style: Style
    }

    var screenTitle: String { "" }
    var sentences: [Sentence] { [] }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        view.backgroundColor = UIColor(hex: "#FFFFFF")
        var y: CGFloat = 24
        for (index, sentence) in sentences.enumerated() {
            let label = UILabel().srcLine()
            // Built in one loop, so the labels share a source line; the tag keeps findings apart.
            label.tag = index
            label.numberOfLines = 0
            label.attributedText = attributedText(for: sentence)
            label.frame = CGRect(x: 24, y: y, width: view.bounds.width - 48, height: 60)
            label.autoresizingMask = [.flexibleWidth]
            view.addSubview(label)
            y += 84
        }
    }

    private func attributedText(for sentence: Sentence) -> NSAttributedString {
        let body = UIFont.systemFont(ofSize: 17)
        let bodyColor = UIColor(hex: "#1A1A1A")
        let linkColor = UIColor(hex: "#0B5FA5")
        let result = NSMutableAttributedString()
        result.append(NSAttributedString(string: sentence.before, attributes: [.font: body, .foregroundColor: bodyColor]))

        var attributes: [NSAttributedString.Key: Any] = [
            .font: body,
            .foregroundColor: linkColor,
            .link: URL(string: "https://example.com/terms")!,
        ]
        switch sentence.style {
        case .underlined:
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        case .bold:
            attributes[.font] = UIFont.boldSystemFont(ofSize: 17)
        case .colourOnly:
            break
        }
        result.append(NSAttributedString(string: sentence.link, attributes: attributes))
        result.append(NSAttributedString(string: sentence.after, attributes: [.font: body, .foregroundColor: bodyColor]))
        return result
    }
}
