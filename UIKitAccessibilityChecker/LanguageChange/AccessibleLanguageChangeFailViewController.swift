import UIKit

/// LANGUAGE CHANGE — Fail tier.
///
/// Elements covered (2) — every one is a defect:
///   1. English sentence tagged "fr" (wrong tag)                          → BB40107 Fail
///   2. English and French sentence in one label, nothing tagged          → BB40107 Fail
//final class AccessibleLanguageChangeFailViewController: NewRuleScreen {
//
//    override var screenTitle: String { "Language Change (Fail)" }
//
//    private static let english = "Thank you for visiting our shop today, we are open every day of the week."
//    private static let french = "Merci beaucoup pour votre visite aujourd'hui, nous sommes ouverts tous les jours de la semaine."
//
//    /// A multi-line label showing `text`, with the speech language of each run given by `runs`
//    /// (a nil language leaves the run untagged).
//    private func label(_ runs: [(String, String?)], tag: Int) {
//        let text = NSMutableAttributedString()
//        for (index, run) in runs.enumerated() {
//            var attributes: [NSAttributedString.Key: Any] = [:]
//            if let language = run.1 { attributes[.accessibilitySpeechLanguage] = language }
//            text.append(NSAttributedString(string: (index > 0 ? " " : "") + run.0, attributes: attributes))
//        }
//        let label = UILabel().srcLine()
//        label.tag = tag
//        label.numberOfLines = 0
//        label.attributedText = text
//        place(label, height: 90, gap: 24)
//    }
//
//    override func build() {
//        label([(Self.english, "fr")], tag: 0)
//        label([(Self.english, nil), (Self.french, nil)], tag: 1)
//    }
//}


//

//  AccessibleLanguageMissingFailViewController.swift

//

//  WCAG 3.1.2 Language of Parts (Level AA)

//  Issue: Missing language attribute on content in a different language

//  Rule ID: BB40109 — Language of content does not match app language.
//  Scan result (language family): 1 × BB40109 Fail, for the French quote. Change the
//  quote to English and the row goes away; set the app/device language to French and the
//  English elements are reported instead — the verdict is the content vs the app language.

//

//  The app and this screen are English. One passage — a French quote — is in a

//  different language, but it has no `accessibilityLanguage = "fr"` (the iOS

//  equivalent of a missing lang attribute). VoiceOver reads the French quote

//  with the English voice and mispronounces it.

//

//  Element covered (1) — fails:

//    1. French quote "La vie est belle quand on la partage." inside an English

//       review card — accessibilityLanguage is missing (nil).

//

//  Everything else on the screen is English and correctly needs no override.

//

//  How to test:

//    1. Keep the app's development language as English.

//    2. Set the device language to English.

//    3. Turn OFF VoiceOver › Speech › Detect Languages, otherwise VoiceOver may

//       guess French and hide the failure.

//    4. Swipe to the quote.

//       Expected (fail): the French quote is read in the English voice with

//       English pronunciation. Inspection shows accessibilityLanguage = nil.

//
 
import UIKit
 
final class AccessibleLanguageChangeFailViewController: NewRuleScreen {

    private let statusLabel = LanguageMissingFailLabel.make("", style: .footnote, color: .secondaryLabel)
 
    override func viewDidLoad() {

        super.viewDidLoad()

        title = "Language of Parts (Fail)"

        view.backgroundColor = .systemBackground

        setupLayout()

    }
 
    private func setupLayout() {

        let heading = LanguageMissingFailLabel.make("Customer Review", style: .title2)

        heading.accessibilityTraits = .header
 
        let intro = LanguageMissingFailLabel.make(

            "Amélie from Lyon left this note after her stay:"

        )
 
        // FAIL: French text with no language defined.

        // Fix would be: quote.accessibilityLanguage = "fr"

        let quote = LanguageMissingFailLabel.make(

            "« La vie est belle quand on la partage. »",

            style: .headline

        )

        quote.accessibilityLanguage = nil   // [LANG] intentionally missing
 
        let rating = LanguageMissingFailLabel.make("Rating: 5 out of 5", style: .subheadline,

                                                   color: .secondaryLabel)
 
        var config = UIButton.Configuration.filled()

        config.title = "Mark as helpful"

        let helpfulButton = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in

            guard let self else { return }

            self.statusLabel.text = "Thanks for your feedback."

            UIAccessibility.post(notification: .announcement, argument: "Thanks for your feedback.")

        })
 
        let card = UIStackView(arrangedSubviews: [heading, intro, quote, rating, helpfulButton, statusLabel])

        card.axis = .vertical

        card.spacing = 16

        card.isLayoutMarginsRelativeArrangement = true

        card.directionalLayoutMargins = .init(top: 16, leading: 16, bottom: 16, trailing: 16)

        card.backgroundColor = .secondarySystemBackground

        card.layer.cornerRadius = 12

        card.translatesAutoresizingMaskIntoConstraints = false
 
        let scrollView = UIScrollView()

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(card)

        view.addSubview(scrollView)
 
        NSLayoutConstraint.activate([

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),

            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
 
            card.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),

            card.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),

            card.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),

            card.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20)

        ])

    }

}
 
// MARK: - Helper (unique name so it doesn't collide with other test files)
 
private enum LanguageMissingFailLabel {

    static func make(_ text: String,

                     style: UIFont.TextStyle = .body,

                     color: UIColor = .label) -> UILabel {

        let label = UILabel()

        label.text = text

        label.font = .preferredFont(forTextStyle: style)

        label.adjustsFontForContentSizeCategory = true

        label.textColor = color

        label.numberOfLines = 0

        return label

    }

}
 
