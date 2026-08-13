//
//  SourceLineTagging.swift
//  UIKitAccessibilityChecker
//
//  Nothing at runtime knows which line of code declared a control — a live view carries
//  no link back to its source. So each control records it: `.srcLine()` writes
//  "src:<line>" into accessibilityIdentifier, and `#line` as a default argument expands
//  at the CALL SITE, so the value is the line where `.srcLine()` is written — which for a
//  stored property is its declaration line.
//
//  The scan reads that identifier back and prints it beside each finding, so a report row
//  points straight at the control that caused it.
//

import UIKit

extension UIView {
    /// Tags this control with the source line it is declared on, and returns it so the
    /// call chains onto a property declaration: `let button = UIButton().srcLine()`.
    @discardableResult
    func srcLine(_ line: Int = #line, file: String = #fileID) -> Self {
        // File as well as line: a control declared in one file can be USED by another
        // screen — PlainRatingControl lives in the Partial view controller but the Fail
        // screen renders it — and a bare line number then reads as a line in the wrong
        // file. #fileID is "Module/File.swift", so take the last component.
        if accessibilityIdentifier == nil {
            let name = file.split(separator: "/").last.map(String.init) ?? file
            accessibilityIdentifier = "src:\(name):\(line)"
        }
        return self
    }
}
