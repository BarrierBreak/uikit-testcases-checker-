import UIKit

/// TAB CONTROL — Fail tier.
///
/// Two tab bars taken out of the accessibility tree, one directly and one through its parent,
/// so a screen-reader user cannot switch tabs. Each is reported as BB40036 "Check if tab
/// control needs to be hidden for screen reader user" for a person to confirm.
///
/// Elements covered (2) — both are flagged:
///   1. Tab bar — accessibilityElementsHidden = true            → BB40036 Validate
///   2. Tab bar — inside a view that hides its subtree          → BB40036 Validate
final class AccessibleTabControlFailViewController: NewRuleScreen {

    override var screenTitle: String { "Tab Control (Fail)" }


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
        tabBar(.itself, tag: 0)
        tabBar(.parent, tag: 1)
    }
}
