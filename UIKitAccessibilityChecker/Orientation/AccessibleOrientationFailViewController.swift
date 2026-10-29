import UIKit

/// ORIENTATION — Fail tier.
///
/// The screen holds the user to portrait: it will not turn into landscape. It reports BB40056
/// "Screen is locked in orientation".
///
/// Elements covered (1):
///   1. The screen   — portrait only              → BB40056 Fail
final class AccessibleOrientationFailViewController: OrientationDemoViewController {

    override var screenTitle: String { "Orientation (Fail)" }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
}
