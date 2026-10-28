import UIKit

/// TAB CONTROL — Partial tier.
///
/// One tab bar is reachable and one is hidden.
///
/// Elements covered (2):
///   1. Tab bar — left in the accessibility tree                → no row
///   2. Tab bar — accessibilityElementsHidden = true            → BB40036 Validate
final class AccessibleTabControlPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Tab Control (Partial)" }


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
        tabBar(.itself, tag: 1)
    }
}
