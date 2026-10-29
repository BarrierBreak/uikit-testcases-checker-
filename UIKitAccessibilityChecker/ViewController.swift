//
//  ViewController.swift
//  UIKitAccessibilityChecker
//
//  Created by Meet Pokar on 31/07/26.
//

import UIKit

class ViewController: UIViewController {

    private let passButton = UIButton(type: .system)
    private let partialButton = UIButton(type: .system)
    private let failButton = UIButton(type: .system)

    // The Extras screens stage the accessible-name defects the three screens above
    // cannot express. They are scanned by UIKitA11yScanRunner, so they need a way in
    // here too — otherwise they can only be inspected headlessly.
    private let extrasPassButton = UIButton(type: .system)
    private let extrasPartialButton = UIButton(type: .system)
    private let extrasFailButton = UIButton(type: .system)

    // Role / Native Role / State screens were previously reachable only through
    // UIKitA11yScanRunner's headless --a11y-scan sweep (it swaps window.rootViewController
    // for ~0.3s per screen and tears down) — there was no stable, real navigation path to
    // any of them, so nothing that needs the screen to actually stay on-screen (keyboard
    // focus navigation, VoiceOver inspection by hand) could reach them. Added here so they
    // behave the same way the Name/Extras screens already do.
    private let rolePassButton = UIButton(type: .system)
    private let rolePartialButton = UIButton(type: .system)
    private let roleFailButton = UIButton(type: .system)

    private let nativeRolePassButton = UIButton(type: .system)
    private let nativeRolePartialButton = UIButton(type: .system)
    private let nativeRoleFailButton = UIButton(type: .system)

    private let statePassButton = UIButton(type: .system)
    private let statePartialButton = UIButton(type: .system)
    private let stateFailButton = UIButton(type: .system)

    private let nativeStatePassButton = UIButton(type: .system)
    private let nativeStatePartialButton = UIButton(type: .system)
    private let nativeStateFailButton = UIButton(type: .system)

    private let keyboardPassButton = UIButton(type: .system)
    private let keyboardPartialButton = UIButton(type: .system)
    private let keyboardFailButton = UIButton(type: .system)

    private let keyboardExtrasPassButton = UIButton(type: .system)
    private let keyboardExtrasPartialButton = UIButton(type: .system)
    private let keyboardExtrasFailButton = UIButton(type: .system)

    private let nativeKeyboardPassButton = UIButton(type: .system)
    private let nativeKeyboardPartialButton = UIButton(type: .system)
    private let nativeKeyboardFailButton = UIButton(type: .system)

    private let textResizePassButton = UIButton(type: .system)
    private let textResizePartialButton = UIButton(type: .system)
    private let textResizeFailButton = UIButton(type: .system)
    private let textClippingPassButton = UIButton(type: .system)
    private let textClippingPartialButton = UIButton(type: .system)
    private let textClippingFailButton = UIButton(type: .system)
    private let targetSizePassButton = UIButton(type: .system)
    private let targetSizePartialButton = UIButton(type: .system)
    private let targetSizeFailButton = UIButton(type: .system)
    private let hiddenPassButton = UIButton(type: .system)
    private let hiddenPartialButton = UIButton(type: .system)
    private let hiddenFailButton = UIButton(type: .system)
    private let languagePassButton = UIButton(type: .system)
    private let languagePartialButton = UIButton(type: .system)
    private let languageFailButton = UIButton(type: .system)
    private let motionPassButton = UIButton(type: .system)
    private let motionPartialButton = UIButton(type: .system)
    private let motionFailButton = UIButton(type: .system)
    private let imagesPassButton = UIButton(type: .system)
    private let imagesPartialButton = UIButton(type: .system)
    private let imagesFailButton = UIButton(type: .system)
    private let newRoleTraitPassButton = UIButton(type: .system)
    private let newRoleTraitPartialButton = UIButton(type: .system)
    private let newRoleTraitFailButton = UIButton(type: .system)
    private let newStateTraitPassButton = UIButton(type: .system)
    private let newStateTraitPartialButton = UIButton(type: .system)
    private let newStateTraitFailButton = UIButton(type: .system)
    private let newButtonPassButton = UIButton(type: .system)
    private let newButtonPartialButton = UIButton(type: .system)
    private let newButtonFailButton = UIButton(type: .system)
    private let newFormLabelPassButton = UIButton(type: .system)
    private let newFormLabelPartialButton = UIButton(type: .system)
    private let newFormLabelFailButton = UIButton(type: .system)
    private let newCustomActionPassButton = UIButton(type: .system)
    private let newCustomActionPartialButton = UIButton(type: .system)
    private let newCustomActionFailButton = UIButton(type: .system)
    private let newErrorMessagePassButton = UIButton(type: .system)
    private let newErrorMessagePartialButton = UIButton(type: .system)
    private let newErrorMessageFailButton = UIButton(type: .system)
    private let newNonTextContrastPassButton = UIButton(type: .system)
    private let newNonTextContrastPartialButton = UIButton(type: .system)
    private let newNonTextContrastFailButton = UIButton(type: .system)
    private let newFocusObscuredPassButton = UIButton(type: .system)
    private let newFocusObscuredPartialButton = UIButton(type: .system)
    private let newFocusObscuredFailButton = UIButton(type: .system)
    private let newModalPassButton = UIButton(type: .system)
    private let newModalPartialButton = UIButton(type: .system)
    private let newModalFailButton = UIButton(type: .system)
    private let newTabControlPassButton = UIButton(type: .system)
    private let newTabControlPartialButton = UIButton(type: .system)
    private let newTabControlFailButton = UIButton(type: .system)
    private let newScreenTitlePassButton = UIButton(type: .system)
    private let newScreenTitlePartialButton = UIButton(type: .system)
    private let newScreenTitleFailButton = UIButton(type: .system)
    private let keyboardLinkPassButton = UIButton(type: .system)
    private let keyboardLinkPartialButton = UIButton(type: .system)
    private let keyboardLinkFailButton = UIButton(type: .system)
    private let newGestureKeyboardPassButton = UIButton(type: .system)
    private let newGestureKeyboardPartialButton = UIButton(type: .system)
    private let newGestureKeyboardFailButton = UIButton(type: .system)
    private let newAutocompletePassButton = UIButton(type: .system)
    private let newAutocompletePartialButton = UIButton(type: .system)
    private let newAutocompleteFailButton = UIButton(type: .system)
    private let newModalClosePassButton = UIButton(type: .system)
    private let newModalClosePartialButton = UIButton(type: .system)
    private let newModalCloseFailButton = UIButton(type: .system)
    private let newLanguageChangePassButton = UIButton(type: .system)
    private let newLanguageChangePartialButton = UIButton(type: .system)
    private let newLanguageChangeFailButton = UIButton(type: .system)
    private let newFocusOrderPassButton = UIButton(type: .system)
    private let newFocusOrderPartialButton = UIButton(type: .system)
    private let newFocusOrderFailButton = UIButton(type: .system)
    private let newTouchEventPassButton = UIButton(type: .system)
    private let newTouchEventPartialButton = UIButton(type: .system)
    private let newTouchEventFailButton = UIButton(type: .system)
    private let readingOrderPassButton = UIButton(type: .system)
    private let readingOrderPartialButton = UIButton(type: .system)
    private let readingOrderFailButton = UIButton(type: .system)
    private let focusPassButton = UIButton(type: .system)
    private let focusPartialButton = UIButton(type: .system)
    private let focusFailButton = UIButton(type: .system)
    private let linkPassButton = UIButton(type: .system)
    private let linkPartialButton = UIButton(type: .system)
    private let linkFailButton = UIButton(type: .system)

    private let textContrastPassButton = UIButton(type: .system)
    private let textContrastPartialButton = UIButton(type: .system)
    private let textContrastFailButton = UIButton(type: .system)

    private let compositedContrastPassButton = UIButton(type: .system)
    private let compositedContrastPartialButton = UIButton(type: .system)
    private let compositedContrastFailButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Accessibility Checker"
        view.backgroundColor = .systemBackground
        passButton.accessibilityLabel = "Accessibility-Pass"
        partialButton.accessibilityLabel = "Accessibility-Partial"
        failButton.accessibilityLabel = "Accessibility-Fail"
        extrasPassButton.accessibilityLabel = "Accessibility-Extras-Pass"
        extrasPartialButton.accessibilityLabel = "Accessibility-Extras-Partial"
        extrasFailButton.accessibilityLabel = "Accessibility-Extras-Fail"
        rolePassButton.accessibilityLabel = "Accessibility-Role-Pass"
        rolePartialButton.accessibilityLabel = "Accessibility-Role-Partial"
        roleFailButton.accessibilityLabel = "Accessibility-Role-Fail"
        nativeRolePassButton.accessibilityLabel = "Accessibility-NativeRole-Pass"
        nativeRolePartialButton.accessibilityLabel = "Accessibility-NativeRole-Partial"
        nativeRoleFailButton.accessibilityLabel = "Accessibility-NativeRole-Fail"
        statePassButton.accessibilityLabel = "Accessibility-State-Pass"
        statePartialButton.accessibilityLabel = "Accessibility-State-Partial"
        stateFailButton.accessibilityLabel = "Accessibility-State-Fail"
        nativeStatePassButton.accessibilityLabel = "Accessibility-NativeState-Pass"
        nativeStatePartialButton.accessibilityLabel = "Accessibility-NativeState-Partial"
        nativeStateFailButton.accessibilityLabel = "Accessibility-NativeState-Fail"
        keyboardPassButton.accessibilityLabel = "Accessibility-Keyboard-Pass"
        keyboardPartialButton.accessibilityLabel = "Accessibility-Keyboard-Partial"
        keyboardFailButton.accessibilityLabel = "Accessibility-Keyboard-Fail"
        keyboardExtrasPassButton.accessibilityLabel = "Accessibility-KeyboardExtras-Pass"
        keyboardExtrasPartialButton.accessibilityLabel = "Accessibility-KeyboardExtras-Partial"
        keyboardExtrasFailButton.accessibilityLabel = "Accessibility-KeyboardExtras-Fail"
        nativeKeyboardPassButton.accessibilityLabel = "Accessibility-NativeKeyboard-Pass"
        nativeKeyboardPartialButton.accessibilityLabel = "Accessibility-NativeKeyboard-Partial"
        nativeKeyboardFailButton.accessibilityLabel = "Accessibility-NativeKeyboard-Fail"
        textResizePassButton.accessibilityLabel = "Accessibility-TextResize-Pass"
        textResizePartialButton.accessibilityLabel = "Accessibility-TextResize-Partial"
        textResizeFailButton.accessibilityLabel = "Accessibility-TextResize-Fail"
        textClippingPassButton.accessibilityLabel = "Accessibility-TextClipping-Pass"
        textClippingPartialButton.accessibilityLabel = "Accessibility-TextClipping-Partial"
        textClippingFailButton.accessibilityLabel = "Accessibility-TextClipping-Fail"
        targetSizePassButton.accessibilityLabel = "Accessibility-TargetSize-Pass"
        targetSizePartialButton.accessibilityLabel = "Accessibility-TargetSize-Partial"
        targetSizeFailButton.accessibilityLabel = "Accessibility-TargetSize-Fail"
        hiddenPassButton.accessibilityLabel = "Accessibility-Hidden-Pass"
        hiddenPartialButton.accessibilityLabel = "Accessibility-Hidden-Partial"
        hiddenFailButton.accessibilityLabel = "Accessibility-Hidden-Fail"
        languagePassButton.accessibilityLabel = "Accessibility-Language-Pass"
        languagePartialButton.accessibilityLabel = "Accessibility-Language-Partial"
        languageFailButton.accessibilityLabel = "Accessibility-Language-Fail"
        motionPassButton.accessibilityLabel = "Accessibility-Motion-Pass"
        motionPartialButton.accessibilityLabel = "Accessibility-Motion-Partial"
        motionFailButton.accessibilityLabel = "Accessibility-Motion-Fail"
        imagesPassButton.accessibilityLabel = "Accessibility-Images-Pass"
        imagesPartialButton.accessibilityLabel = "Accessibility-Images-Partial"
        imagesFailButton.accessibilityLabel = "Accessibility-Images-Fail"
        newRoleTraitPassButton.accessibilityLabel = "Accessibility-RoleTrait-Pass"
        newRoleTraitPartialButton.accessibilityLabel = "Accessibility-RoleTrait-Partial"
        newRoleTraitFailButton.accessibilityLabel = "Accessibility-RoleTrait-Fail"
        newStateTraitPassButton.accessibilityLabel = "Accessibility-StateTrait-Pass"
        newStateTraitPartialButton.accessibilityLabel = "Accessibility-StateTrait-Partial"
        newStateTraitFailButton.accessibilityLabel = "Accessibility-StateTrait-Fail"
        newButtonPassButton.accessibilityLabel = "Accessibility-Button-Pass"
        newButtonPartialButton.accessibilityLabel = "Accessibility-Button-Partial"
        newButtonFailButton.accessibilityLabel = "Accessibility-Button-Fail"
        newFormLabelPassButton.accessibilityLabel = "Accessibility-FormLabel-Pass"
        newFormLabelPartialButton.accessibilityLabel = "Accessibility-FormLabel-Partial"
        newFormLabelFailButton.accessibilityLabel = "Accessibility-FormLabel-Fail"
        newCustomActionPassButton.accessibilityLabel = "Accessibility-CustomAction-Pass"
        newCustomActionPartialButton.accessibilityLabel = "Accessibility-CustomAction-Partial"
        newCustomActionFailButton.accessibilityLabel = "Accessibility-CustomAction-Fail"
        newErrorMessagePassButton.accessibilityLabel = "Accessibility-ErrorMessage-Pass"
        newErrorMessagePartialButton.accessibilityLabel = "Accessibility-ErrorMessage-Partial"
        newErrorMessageFailButton.accessibilityLabel = "Accessibility-ErrorMessage-Fail"
        newNonTextContrastPassButton.accessibilityLabel = "Accessibility-NonTextContrast-Pass"
        newNonTextContrastPartialButton.accessibilityLabel = "Accessibility-NonTextContrast-Partial"
        newNonTextContrastFailButton.accessibilityLabel = "Accessibility-NonTextContrast-Fail"
        newFocusObscuredPassButton.accessibilityLabel = "Accessibility-FocusObscured-Pass"
        newFocusObscuredPartialButton.accessibilityLabel = "Accessibility-FocusObscured-Partial"
        newFocusObscuredFailButton.accessibilityLabel = "Accessibility-FocusObscured-Fail"
        newModalPassButton.accessibilityLabel = "Accessibility-Modal-Pass"
        newModalPartialButton.accessibilityLabel = "Accessibility-Modal-Partial"
        newModalFailButton.accessibilityLabel = "Accessibility-Modal-Fail"
        newTabControlPassButton.accessibilityLabel = "Accessibility-TabControl-Pass"
        newTabControlPartialButton.accessibilityLabel = "Accessibility-TabControl-Partial"
        newTabControlFailButton.accessibilityLabel = "Accessibility-TabControl-Fail"
        newScreenTitlePassButton.accessibilityLabel = "Accessibility-ScreenTitle-Pass"
        newScreenTitlePartialButton.accessibilityLabel = "Accessibility-ScreenTitle-Partial"
        newScreenTitleFailButton.accessibilityLabel = "Accessibility-ScreenTitle-Fail"
        keyboardLinkPassButton.accessibilityLabel = "Accessibility-KeyboardLink-Pass"
        keyboardLinkPartialButton.accessibilityLabel = "Accessibility-KeyboardLink-Partial"
        keyboardLinkFailButton.accessibilityLabel = "Accessibility-KeyboardLink-Fail"
        newGestureKeyboardPassButton.accessibilityLabel = "Accessibility-GestureKeyboard-Pass"
        newGestureKeyboardPartialButton.accessibilityLabel = "Accessibility-GestureKeyboard-Partial"
        newGestureKeyboardFailButton.accessibilityLabel = "Accessibility-GestureKeyboard-Fail"
        newAutocompletePassButton.accessibilityLabel = "Accessibility-Autocomplete-Pass"
        newAutocompletePartialButton.accessibilityLabel = "Accessibility-Autocomplete-Partial"
        newAutocompleteFailButton.accessibilityLabel = "Accessibility-Autocomplete-Fail"
        newModalClosePassButton.accessibilityLabel = "Accessibility-ModalClose-Pass"
        newModalClosePartialButton.accessibilityLabel = "Accessibility-ModalClose-Partial"
        newModalCloseFailButton.accessibilityLabel = "Accessibility-ModalClose-Fail"
        newLanguageChangePassButton.accessibilityLabel = "Accessibility-LanguageChange-Pass"
        newLanguageChangePartialButton.accessibilityLabel = "Accessibility-LanguageChange-Partial"
        newLanguageChangeFailButton.accessibilityLabel = "Accessibility-LanguageChange-Fail"
        newFocusOrderPassButton.accessibilityLabel = "Accessibility-FocusOrder-Pass"
        newFocusOrderPartialButton.accessibilityLabel = "Accessibility-FocusOrder-Partial"
        newFocusOrderFailButton.accessibilityLabel = "Accessibility-FocusOrder-Fail"
        newTouchEventPassButton.accessibilityLabel = "Accessibility-TouchEvent-Pass"
        newTouchEventPartialButton.accessibilityLabel = "Accessibility-TouchEvent-Partial"
        newTouchEventFailButton.accessibilityLabel = "Accessibility-TouchEvent-Fail"
        readingOrderPassButton.accessibilityLabel = "Accessibility-ReadingOrder-Pass"
        readingOrderPartialButton.accessibilityLabel = "Accessibility-ReadingOrder-Partial"
        readingOrderFailButton.accessibilityLabel = "Accessibility-ReadingOrder-Fail"
        focusPassButton.accessibilityLabel = "Accessibility-Focus-Pass"
        focusPartialButton.accessibilityLabel = "Accessibility-Focus-Partial"
        focusFailButton.accessibilityLabel = "Accessibility-Focus-Fail"
        linkPassButton.accessibilityLabel = "Accessibility-Link-Pass"
        linkPartialButton.accessibilityLabel = "Accessibility-Link-Partial"
        linkFailButton.accessibilityLabel = "Accessibility-Link-Fail"
        textContrastPassButton.accessibilityLabel = "Accessibility-TextContrast-Pass"
        textContrastPartialButton.accessibilityLabel = "Accessibility-TextContrast-Partial"
        textContrastFailButton.accessibilityLabel = "Accessibility-TextContrast-Fail"
        compositedContrastPassButton.accessibilityLabel = "Accessibility-CompositedContrast-Pass"
        compositedContrastPartialButton.accessibilityLabel = "Accessibility-CompositedContrast-Partial"
        compositedContrastFailButton.accessibilityLabel = "Accessibility-CompositedContrast-Fail"
        setupButtons()
    }

    private func setupButtons() {

        configureButton(passButton, title: "Accessibility-Pass", action: #selector(openPassScreen))
        configureButton(partialButton, title: "Accessibility-Partial", action: #selector(openPartialScreen))
        configureButton(failButton, title: "Accessibility-Fail", action: #selector(openFailScreen))

        configureButton(extrasPassButton, title: "Accessibility-Extras-Pass", action: #selector(openExtrasPassScreen))
        configureButton(extrasPartialButton, title: "Accessibility-Extras-Partial", action: #selector(openExtrasPartialScreen))
        configureButton(extrasFailButton, title: "Accessibility-Extras-Fail", action: #selector(openExtrasFailScreen))

        configureButton(rolePassButton, title: "Accessibility-Role-Pass", action: #selector(openRolePassScreen))
        configureButton(rolePartialButton, title: "Accessibility-Role-Partial", action: #selector(openRolePartialScreen))
        configureButton(roleFailButton, title: "Accessibility-Role-Fail", action: #selector(openRoleFailScreen))

        configureButton(nativeRolePassButton, title: "Accessibility-NativeRole-Pass", action: #selector(openNativeRolePassScreen))
        configureButton(nativeRolePartialButton, title: "Accessibility-NativeRole-Partial", action: #selector(openNativeRolePartialScreen))
        configureButton(nativeRoleFailButton, title: "Accessibility-NativeRole-Fail", action: #selector(openNativeRoleFailScreen))

        configureButton(statePassButton, title: "Accessibility-State-Pass", action: #selector(openStatePassScreen))
        configureButton(statePartialButton, title: "Accessibility-State-Partial", action: #selector(openStatePartialScreen))
        configureButton(stateFailButton, title: "Accessibility-State-Fail", action: #selector(openStateFailScreen))

        configureButton(nativeStatePassButton, title: "Accessibility-NativeState-Pass", action: #selector(openNativeStatePassScreen))
        configureButton(nativeStatePartialButton, title: "Accessibility-NativeState-Partial", action: #selector(openNativeStatePartialScreen))
        configureButton(nativeStateFailButton, title: "Accessibility-NativeState-Fail", action: #selector(openNativeStateFailScreen))

        configureButton(keyboardPassButton, title: "Accessibility-Keyboard-Pass", action: #selector(openKeyboardPassScreen))
        configureButton(keyboardPartialButton, title: "Accessibility-Keyboard-Partial", action: #selector(openKeyboardPartialScreen))
        configureButton(keyboardFailButton, title: "Accessibility-Keyboard-Fail", action: #selector(openKeyboardFailScreen))
        configureButton(keyboardExtrasPassButton, title: "Accessibility-KeyboardExtras-Pass", action: #selector(openKeyboardExtrasPassScreen))
        configureButton(keyboardExtrasPartialButton, title: "Accessibility-KeyboardExtras-Partial", action: #selector(openKeyboardExtrasPartialScreen))
        configureButton(keyboardExtrasFailButton, title: "Accessibility-KeyboardExtras-Fail", action: #selector(openKeyboardExtrasFailScreen))
        configureButton(nativeKeyboardPassButton, title: "Accessibility-NativeKeyboard-Pass", action: #selector(openNativeKeyboardPassScreen))
        configureButton(nativeKeyboardPartialButton, title: "Accessibility-NativeKeyboard-Partial", action: #selector(openNativeKeyboardPartialScreen))
        configureButton(nativeKeyboardFailButton, title: "Accessibility-NativeKeyboard-Fail", action: #selector(openNativeKeyboardFailScreen))
        configureButton(textResizePassButton, title: "Accessibility-TextResize-Pass", action: #selector(openTextResizePassScreen))
        configureButton(textResizePartialButton, title: "Accessibility-TextResize-Partial", action: #selector(openTextResizePartialScreen))
        configureButton(textResizeFailButton, title: "Accessibility-TextResize-Fail", action: #selector(openTextResizeFailScreen))
        configureButton(textClippingPassButton, title: "Accessibility-TextClipping-Pass", action: #selector(openTextClippingPassScreen))
        configureButton(textClippingPartialButton, title: "Accessibility-TextClipping-Partial", action: #selector(openTextClippingPartialScreen))
        configureButton(textClippingFailButton, title: "Accessibility-TextClipping-Fail", action: #selector(openTextClippingFailScreen))
        configureButton(targetSizePassButton, title: "Accessibility-TargetSize-Pass", action: #selector(openTargetSizePassScreen))
        configureButton(targetSizePartialButton, title: "Accessibility-TargetSize-Partial", action: #selector(openTargetSizePartialScreen))
        configureButton(targetSizeFailButton, title: "Accessibility-TargetSize-Fail", action: #selector(openTargetSizeFailScreen))

        configureButton(textContrastPassButton, title: "Accessibility-TextContrast-Pass", action: #selector(openTextContrastPassScreen))
        configureButton(textContrastPartialButton, title: "Accessibility-TextContrast-Partial", action: #selector(openTextContrastPartialScreen))
        configureButton(textContrastFailButton, title: "Accessibility-TextContrast-Fail", action: #selector(openTextContrastFailScreen))

        configureButton(compositedContrastPassButton, title: "Accessibility-CompositedContrast-Pass", action: #selector(openCompositedContrastPassScreen))
        configureButton(hiddenPassButton, title: "Accessibility-Hidden-Pass", action: #selector(openHiddenPassScreen))
        configureButton(hiddenPartialButton, title: "Accessibility-Hidden-Partial", action: #selector(openHiddenPartialScreen))
        configureButton(hiddenFailButton, title: "Accessibility-Hidden-Fail", action: #selector(openHiddenFailScreen))
        configureButton(languagePassButton, title: "Accessibility-Language-Pass", action: #selector(openLanguagePassScreen))
        configureButton(languagePartialButton, title: "Accessibility-Language-Partial", action: #selector(openLanguagePartialScreen))
        configureButton(languageFailButton, title: "Accessibility-Language-Fail", action: #selector(openLanguageFailScreen))
        configureButton(motionPassButton, title: "Accessibility-Motion-Pass", action: #selector(openMotionPassScreen))
        configureButton(motionPartialButton, title: "Accessibility-Motion-Partial", action: #selector(openMotionPartialScreen))
        configureButton(motionFailButton, title: "Accessibility-Motion-Fail", action: #selector(openMotionFailScreen))
        configureButton(imagesPassButton, title: "Accessibility-Images-Pass", action: #selector(openImagesPassScreen))
        configureButton(imagesPartialButton, title: "Accessibility-Images-Partial", action: #selector(openImagesPartialScreen))
        configureButton(imagesFailButton, title: "Accessibility-Images-Fail", action: #selector(openImagesFailScreen))
        configureButton(newRoleTraitPassButton, title: "Accessibility-RoleTrait-Pass", action: #selector(openRoleTraitPassScreen))
        configureButton(newRoleTraitPartialButton, title: "Accessibility-RoleTrait-Partial", action: #selector(openRoleTraitPartialScreen))
        configureButton(newRoleTraitFailButton, title: "Accessibility-RoleTrait-Fail", action: #selector(openRoleTraitFailScreen))
        configureButton(newStateTraitPassButton, title: "Accessibility-StateTrait-Pass", action: #selector(openStateTraitPassScreen))
        configureButton(newStateTraitPartialButton, title: "Accessibility-StateTrait-Partial", action: #selector(openStateTraitPartialScreen))
        configureButton(newStateTraitFailButton, title: "Accessibility-StateTrait-Fail", action: #selector(openStateTraitFailScreen))
        configureButton(newButtonPassButton, title: "Accessibility-Button-Pass", action: #selector(openButtonPassScreen))
        configureButton(newButtonPartialButton, title: "Accessibility-Button-Partial", action: #selector(openButtonPartialScreen))
        configureButton(newButtonFailButton, title: "Accessibility-Button-Fail", action: #selector(openButtonFailScreen))
        configureButton(newFormLabelPassButton, title: "Accessibility-FormLabel-Pass", action: #selector(openFormLabelPassScreen))
        configureButton(newFormLabelPartialButton, title: "Accessibility-FormLabel-Partial", action: #selector(openFormLabelPartialScreen))
        configureButton(newFormLabelFailButton, title: "Accessibility-FormLabel-Fail", action: #selector(openFormLabelFailScreen))
        configureButton(newCustomActionPassButton, title: "Accessibility-CustomAction-Pass", action: #selector(openCustomActionPassScreen))
        configureButton(newCustomActionPartialButton, title: "Accessibility-CustomAction-Partial", action: #selector(openCustomActionPartialScreen))
        configureButton(newCustomActionFailButton, title: "Accessibility-CustomAction-Fail", action: #selector(openCustomActionFailScreen))
        configureButton(newErrorMessagePassButton, title: "Accessibility-ErrorMessage-Pass", action: #selector(openErrorMessagePassScreen))
        configureButton(newErrorMessagePartialButton, title: "Accessibility-ErrorMessage-Partial", action: #selector(openErrorMessagePartialScreen))
        configureButton(newErrorMessageFailButton, title: "Accessibility-ErrorMessage-Fail", action: #selector(openErrorMessageFailScreen))
        configureButton(newNonTextContrastPassButton, title: "Accessibility-NonTextContrast-Pass", action: #selector(openNonTextContrastPassScreen))
        configureButton(newNonTextContrastPartialButton, title: "Accessibility-NonTextContrast-Partial", action: #selector(openNonTextContrastPartialScreen))
        configureButton(newNonTextContrastFailButton, title: "Accessibility-NonTextContrast-Fail", action: #selector(openNonTextContrastFailScreen))
        configureButton(newFocusObscuredPassButton, title: "Accessibility-FocusObscured-Pass", action: #selector(openFocusObscuredPassScreen))
        configureButton(newFocusObscuredPartialButton, title: "Accessibility-FocusObscured-Partial", action: #selector(openFocusObscuredPartialScreen))
        configureButton(newFocusObscuredFailButton, title: "Accessibility-FocusObscured-Fail", action: #selector(openFocusObscuredFailScreen))
        configureButton(newModalPassButton, title: "Accessibility-Modal-Pass", action: #selector(openModalPassScreen))
        configureButton(newModalPartialButton, title: "Accessibility-Modal-Partial", action: #selector(openModalPartialScreen))
        configureButton(newModalFailButton, title: "Accessibility-Modal-Fail", action: #selector(openModalFailScreen))
        configureButton(newTabControlPassButton, title: "Accessibility-TabControl-Pass", action: #selector(openTabControlPassScreen))
        configureButton(newTabControlPartialButton, title: "Accessibility-TabControl-Partial", action: #selector(openTabControlPartialScreen))
        configureButton(newTabControlFailButton, title: "Accessibility-TabControl-Fail", action: #selector(openTabControlFailScreen))
        configureButton(newScreenTitlePassButton, title: "Accessibility-ScreenTitle-Pass", action: #selector(openScreenTitlePassScreen))
        configureButton(newScreenTitlePartialButton, title: "Accessibility-ScreenTitle-Partial", action: #selector(openScreenTitlePartialScreen))
        configureButton(newScreenTitleFailButton, title: "Accessibility-ScreenTitle-Fail", action: #selector(openScreenTitleFailScreen))
        configureButton(keyboardLinkPassButton, title: "Accessibility-KeyboardLink-Pass", action: #selector(openKeyboardLinkPassScreen))
        configureButton(keyboardLinkPartialButton, title: "Accessibility-KeyboardLink-Partial", action: #selector(openKeyboardLinkPartialScreen))
        configureButton(keyboardLinkFailButton, title: "Accessibility-KeyboardLink-Fail", action: #selector(openKeyboardLinkFailScreen))
        configureButton(newGestureKeyboardPassButton, title: "Accessibility-GestureKeyboard-Pass", action: #selector(openGestureKeyboardPassScreen))
        configureButton(newGestureKeyboardPartialButton, title: "Accessibility-GestureKeyboard-Partial", action: #selector(openGestureKeyboardPartialScreen))
        configureButton(newGestureKeyboardFailButton, title: "Accessibility-GestureKeyboard-Fail", action: #selector(openGestureKeyboardFailScreen))
        configureButton(newAutocompletePassButton, title: "Accessibility-Autocomplete-Pass", action: #selector(openAutocompletePassScreen))
        configureButton(newAutocompletePartialButton, title: "Accessibility-Autocomplete-Partial", action: #selector(openAutocompletePartialScreen))
        configureButton(newAutocompleteFailButton, title: "Accessibility-Autocomplete-Fail", action: #selector(openAutocompleteFailScreen))
        configureButton(newModalClosePassButton, title: "Accessibility-ModalClose-Pass", action: #selector(openModalClosePassScreen))
        configureButton(newModalClosePartialButton, title: "Accessibility-ModalClose-Partial", action: #selector(openModalClosePartialScreen))
        configureButton(newModalCloseFailButton, title: "Accessibility-ModalClose-Fail", action: #selector(openModalCloseFailScreen))
        configureButton(newLanguageChangePassButton, title: "Accessibility-LanguageChange-Pass", action: #selector(openLanguageChangePassScreen))
        configureButton(newLanguageChangePartialButton, title: "Accessibility-LanguageChange-Partial", action: #selector(openLanguageChangePartialScreen))
        configureButton(newLanguageChangeFailButton, title: "Accessibility-LanguageChange-Fail", action: #selector(openLanguageChangeFailScreen))
        configureButton(newFocusOrderPassButton, title: "Accessibility-FocusOrder-Pass", action: #selector(openFocusOrderPassScreen))
        configureButton(newFocusOrderPartialButton, title: "Accessibility-FocusOrder-Partial", action: #selector(openFocusOrderPartialScreen))
        configureButton(newFocusOrderFailButton, title: "Accessibility-FocusOrder-Fail", action: #selector(openFocusOrderFailScreen))
        configureButton(newTouchEventPassButton, title: "Accessibility-TouchEvent-Pass", action: #selector(openTouchEventPassScreen))
        configureButton(newTouchEventPartialButton, title: "Accessibility-TouchEvent-Partial", action: #selector(openTouchEventPartialScreen))
        configureButton(newTouchEventFailButton, title: "Accessibility-TouchEvent-Fail", action: #selector(openTouchEventFailScreen))
        configureButton(readingOrderPassButton, title: "Accessibility-ReadingOrder-Pass", action: #selector(openReadingOrderPassScreen))
        configureButton(readingOrderPartialButton, title: "Accessibility-ReadingOrder-Partial", action: #selector(openReadingOrderPartialScreen))
        configureButton(readingOrderFailButton, title: "Accessibility-ReadingOrder-Fail", action: #selector(openReadingOrderFailScreen))
        configureButton(focusPassButton, title: "Accessibility-Focus-Pass", action: #selector(openFocusPassScreen))
        configureButton(focusPartialButton, title: "Accessibility-Focus-Partial", action: #selector(openFocusPartialScreen))
        configureButton(focusFailButton, title: "Accessibility-Focus-Fail", action: #selector(openFocusFailScreen))
        configureButton(linkPassButton, title: "Accessibility-Link-Pass", action: #selector(openLinkPassScreen))
        configureButton(linkPartialButton, title: "Accessibility-Link-Partial", action: #selector(openLinkPartialScreen))
        configureButton(linkFailButton, title: "Accessibility-Link-Fail", action: #selector(openLinkFailScreen))
        configureButton(compositedContrastPartialButton, title: "Accessibility-CompositedContrast-Partial", action: #selector(openCompositedContrastPartialScreen))
        configureButton(compositedContrastFailButton, title: "Accessibility-CompositedContrast-Fail", action: #selector(openCompositedContrastFailScreen))

        // 36 buttons no longer fit a fixed-height, centered stack — wrapped in a scroll
        // view, matching the pattern every example screen in this app already uses
        // (see AccessibleNamePassViewController.buildLayout()) rather than inventing a
        // second layout convention.
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let stackView = UIStackView(arrangedSubviews: [
            passButton, partialButton, failButton,
            extrasPassButton, extrasPartialButton, extrasFailButton,
            rolePassButton, rolePartialButton, roleFailButton,
            nativeRolePassButton, nativeRolePartialButton, nativeRoleFailButton,
            statePassButton, statePartialButton, stateFailButton,
            nativeStatePassButton, nativeStatePartialButton, nativeStateFailButton,
            keyboardPassButton, keyboardPartialButton, keyboardFailButton,
            keyboardExtrasPassButton, keyboardExtrasPartialButton, keyboardExtrasFailButton,
            nativeKeyboardPassButton, nativeKeyboardPartialButton, nativeKeyboardFailButton,
            targetSizePassButton, targetSizePartialButton, targetSizeFailButton,
            hiddenPassButton, hiddenPartialButton, hiddenFailButton,
            languagePassButton, languagePartialButton, languageFailButton,
            motionPassButton, motionPartialButton, motionFailButton,
            imagesPassButton, imagesPartialButton, imagesFailButton,
            newRoleTraitPassButton, newRoleTraitPartialButton, newRoleTraitFailButton,
            newStateTraitPassButton, newStateTraitPartialButton, newStateTraitFailButton,
            newButtonPassButton, newButtonPartialButton, newButtonFailButton,
            newFormLabelPassButton, newFormLabelPartialButton, newFormLabelFailButton,
            newCustomActionPassButton, newCustomActionPartialButton, newCustomActionFailButton,
            newErrorMessagePassButton, newErrorMessagePartialButton, newErrorMessageFailButton,
            newNonTextContrastPassButton, newNonTextContrastPartialButton, newNonTextContrastFailButton,
            newFocusObscuredPassButton, newFocusObscuredPartialButton, newFocusObscuredFailButton,
            newModalPassButton, newModalPartialButton, newModalFailButton,
            newTabControlPassButton, newTabControlPartialButton, newTabControlFailButton,
            newScreenTitlePassButton, newScreenTitlePartialButton, newScreenTitleFailButton,
            keyboardLinkPassButton, keyboardLinkPartialButton, keyboardLinkFailButton,
            newGestureKeyboardPassButton, newGestureKeyboardPartialButton, newGestureKeyboardFailButton,
            newAutocompletePassButton, newAutocompletePartialButton, newAutocompleteFailButton,
            newModalClosePassButton, newModalClosePartialButton, newModalCloseFailButton,
            newLanguageChangePassButton, newLanguageChangePartialButton, newLanguageChangeFailButton,
            newFocusOrderPassButton, newFocusOrderPartialButton, newFocusOrderFailButton,
            newTouchEventPassButton, newTouchEventPartialButton, newTouchEventFailButton,
            readingOrderPassButton, readingOrderPartialButton, readingOrderFailButton,
            focusPassButton, focusPartialButton, focusFailButton,
            linkPassButton, linkPartialButton, linkFailButton,
            textResizePassButton, textResizePartialButton, textResizeFailButton, textClippingPassButton, textClippingPartialButton, textClippingFailButton,
            textContrastPassButton, textContrastPartialButton, textContrastFailButton,
            compositedContrastPassButton, compositedContrastPartialButton, compositedContrastFailButton
        ])

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -30),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -60),
            stackView.heightAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(36 * 56 + 35 * 16))
        ])
    }

    private func configureButton(_ button: UIButton,
                                 title: String,
                                 action: Selector) {

        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true

        button.addTarget(self, action: action, for: .touchUpInside)
    }

    @objc private func openPassScreen() {
        navigationController?.pushViewController(AccessibleNamePassViewController(), animated: true)
    }

    @objc private func openPartialScreen() {
        navigationController?.pushViewController(AccessibleNamePartialViewController(), animated: true)
    }

    @objc private func openFailScreen() {
        navigationController?.pushViewController(AccessibleNameFailViewController(), animated: true)
    }

    @objc private func openExtrasPassScreen() {
        navigationController?.pushViewController(AccessibleNameExtrasPassViewController(), animated: true)
    }

    @objc private func openExtrasPartialScreen() {
        navigationController?.pushViewController(AccessibleNameExtrasPartialViewController(), animated: true)
    }

    @objc private func openExtrasFailScreen() {
        navigationController?.pushViewController(AccessibleNameExtrasFailViewController(), animated: true)
    }

    @objc private func openRolePassScreen() {
        navigationController?.pushViewController(AccessibleRolePassViewController(), animated: true)
    }

    @objc private func openRolePartialScreen() {
        navigationController?.pushViewController(AccessibleRolePartialViewController(), animated: true)
    }

    @objc private func openRoleFailScreen() {
        navigationController?.pushViewController(AccessibleRoleFailViewController(), animated: true)
    }

    @objc private func openNativeRolePassScreen() {
        navigationController?.pushViewController(AccessibleNativeRolePassViewController(), animated: true)
    }

    @objc private func openNativeRolePartialScreen() {
        navigationController?.pushViewController(AccessibleNativeRolePartialViewController(), animated: true)
    }

    @objc private func openNativeRoleFailScreen() {
        navigationController?.pushViewController(AccessibleNativeRoleFailViewController(), animated: true)
    }

    @objc private func openStatePassScreen() {
        navigationController?.pushViewController(AccessibleStatePassViewController(), animated: true)
    }

    @objc private func openStatePartialScreen() {
        navigationController?.pushViewController(AccessibleStatePartialViewController(), animated: true)
    }

    @objc private func openStateFailScreen() {
        navigationController?.pushViewController(AccessibleStateFailViewController(), animated: true)
    }

    @objc private func openNativeStatePassScreen() {
        navigationController?.pushViewController(AccessibleNativeStatePassViewController(), animated: true)
    }

    @objc private func openNativeStatePartialScreen() {
        navigationController?.pushViewController(AccessibleNativeStatePartialViewController(), animated: true)
    }

    @objc private func openNativeStateFailScreen() {
        navigationController?.pushViewController(AccessibleNativeStateFailViewController(), animated: true)
    }

    @objc private func openKeyboardPassScreen() {
        navigationController?.pushViewController(AccessibleKeyboardPassViewController(), animated: true)
    }

    @objc private func openKeyboardPartialScreen() {
        navigationController?.pushViewController(AccessibleKeyboardPartialViewController(), animated: true)
    }

    @objc private func openTextResizePassScreen() {
        navigationController?.pushViewController(AccessibleTextResizePassViewController(), animated: true)
    }

    @objc private func openTextResizePartialScreen() {
        navigationController?.pushViewController(AccessibleTextResizePartialViewController(), animated: true)
    }

    @objc private func openTextResizeFailScreen() {
        navigationController?.pushViewController(AccessibleTextResizeFailViewController(), animated: true)
    }

    @objc private func openTextClippingPassScreen() {
        navigationController?.pushViewController(AccessibleTextClippingPassViewController(), animated: true)
    }

    @objc private func openTextClippingPartialScreen() {
        navigationController?.pushViewController(AccessibleTextClippingPartialViewController(), animated: true)
    }

    @objc private func openTextClippingFailScreen() {
        navigationController?.pushViewController(AccessibleTextClippingFailViewController(), animated: true)
    }

    @objc private func openFocusPassScreen() {
        navigationController?.pushViewController(AccessibleFocusPassViewController(), animated: true)
    }

    @objc private func openFocusPartialScreen() {
        navigationController?.pushViewController(AccessibleFocusPartialViewController(), animated: true)
    }

    @objc private func openFocusFailScreen() {
        navigationController?.pushViewController(AccessibleFocusFailViewController(), animated: true)
    }

    @objc private func openLinkPassScreen() {
        navigationController?.pushViewController(AccessibleLinkPassViewController(), animated: true)
    }

    @objc private func openLinkPartialScreen() {
        navigationController?.pushViewController(AccessibleLinkPartialViewController(), animated: true)
    }

    @objc private func openLinkFailScreen() {
        navigationController?.pushViewController(AccessibleLinkFailViewController(), animated: true)
    }

    @objc private func openRoleTraitPassScreen() {
        navigationController?.pushViewController(AccessibleRoleTraitPassViewController(), animated: true)
    }

    @objc private func openRoleTraitPartialScreen() {
        navigationController?.pushViewController(AccessibleRoleTraitPartialViewController(), animated: true)
    }

    @objc private func openRoleTraitFailScreen() {
        navigationController?.pushViewController(AccessibleRoleTraitFailViewController(), animated: true)
    }

    @objc private func openStateTraitPassScreen() {
        navigationController?.pushViewController(AccessibleStateTraitPassViewController(), animated: true)
    }

    @objc private func openStateTraitPartialScreen() {
        navigationController?.pushViewController(AccessibleStateTraitPartialViewController(), animated: true)
    }

    @objc private func openStateTraitFailScreen() {
        navigationController?.pushViewController(AccessibleStateTraitFailViewController(), animated: true)
    }

    @objc private func openButtonPassScreen() {
        navigationController?.pushViewController(AccessibleButtonPassViewController(), animated: true)
    }

    @objc private func openButtonPartialScreen() {
        navigationController?.pushViewController(AccessibleButtonPartialViewController(), animated: true)
    }

    @objc private func openButtonFailScreen() {
        navigationController?.pushViewController(AccessibleButtonFailViewController(), animated: true)
    }

    @objc private func openFormLabelPassScreen() {
        navigationController?.pushViewController(AccessibleFormLabelPassViewController(), animated: true)
    }

    @objc private func openFormLabelPartialScreen() {
        navigationController?.pushViewController(AccessibleFormLabelPartialViewController(), animated: true)
    }

    @objc private func openFormLabelFailScreen() {
        navigationController?.pushViewController(AccessibleFormLabelFailViewController(), animated: true)
    }

    @objc private func openCustomActionPassScreen() {
        navigationController?.pushViewController(AccessibleCustomActionPassViewController(), animated: true)
    }

    @objc private func openCustomActionPartialScreen() {
        navigationController?.pushViewController(AccessibleCustomActionPartialViewController(), animated: true)
    }

    @objc private func openCustomActionFailScreen() {
        navigationController?.pushViewController(AccessibleCustomActionFailViewController(), animated: true)
    }

    @objc private func openErrorMessagePassScreen() {
        navigationController?.pushViewController(AccessibleErrorMessagePassViewController(), animated: true)
    }

    @objc private func openErrorMessagePartialScreen() {
        navigationController?.pushViewController(AccessibleErrorMessagePartialViewController(), animated: true)
    }

    @objc private func openErrorMessageFailScreen() {
        navigationController?.pushViewController(AccessibleErrorMessageFailViewController(), animated: true)
    }

    @objc private func openNonTextContrastPassScreen() {
        navigationController?.pushViewController(AccessibleNonTextContrastPassViewController(), animated: true)
    }

    @objc private func openNonTextContrastPartialScreen() {
        navigationController?.pushViewController(AccessibleNonTextContrastPartialViewController(), animated: true)
    }

    @objc private func openNonTextContrastFailScreen() {
        navigationController?.pushViewController(AccessibleNonTextContrastFailViewController(), animated: true)
    }

    @objc private func openFocusObscuredPassScreen() {
        navigationController?.pushViewController(AccessibleFocusObscuredPassViewController(), animated: true)
    }

    @objc private func openFocusObscuredPartialScreen() {
        navigationController?.pushViewController(AccessibleFocusObscuredPartialViewController(), animated: true)
    }

    @objc private func openFocusObscuredFailScreen() {
        navigationController?.pushViewController(AccessibleFocusObscuredFailViewController(), animated: true)
    }

    @objc private func openModalPassScreen() {
        navigationController?.pushViewController(AccessibleModalPassViewController(), animated: true)
    }

    @objc private func openModalPartialScreen() {
        navigationController?.pushViewController(AccessibleModalPartialViewController(), animated: true)
    }

    @objc private func openModalFailScreen() {
        navigationController?.pushViewController(AccessibleModalFailViewController(), animated: true)
    }

    @objc private func openTabControlPassScreen() {
        navigationController?.pushViewController(AccessibleTabControlPassViewController(), animated: true)
    }

    @objc private func openTabControlPartialScreen() {
        navigationController?.pushViewController(AccessibleTabControlPartialViewController(), animated: true)
    }

    @objc private func openTabControlFailScreen() {
        navigationController?.pushViewController(AccessibleTabControlFailViewController(), animated: true)
    }

    @objc private func openScreenTitlePassScreen() {
        navigationController?.pushViewController(AccessibleScreenTitlePassViewController(), animated: true)
    }

    @objc private func openScreenTitlePartialScreen() {
        navigationController?.pushViewController(AccessibleScreenTitlePartialViewController(), animated: true)
    }

    @objc private func openScreenTitleFailScreen() {
        navigationController?.pushViewController(AccessibleScreenTitleFailViewController(), animated: true)
    }

    @objc private func openKeyboardLinkPassScreen() {
        navigationController?.pushViewController(AccessibleKeyboardLinkPassViewController(), animated: true)
    }

    @objc private func openKeyboardLinkPartialScreen() {
        navigationController?.pushViewController(AccessibleKeyboardLinkPartialViewController(), animated: true)
    }

    @objc private func openKeyboardLinkFailScreen() {
        navigationController?.pushViewController(AccessibleKeyboardLinkFailViewController(), animated: true)
    }

    @objc private func openGestureKeyboardPassScreen() {
        navigationController?.pushViewController(AccessibleGestureKeyboardPassViewController(), animated: true)
    }

    @objc private func openGestureKeyboardPartialScreen() {
        navigationController?.pushViewController(AccessibleGestureKeyboardPartialViewController(), animated: true)
    }

    @objc private func openGestureKeyboardFailScreen() {
        navigationController?.pushViewController(AccessibleGestureKeyboardFailViewController(), animated: true)
    }

    @objc private func openAutocompletePassScreen() {
        navigationController?.pushViewController(AccessibleAutocompletePassViewController(), animated: true)
    }

    @objc private func openAutocompletePartialScreen() {
        navigationController?.pushViewController(AccessibleAutocompletePartialViewController(), animated: true)
    }

    @objc private func openAutocompleteFailScreen() {
        navigationController?.pushViewController(AccessibleAutocompleteFailViewController(), animated: true)
    }

    @objc private func openModalClosePassScreen() {
        navigationController?.pushViewController(AccessibleModalClosePassViewController(), animated: true)
    }

    @objc private func openModalClosePartialScreen() {
        navigationController?.pushViewController(AccessibleModalClosePartialViewController(), animated: true)
    }

    @objc private func openModalCloseFailScreen() {
        navigationController?.pushViewController(AccessibleModalCloseFailViewController(), animated: true)
    }

    @objc private func openLanguageChangePassScreen() {
        navigationController?.pushViewController(AccessibleLanguageChangePassViewController(), animated: true)
    }

    @objc private func openLanguageChangePartialScreen() {
        navigationController?.pushViewController(AccessibleLanguageChangePartialViewController(), animated: true)
    }

    @objc private func openLanguageChangeFailScreen() {
        navigationController?.pushViewController(AccessibleLanguageChangeFailViewController(), animated: true)
    }

    @objc private func openFocusOrderPassScreen() {
        navigationController?.pushViewController(AccessibleFocusOrderPassViewController(), animated: true)
    }

    @objc private func openFocusOrderPartialScreen() {
        navigationController?.pushViewController(AccessibleFocusOrderPartialViewController(), animated: true)
    }

    @objc private func openFocusOrderFailScreen() {
        navigationController?.pushViewController(AccessibleFocusOrderFailViewController(), animated: true)
    }

    @objc private func openTouchEventPassScreen() {
        navigationController?.pushViewController(AccessibleTouchEventPassViewController(), animated: true)
    }

    @objc private func openTouchEventPartialScreen() {
        navigationController?.pushViewController(AccessibleTouchEventPartialViewController(), animated: true)
    }

    @objc private func openTouchEventFailScreen() {
        navigationController?.pushViewController(AccessibleTouchEventFailViewController(), animated: true)
    }

    @objc private func openReadingOrderPassScreen() {
        navigationController?.pushViewController(AccessibleReadingOrderPassViewController(), animated: true)
    }

    @objc private func openReadingOrderPartialScreen() {
        navigationController?.pushViewController(AccessibleReadingOrderPartialViewController(), animated: true)
    }

    @objc private func openReadingOrderFailScreen() {
        navigationController?.pushViewController(AccessibleReadingOrderFailViewController(), animated: true)
    }

    @objc private func openImagesPassScreen() {
        navigationController?.pushViewController(AccessibleImagesPassViewController(), animated: true)
    }

    @objc private func openImagesPartialScreen() {
        navigationController?.pushViewController(AccessibleImagesPartialViewController(), animated: true)
    }

    @objc private func openImagesFailScreen() {
        navigationController?.pushViewController(AccessibleImagesFailViewController(), animated: true)
    }

    @objc private func openMotionPassScreen() {
        navigationController?.pushViewController(AccessibleMotionPassViewController(), animated: true)
    }

    @objc private func openMotionPartialScreen() {
        navigationController?.pushViewController(AccessibleMotionPartialViewController(), animated: true)
    }

    @objc private func openMotionFailScreen() {
        navigationController?.pushViewController(AccessibleMotionFailViewController(), animated: true)
    }

    @objc private func openLanguagePassScreen() {
        navigationController?.pushViewController(AccessibleLanguagePassViewController(), animated: true)
    }

    @objc private func openLanguagePartialScreen() {
        navigationController?.pushViewController(AccessibleLanguagePartialViewController(), animated: true)
    }

    @objc private func openLanguageFailScreen() {
        navigationController?.pushViewController(AccessibleLanguageFailViewController(), animated: true)
    }

    @objc private func openHiddenPassScreen() {
        navigationController?.pushViewController(AccessibleHiddenPassViewController(), animated: true)
    }

    @objc private func openHiddenPartialScreen() {
        navigationController?.pushViewController(AccessibleHiddenPartialViewController(), animated: true)
    }

    @objc private func openHiddenFailScreen() {
        navigationController?.pushViewController(AccessibleHiddenFailViewController(), animated: true)
    }

    @objc private func openTargetSizePassScreen() {
        navigationController?.pushViewController(AccessibleTargetSizePassViewController(), animated: true)
    }

    @objc private func openTargetSizePartialScreen() {
        navigationController?.pushViewController(AccessibleTargetSizePartialViewController(), animated: true)
    }

    @objc private func openTargetSizeFailScreen() {
        navigationController?.pushViewController(AccessibleTargetSizeFailViewController(), animated: true)
    }

    @objc private func openKeyboardExtrasPassScreen() {
        navigationController?.pushViewController(AccessibleKeyboardExtrasPassViewController(), animated: true)
    }

    @objc private func openKeyboardExtrasPartialScreen() {
        navigationController?.pushViewController(AccessibleKeyboardExtrasPartialViewController(), animated: true)
    }

    @objc private func openKeyboardExtrasFailScreen() {
        navigationController?.pushViewController(AccessibleKeyboardExtrasFailViewController(), animated: true)
    }

    @objc private func openNativeKeyboardPassScreen() {
        navigationController?.pushViewController(AccessibleNativeKeyboardPassViewController(), animated: true)
    }

    @objc private func openNativeKeyboardPartialScreen() {
        navigationController?.pushViewController(AccessibleNativeKeyboardPartialViewController(), animated: true)
    }

    @objc private func openNativeKeyboardFailScreen() {
        navigationController?.pushViewController(AccessibleNativeKeyboardFailViewController(), animated: true)
    }

    @objc private func openKeyboardFailScreen() {
        navigationController?.pushViewController(AccessibleKeyboardFailViewController(), animated: true)
    }

    @objc private func openTextContrastPassScreen() {
        navigationController?.pushViewController(AccessibleTextContrastPassViewController(), animated: true)
    }

    @objc private func openTextContrastPartialScreen() {
        navigationController?.pushViewController(AccessibleTextContrastPartialViewController(), animated: true)
    }

    @objc private func openTextContrastFailScreen() {
        navigationController?.pushViewController(AccessibleTextContrastFailViewController(), animated: true)
    }

    @objc private func openCompositedContrastPassScreen() {
        navigationController?.pushViewController(AccessibleTextContrastCompositedPassViewController(), animated: true)
    }

    @objc private func openCompositedContrastPartialScreen() {
        navigationController?.pushViewController(AccessibleTextContrastCompositedPartialViewController(), animated: true)
    }

    @objc private func openCompositedContrastFailScreen() {
        navigationController?.pushViewController(AccessibleTextContrastCompositedFailViewController(), animated: true)
    }
}
