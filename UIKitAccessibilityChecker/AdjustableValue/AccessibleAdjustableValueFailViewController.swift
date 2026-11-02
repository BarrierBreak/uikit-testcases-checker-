import UIKit

/// ADJUSTABLE VALUE — Fail tier.
///
/// No adjustable element says where it is set.
///
/// Elements covered (3) — every one is a defect:
///   1. Volume slider — accessibilityValue "" replaces the system value       → BB40278 Fail
///   2. Page control  — accessibilityValue " " replaces "page 2 of 4"        → BB40278 Fail
///   3. Star rating   — custom .adjustable view with no accessibilityValue    → BB40278 Fail
final class AccessibleAdjustableValueFailViewController: NewRuleScreen {

    override var screenTitle: String { "Adjustable Value (Fail)" }

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
        place(slider("Volume", value: "", tag: 0))
        place(pages(value: " ", tag: 1), height: 30)
        place(stars(speaksValue: false, tag: 2))
    }
}
