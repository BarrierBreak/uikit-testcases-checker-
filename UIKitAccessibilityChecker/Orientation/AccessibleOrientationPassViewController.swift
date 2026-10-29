import UIKit

/// ORIENTATION — Pass tier.
///
/// The screen turns with the device, in portrait and in landscape. It reports BB40055 as a
/// Validate: a person confirms that all of the content is still there in each orientation.
///
/// Elements covered (1):
///   1. The screen   — allows every orientation   → BB40055 Validate
final class AccessibleOrientationPassViewController: OrientationDemoViewController {

    override var screenTitle: String { "Orientation (Pass)" }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .allButUpsideDown }
}
