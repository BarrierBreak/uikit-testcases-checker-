import UIKit

/// TAB CONTROL — Pass tier.
///
/// Two tab bars, both left in the accessibility tree, so VoiceOver users can switch tabs.
/// Nothing is reported.
///
/// Elements covered (2) — none is a defect:
///   1. Tab bar — Home, Search, Profile      → no row
///   2. Tab bar — Home, Search, Profile      → no row
final class AccessibleTabControlPassViewController: NewRuleScreen {

    override var screenTitle: String { "Tab Control (Pass)" }


    enum Hiding { case none, itself, parent }

    private func tabBar(_ hiding: Hiding, tag: Int) {
        let bar = UITabBar().srcLine()
        bar.tag = tag
        bar.items = [
            UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0),
            UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1),
            UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 2),
        ]
        bar.selectedItem = bar.items?.first
        switch hiding {
        case .none:
            place(bar, height: 49)
        case .itself:
            bar.accessibilityElementsHidden = true
            place(bar, height: 49)
        case .parent:
            let wrapper = UIView()
            wrapper.accessibilityElementsHidden = true
            bar.frame = CGRect(x: 0, y: 0, width: view.bounds.width - 48, height: 49)
            bar.autoresizingMask = [.flexibleWidth]
            wrapper.addSubview(bar)
            place(wrapper, height: 49)
        }
    }

    override func build() {
        tabBar(.none, tag: 0)
        tabBar(.none, tag: 1)
    }
}
