import UIKit

/// ADJUSTABLE VALUE — Partial tier.
///
/// Some adjustable elements say where they are set and some do not.
///
/// Elements covered (3):
///   1. Brightness slider — value left to the system                        → BB40279 Pass
///   2. Page control      — value left to the system                        → BB40279 Pass
///   3. Star rating       — custom .adjustable view with no accessibilityValue → BB40278 Fail
final class AccessibleAdjustableValuePartialViewController: NewRuleScreen {

    override var screenTitle: String { "Adjustable Value (Partial)" }

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
        place(pages(value: nil, tag: 1), height: 30)
        place(stars(speaksValue: false, tag: 2))
    }
}
