import UIKit

/// ROLE TRAIT — Partial tier.
///
/// Four native controls; two keep their role and two have had it replaced.
///
/// Elements covered (4):
///   1. Save changes   — UIButton, stock traits                       → BB40275 Pass
///   2. Volume         — UISlider, stock traits                       → BB40275 Pass
///   3. Cancel         — UIButton set to .staticText, no button role  → BB40274 Fail
///   4. Email          — UITextField set to .button                   → BB40274 Fail
final class AccessibleRoleTraitPartialViewController: NewRuleScreen {

    override var screenTitle: String { "Role Trait (Partial)" }

    override func build() {
        let save = UIButton(type: .system).srcLine()
        save.setTitle("Save changes", for: .normal)
        place(save)

        let slider = UISlider().srcLine()
        slider.accessibilityLabel = "Volume"
        place(slider)

        let cancel = UIButton(type: .system).srcLine()
        cancel.setTitle("Cancel", for: .normal)
        cancel.accessibilityTraits = .staticText
        place(cancel)

        let field = UITextField().srcLine()
        field.borderStyle = .roundedRect
        field.placeholder = "Email"
        field.accessibilityLabel = "Email"
        field.accessibilityTraits = .button
        place(field)
    }
}
