//
//  File.swift
//  
//
//  Created by John Knowles on 7/29/24.
//

import Combine
#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

import OMTextObjC




@available(iOS 16.0, *)
//@available(macOS 10.0, *)
public class OMTextManager: NSObject {
    public override init() {
        
        let storage = OMTextStorage(string: "")
        let layout = NSLayoutManager()
        storage.addLayoutManager(layout)
        let container = NSTextContainer()
        layout.addTextContainer(container)
        
        self.view = OMTextView(frame: .zero, textContainer: container)
        self.textStorage = storage
        
        super.init()
        
        view.delegate = self
                
        //        view.textStorage.removeLayoutManager(view.layoutManager)
//        textStorage.addLayoutManager(view.layoutManager)
        textStorage.storageDelegate = self
        textStorage.delegate = self
        
        changeThrottle
            .debounce(for: 0.4, scheduler: RunLoop.main)
            .sink(receiveValue: processChange)
            .store(in: &cancellables)
        
    }
    
//    public lazy var findInteraction = UIFindInteraction(sessionDelegate: self)
    public var delegate: OMTextDelegate? {
        didSet {
            view.textDelegate = delegate
        }
    }
    public var view: OMTextView
    public let state = CurrentValueSubject<OMTextState, Never>(OMTextState())
    
    let changeThrottle = PassthroughSubject<NSAttributedString, Never>()
    var cancellables = Set<AnyCancellable>()
    
    private var textStorage: OMTextStorage

    
    private func processChange(text: NSAttributedString) {
        state.value.wordCount = text.string.numberOfWords
    }
    
    
    
    public func undo() {
        
        guard let undoManager = view.undoManager else { return }
        if undoManager.canUndo {
            undoManager.undo()
        }
    }
    
    public func redo() {
        guard let undoManager =  view.undoManager else { return }
        if undoManager.canRedo {
            undoManager.redo()
        }
        
    }
    
    
    
    #if os(iOS)

    public func move(cursor: CursorMovement) {
        guard view.isFirstResponder,
             let currentPosition = view.cursorPosition() else { return }
       
       let newPosition: UITextPosition? = {
           switch cursor {
           case .down:
               let cursorRect = view.caretRect(for: currentPosition)
               var adjustedCursorPoint = CGPoint(x: cursorRect.maxX, y: cursorRect.maxY)
               return view.closestPosition(to: adjustedCursorPoint)
           case .up:
               let cursorRect = view.caretRect(for: currentPosition)
               var adjustedCursorPoint = CGPoint(x: cursorRect.maxX, y: cursorRect.minY)
               return view.closestPosition(to: adjustedCursorPoint)
           case .left:
               return view.tokenizer.position(from: currentPosition,
                                                           toBoundary: .word,
                                                           inDirection: .layout(.left))
           case .right:
               return view.tokenizer.position(from: currentPosition,
                                                           toBoundary: .word,
                                                           inDirection: .layout(.right))
           }
       }()
       
       if let newPosition,
           newPosition != currentPosition,
          let textRange = view.textRange(from: newPosition, to: newPosition) {
           view.selectedTextRange = textRange
           scrollToCursor()
       }
   }
    #endif

    #if os(macOS)
    public func move(cursor: CursorMovement) {
    }
    #endif
    
    #if os(iOS)
    private func scrollToCursor() {
        if let currentPosition = view.cursorPosition()  {
            let cursorRect = view.caretRect(for: currentPosition)
            
            view.scrollRectToVisible(cursorRect, animated: true)
        }
    }
    
    #endif

    
}


import RegexBuilder

// @available(iOS 16.0, *)
// extension OMTextManager: NSTextStorageDelegate {
//     public func textStorage(_ textStorage: NSTextStorage, 
//                             didProcessEditing editedMask: NSTextStorageEditActions,
//                             range editedRange: NSRange,
//                             changeInLength delta: Int) {
//         delegate?.processChange(textStorage, didProcessEditing: editedMask, range: editedRange, changeInLength: delta)
//     }
// }

extension OMTextManager: OMTextStorageDelegate {
    
    public func textStorageWillBeginProcessingEdit(_ textStorage: OMTextStorage) {
//        delegate?.processChange(textStorage)
    }
    
    public func textStorageDidCompleteProcessingEdit(_ textStorage: OMTextStorage) {
       delegate?.processChange(textStorage)
    }
}


//@available(iOS 16.0, *)
//extension OMTextManager: OMFindSessionDelegate, UIFindInteractionDelegate {
//   
//    public func findInteraction(_ interaction: UIFindInteraction, sessionFor view: UIView) -> UIFindSession? {
//        self.view.findInteraction(interaction, sessionFor: view)
////        OMFindSession(delegate: self)
////        UITextSearchingFindSession(searchableObject: self)
//    }
//    
//    @available(iOS 16.0, *)
//    public func findInteraction(_ interaction: UIFindInteraction, didBegin session: UIFindSession) {
//        print("START FINDING")
//        delegate?.didStartFinding()
//    }
//    
//    @available(iOS 16.0, *)
//    public func findInteraction(_ interaction: UIFindInteraction, didEnd session: UIFindSession) {
//        print("END FINDING")
//        delegate?.didEndFinding()
//    }
//}

#if os(iOS)
extension OMTextManager: UITextViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didChangeScroll(scrollView.contentOffset)
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        delegate?.didChangeSelection(textView: textView, range: textView.selectedRange, text: textView.attributedText )
    }
    

    public func textViewDidChange(_ textView: UITextView) {
        delegate?.didChangeText(textView: textView, text: textView.attributedText)
    }
   
    public func textViewDidBeginEditing(_ textView: UITextView) {
            self.delegate?.didStartEditing()
    }
    
    
    public func textViewDidEndEditing(_ textView: UITextView) {
            self.delegate?.didEndEditing(textView.attributedText)
    }
    
    public func textView(_ textView: UITextView, 
                         shouldInteractWith URL: URL,
                         in characterRange: NSRange,
                         interaction: UITextItemInteraction) -> Bool {
        
        delegate?.shouldOpenURL(URL, in: textView, range: characterRange, interaction: interaction) ?? true
        
    }

}
#endif

#if os(macOS)
extension OMTextManager: NSTextViewDelegate {
    public func textViewDidChangeSelection(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }

//        delegate?.didChangeSelection(textView: textView, range: textView.selectedRange, text: textView.attributedText )

    }
    
    public func textView(_ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int) -> Bool {
        delegate?.openLink(textView: textView, clickedOnLink: link, at: charIndex) 
        return false
    }
    public func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        delegate?.didChangeText(textView: textView)
    }
    public func textDidBeginEditing(_ notification: Notification) {
        self.delegate?.didStartEditing()
    }
    
    public func textDidEndEditing(_ notification: Notification) {
        self.delegate?.didEndEditing()
    }
}
#endif
