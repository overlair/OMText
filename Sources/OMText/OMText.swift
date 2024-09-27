// The Swift Programming Language
// https://docs.swift.org/swift-book



import Foundation
import SwiftUI
import OMTextObjC
//import STTextView


/*
 - https://github.com/ChimeHQ/TextStory/tree/main
 
 
 
 */
/*
 Audio
 Photos
 Camera
 Video
 Text
    undo
    redo
    attributes
    cursor
    delegate
 
 URL
 Paint
 Sync
 Scroll
 Present
 
 */



#if os(iOS)
typealias OMColor = UIColor
#endif

#if os(macOS)
import AppKit
typealias OMColor = NSColor
#endif



public enum CursorMovement {
    case left
    case right
    case up
    case down
}



import Combine

public struct OMTextState: Equatable {
    public init(isEditing: Bool = false) {
        self.isEditing = isEditing
    }
    
    public var isEditing = false
    public var isFinding = false
    public var canRedo = false
    public var canUndo = false
    public var canMoveLeft = false
    public var canMoveUp = false
    public var canMoveDown = false
    public var canMoveRight = false
    public var wordCount = 0
}




#if os(iOS)


//extension OMTextView: UITextViewDelegate {
//    public func textViewDidChangeSelection(_ textView: UITextView) {
//        omDelegate?.didChangeSelection(textView.selectedRange, text: textView.attributedText )
//    }
//    public func textViewDidChange(_ textView: UITextView) {
//        omDelegate?.didChange(textView.attributedText)
//    }
//    
//    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let shouldChange = omDelegate?.shouldChange(textView, shouldChangeTextIn: range, replacementText: text) ?? true
//        
//        if text.isEmpty {
//            print("delete", range, text)
//        } else {
//            if text == "\n" {
//                print("RETURN")
////                textView.typingAttributes = .typingAttributes
//            }
//            print("insert", range, text)
//        }
//        
//        
//        if let changePosition =  textView.position(from: textView.beginningOfDocument, offset: range.location) {
//            let caretRect = textView.caretRect(for: changePosition)
//            if caretRect.minY < textView.contentOffset.y || caretRect.minY > textView.contentOffset.y + textView.visibleSize.height {
//                
//                textView.scrollRangeToVisible(range)
//            }
//        }
//        
//        return shouldChange
//    }
//    
//    public func textViewDidBeginEditing(_ textView: UITextView) {
//        print("START TEXT VIEW")
//        omDelegate?.didStartEditing()
//    }
//    
//    public func textViewDidEndEditing(_ textView: UITextView) {
//        print("END TEXT VIEW")
//        omDelegate?.didEndEditing(textView.attributedText)
//    }    
//    
//    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
//        
//        print(characterRange)
//        omDelegate?.didTapLink(in: characterRange)
//        return true
//    }
//}
             
//public class OMUITextView: UITextView {
//    public var omDelegate: OMTextDelegate?
//  
//    
//    
//    private lazy var internalTokenizer = OMTextTokenizer(textInput:  self)
//    
////    public override var tokenizer: UITextInputTokenizer {
////            get {
////                return internalTokenizer
////            }
////        }
////    
//    
//    public func undo() {
//        
//        guard let undoManager else { return }
//        if undoManager.canUndo {
//            undoManager.undo()
//        }
//    }
//    
//    public func redo() {
//        guard let undoManager else { return }
//        if undoManager.canRedo {
//            undoManager.redo()
//        }
//        
//    }
//    
//    public func move(cursor: CursorMovement) {
//       guard isFirstResponder,
//             let currentPosition = cursorPosition() else { return }
//       
//       let newPosition: UITextPosition? = {
//           switch cursor {
//           case .down:
//               let cursorRect = caretRect(for: currentPosition)
//               var adjustedCursorPoint = CGPoint(x: cursorRect.maxX, y: cursorRect.maxY)
//               return closestPosition(to: adjustedCursorPoint)
//           case .up:
//               let cursorRect = caretRect(for: currentPosition)
//               var adjustedCursorPoint = CGPoint(x: cursorRect.maxX, y: cursorRect.minY)
//               return closestPosition(to: adjustedCursorPoint)
//           case .left:
//               return tokenizer.position(from: currentPosition,
//                                                           toBoundary: .word,
//                                                           inDirection: .layout(.left))
//           case .right:
//               return tokenizer.position(from: currentPosition,
//                                                           toBoundary: .word,
//                                                           inDirection: .layout(.right))
//           }
//       }()
//       
//       if let newPosition,
//           newPosition != currentPosition,
//           let textRange = textRange(from: newPosition, to: newPosition) {
//           selectedTextRange = textRange
//           scrollToCursor()
//       }
//   }
//
//    
//    
//    private func scrollToCursor() {
//        if let currentPosition = cursorPosition()  {
//            let cursorRect = caretRect(for: currentPosition)
//            
//            scrollRectToVisible(cursorRect, animated: true)
//        }
//    }
//    
//    
//    
//    public func addText(_ text: String) {
//        insertText(text)
//
////        if let currentPosition = cursorPosition()  {
////            insertText(text)
////        }
//    }
//    
//    
//}


#endif


#if os(macOS)
//class OMTextView: NSTex
#endif


extension [NSAttributedString.Key: Any] {
    
    var typing:  [String: Any] {
        var temp: [String: Any] = [:]
        for key in self.keys {
            temp[key.rawValue] = self[key]
        }
        return temp
    }
    
    static let page: [NSAttributedString.Key: Any] = {
        var attributes: [NSAttributedString.Key: Any] = [:]
//        attributes[.foregroundColor] = OMColor.label
//        attributes[.font] = UIFont.systemFont(ofSize: 20, weight: .regular)
        return attributes
    }()
}

extension [String: Any] {
    
    var stored:  [NSAttributedString.Key: Any] {
        var temp: [NSAttributedString.Key: Any] = [:]
        for key in self.keys {
            temp[NSAttributedString.Key(key)] = self[key]
        }
        return temp
    }
}



extension [NSAttributedString.DocumentAttributeKey : Any] {
   static let rtfAttributes: [NSAttributedString.DocumentAttributeKey : Any] =
        [.documentType: NSAttributedString.DocumentType.rtf]
}

extension NSAttributedString {
    func richTextData() throws ->  Data {
        let textDataRange: NSRange = .init(location: 0, length: self.length)
        return try self.data(from: textDataRange,
              documentAttributes: .rtfAttributes)
    }
    
}





#if os(iOS)
public struct OMTextViewRepresentable: UIViewRepresentable {
    public init(view: OMTextView) {
        self.view = view
    }

    let view: OMTextView

    public func makeUIView(context: Context) -> some UIView {
        view
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {}
}
#endif


#if os(macOS)
//public struct OMTextViewRepresentable: NSViewRepresentable {
//    public init(view: OMTextView) {
//        self.view = view
//    }
//
//    let view: OMTextView
//
//    public func makeUIView(context: Context) -> some UIView {
//        view
//    }
//    
//    public func updateUIView(_ uiView: UIViewType, context: Context) {}
//}
#endif




