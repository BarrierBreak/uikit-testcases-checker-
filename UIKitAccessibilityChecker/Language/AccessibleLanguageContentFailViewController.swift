//
//  AccessibleLanguageContentFailViewController.swift
//
//  WCAG 3.1.1 Language of Page (Level A) — applied to the whole app (WCAG2ICT)
//  Issue: Language of content does not match app language
//  Rule ID: BB40109
//
//  The app's language is English (CFBundleDevelopmentRegion = "en", the Xcode
//  default), but every piece of content on this screen is written in French.
//  No `accessibilityLanguage` is set anywhere, so VoiceOver keeps using the
//  app's English voice and mispronounces all the French text.
//
//  Elements covered (5) — every one fails, BB40109:
//    1. Heading      "Paramètres du compte"
//    2. Description  "Modifiez vos préférences ci-dessous. …"
//    3. Switch       "Recevoir les notifications"
//    4. Text field   "Nom d'utilisateur"
//    5. Button       "Enregistrer les modifications"
//  (The status line is empty until Save is tapped; the switch's visible caption is not an
//  accessibility element — the switch carries the name.)
//
//  How to test by hand:
//    1. Keep the project's development region as English.
//    2. Set the device language to English.
//    3. Turn OFF VoiceOver › Speech › Detect Languages, otherwise VoiceOver may
//       guess French and hide the failure.
//    4. Swipe through the screen: every element is read in the English voice.
//
//  Fix: set accessibilityLanguage = "fr" on each element (and post the announcement as an
//  attributed string with .accessibilitySpeechLanguage "fr") — see the Partial screen.
//

import UIKit

final class AccessibleLanguageContentFailViewController: LanguageContentCardViewController {
    override var screenTitle: String { "Paramètres (Fail)" }
    override var heading: Text { Text(string: "Paramètres du compte", language: nil) }
    override var body: Text {
        Text(string: "Modifiez vos préférences ci-dessous. Les changements seront enregistrés immédiatement.", language: nil)
    }
    override var switchName: Text { Text(string: "Recevoir les notifications", language: nil) }
    override var fieldName: Text { Text(string: "Nom d'utilisateur", language: nil) }
    override var saveTitle: Text { Text(string: "Enregistrer les modifications", language: nil) }
    override var savedMessage: Text { Text(string: "Vos modifications ont été enregistrées.", language: nil) }
}
