//
//  File.swift
//  
//
//  Created by John Knowles on 9/27/24.
//

import Foundation

#if os(iOS)
import UIKit

@available(iOS 16.0, *)
public typealias OMTextView = OMUITextView


@available(iOS 16.0, *)
public class OMUITextView: UITextView {
    var textDelegate: OMTextDelegate?
    var isFinding = false
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.isFindInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func findInteraction(_ interaction: UIFindInteraction, didBegin session: UIFindSession) {
        super.findInteraction(interaction, didBegin: session)
        textDelegate?.didStartFinding()
        isFinding = true
    }
    
    
    public override func findInteraction(_ interaction: UIFindInteraction,
                                         didEnd session: UIFindSession) {
//        interaction.dismissFindNavigator()
//        super.findInteraction(interaction, didEnd: session)
        if isFinding {
            isFinding = false
            textDelegate?.didEndFinding()
        }
    }
    
}

public  extension UITextView {
    public func cursorPosition() -> UITextPosition? {
        if let selectedRange = self.selectedTextRange {
            let offset = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
               return self.position(from: self.beginningOfDocument, offset: offset)
        }
        return nil
    }
    
    
    public func range(from textRange: UITextRange) -> NSRange {
        let location:Int = self.offset(from: self.beginningOfDocument, to: textRange.start)
        let length:Int = self.offset(from: textRange.start, to: textRange.end)
        return NSMakeRange(location, length)
    }
}


#endif


#if os(macOS)
import AppKit

public typealias OMTextView = OMNSTextView

public class OMNSTextView: NSTextView {
    var textDelegate: OMTextDelegate?
    var isFinding = false
    
    
//    public override func findInteraction(_ interaction: UIFindInteraction, didBegin session: UIFindSession) {
//        super.findInteraction(interaction, didBegin: session)
//        textDelegate?.didStartFinding()
//        isFinding = true
//    }
//    
//    
//    public override func findInteraction(_ interaction: UIFindInteraction,
//                                         didEnd session: UIFindSession) {
//        //        interaction.dismissFindNavigator()
//        //        super.findInteraction(interaction, didEnd: session)
//        if isFinding {
//            isFinding = false
//            textDelegate?.didEndFinding()
//        }
//    }
}
    
public  extension NSTextView {
 
    
 
}

#endif



