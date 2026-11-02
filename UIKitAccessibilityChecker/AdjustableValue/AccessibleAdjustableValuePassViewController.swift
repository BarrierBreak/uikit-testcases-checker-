import UIKit

/// ADJUSTABLE VALUE — Pass tier.
///
/// Every adjustable element says where it is set.
///
/// Elements covered (4) — none is a defect:
///   1. Brightness slider — value left to the system ("40%")                 → BB40279 Pass
///   2. Volume slider     — accessibilityValue "40 percent"                  → BB40279 Pass
///   3. Page control      — value left to the system ("page 2 of 4")         → BB40279 Pass
///   4. Star rating       — custom .adjustable view, value "3 of 5 stars"    → BB40279 Pass
final class AccessibleAdjustableValuePassViewController: NewRuleScreen {

    override var screenTitle: String { "Adjustable Value (Pass)" }

    private func slider(_ name: String, value: String?, tag: Int) -> UISlider {
        let slider = UISlider().srcLine()
        slider.tag = tag
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 40
        slider.accessibilityLabel = name
        if let value { slider.accessibilityValue = value }
        return slider
    }

    private func pages(value: String?, tag: Int) -> UIPageControl {
        let pages = UIPageControl().srcLine()
        pages.tag = tag
        pages.numberOfPages = 4
        pages.currentPage = 1
        pages.pageIndicatorTintColor = .systemGray
        pages.currentPageIndicatorTintColor = .label
        pages.accessibilityLabel = "Onboarding page"
        if let value { pages.accessibilityValue = value }
        return pages
    }

    private func stars(speaksValue: Bool, tag: Int) -> AdjustableRatingView {
        let stars = AdjustableRatingView(speaksValue: speaksValue).srcLine()
        stars.tag = tag
        return stars
    }

    override func build() {
        place(slider("Brightness", value: nil, tag: 0))
        place(slider("Volume", value: "40 percent", tag: 1))
        place(pages(value: nil, tag: 2), height: 30)
        place(stars(speaksValue: true, tag: 3))
    }
}
