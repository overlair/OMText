//
//  File.swift
//  
//
//  Created by John Knowles on 9/27/24.
//

import OMTextObjC
#if os(iOS)
import UIKit
public protocol OMTextDelegate {
    func didChangeSelection(textView: UITextView,  range: NSRange, text: NSAttributedString)
    func didChangeText(textView: UITextView,  text: NSAttributedString)
    func shouldChange(_ textView: UITextView,
                      shouldChangeTextIn range: NSRange,
                      replacementText text: String) -> Bool
    
    func processChange(_ textStorage: OMTextStorage)
    
    func didStartEditing()
    func didEndEditing(_ text: NSAttributedString)
    
    func didStartFinding()
    func didEndFinding()

    func didChangeScroll(_ point: CGPoint)

    func shouldOpenURL( _ URL: URL,
                        in textView: UITextView,
                        range: NSRange,
                        interaction: UITextItemInteraction) -> Bool
    
    
}

public extension OMTextDelegate {
    func didChangeSelection(_ range: NSRange, text: NSAttributedString) {}
    func didChange(_ text: NSAttributedString) {}
    func shouldChange(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        true
    }
    
    func didTapLink(in range: NSRange) {}

    func didStartEditing() {}
    func didEndEditing(_ text: NSAttributedString) {}

    func didStartFinding() {}
    func didEndFinding() {}
    
    func didChangeScroll(_ point: CGPoint) {}
}
#endif

#if os(macOS)
import AppKit
public protocol OMTextDelegate {
    func didChangeSelection(textView: NSTextView,  range: NSRange, text: NSAttributedString)
    func didChangeText(textView: NSTextView)
    func shouldChange(_ textView: NSTextView,
                      shouldChangeTextIn range: NSRange,
                      replacementText text: String) -> Bool
    
    func processChange(_ textStorage: OMTextStorage)
    
    func didStartEditing()
    func didEndEditing()
    
    func didStartFinding()
    func didEndFinding()

    func didChangeScroll(_ point: CGPoint)

    func openLink(textView: NSTextView,
                       clickedOnLink link: Any,
                       at charIndex: Int)
    
    
}

public extension OMTextDelegate {
    func didChangeSelection(_ range: NSRange, text: NSAttributedString) {}
    func didChange(_ text: NSAttributedString) {}
    func shouldChange(_ textView: NSTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        true
    }
    
    func didTapLink(in range: NSRange) {}

    func didStartEditing() {}
    func didEndEditing(_ text: NSAttributedString) {}

    func didStartFinding() {}
    func didEndFinding() {}
    
    func didChangeScroll(_ point: CGPoint) {}
}
#endif
