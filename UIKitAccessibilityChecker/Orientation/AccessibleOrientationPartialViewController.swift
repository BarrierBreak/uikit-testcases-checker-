import UIKit

/// ORIENTATION — Partial tier.
///
/// The screen holds the user to landscape: it will not turn back to portrait, so it is
/// only half-way to supporting both. It reports BB40056 "Screen is locked in orientation".
///
/// Elements covered (1):
///   1. The screen   — landscape only             → BB40056 Fail
final class AccessibleOrientationPartialViewController: OrientationDemoViewController {

    override var screenTitle: String { "Orientation (Partial)" }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .landscape }
}
