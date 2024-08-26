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


#if os(iOS)
public protocol OMTextDelegate: UITextViewDelegate {
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





@MainActor
protocol OMFindSessionDelegate {
    var view: UITextView { get }
//    func replaceCurrentSearchResult(with replacementText: String)
//    func replaceAllSearchResults(with replacementText: String)
}

@available(iOS 16.0, *)
class OMFindSession: UIFindSession {
    
    private var delegate: OMFindSessionDelegate

    init(delegate: OMFindSessionDelegate) {
        self.delegate = delegate
    }
    
    override var resultCount: Int {
        0
//        guard let outline = delegate.outline else { return 0 }
//        return outline.searchResultCount
    }
    
    override var highlightedResultIndex: Int {
        0
//        guard let outline = delegate.outline else { return 0 }
//        return outline.currentSearchResult
    }
    
    override var supportsReplacement: Bool {
        return true
    }
    
    override var allowsReplacementForCurrentlyHighlightedResult: Bool {
        true
//        guard let outline = delegate.outline else { return false }
//        return outline.isCurrentSearchResultReplacable
    }
    
    override var searchResultDisplayStyle: UIFindSession.SearchResultDisplayStyle {
        set {}
        get { .none } // The other two options simply don't work right now...
    }
    
    override func performSearch(query: String, options: UITextSearchOptions?) {
//        var outlineSearchOptions = Outline.SearchOptions()
//        
//        if options?.stringCompareOptions.contains(.caseInsensitive) ?? false {
//            outlineSearchOptions.formUnion(.caseInsensitive)
//        }
//        
//        if options?.wordMatchMethod == .fullWord {
//            outlineSearchOptions.formUnion(.wholeWords)
//        }
//        
//        guard let outline = delegate.outline else { return }
//        outline.search(for: query, options: outlineSearchOptions)
    }
    
    override func highlightNextResult(in direction: UITextStorageDirection) {
//        guard let outline = delegate.outline else { return }
//
//        switch direction {
//        case .forward:
//            outline.nextSearchResult()
//        case .backward:
//            outline.previousSearchResult()
//        @unknown default:
//            fatalError()
//        }
    }
    
    override func performSingleReplacement(query searchQuery: String, replacementString: String, options: UITextSearchOptions?) {
        let options = UITextSearchOptions()
        delegate.view.replaceAllOccurrences(ofQueryString: searchQuery, using: options, withText: replacementString)//        delegate.replaceCurrentSearchResult(with: replacementString)
    }
    
    override func replaceAll(searchQuery: String, replacementString: String, options: UITextSearchOptions?) {
        let options = UITextSearchOptions()
        delegate.view.replaceAllOccurrences(ofQueryString: searchQuery, using: options, withText: replacementString)
        
    }
    
    override func invalidateFoundResults() {
//        guard let outline = delegate.outline else { return }
//        outline.search(for: "", options: [])
    }
    
}







extension OMTextView: UITextViewDelegate {
    public func textViewDidChangeSelection(_ textView: UITextView) {
        omDelegate?.didChangeSelection(textView.selectedRange, text: textView.attributedText )
    }
    public func textViewDidChange(_ textView: UITextView) {
        omDelegate?.didChange(textView.attributedText)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let shouldChange = omDelegate?.shouldChange(textView, shouldChangeTextIn: range, replacementText: text) ?? true
        
        if text.isEmpty {
            print("delete", range, text)
        } else {
            if text == "\n" {
                print("RETURN")
//                textView.typingAttributes = .typingAttributes
            }
            print("insert", range, text)
        }
        
        
        if let changePosition =  textView.position(from: textView.beginningOfDocument, offset: range.location) {
            let caretRect = textView.caretRect(for: changePosition)
            if caretRect.minY < textView.contentOffset.y || caretRect.minY > textView.contentOffset.y + textView.visibleSize.height {
                
                textView.scrollRangeToVisible(range)
            }
        }
        
        return shouldChange
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        print("START TEXT VIEW")
        omDelegate?.didStartEditing()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        print("END TEXT VIEW")
        omDelegate?.didEndEditing(textView.attributedText)
    }    
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        print(characterRange)
        omDelegate?.didTapLink(in: characterRange)
        return true
    }
}
             
public class OMTextView: UITextView {
    public var omDelegate: OMTextDelegate?
  
    
    
    private lazy var internalTokenizer = MyUITextInputStringTokenizer(textInput:  self)
    
//    public override var tokenizer: UITextInputTokenizer {
//            get {
//                return internalTokenizer
//            }
//        }
//    
    
    public func undo() {
        
        guard let undoManager else { return }
        if undoManager.canUndo {
            undoManager.undo()
        }
    }
    
    public func redo() {
        guard let undoManager else { return }
        if undoManager.canRedo {
            undoManager.redo()
        }
        
    }
    
    public func move(cursor: CursorMovement) {
       guard isFirstResponder,
             let currentPosition = cursorPosition() else { return }
       
       let newPosition: UITextPosition? = {
           switch cursor {
           case .down:
               let cursorRect = caretRect(for: currentPosition)
               var adjustedCursorPoint = CGPoint(x: cursorRect.maxX, y: cursorRect.maxY)
               return closestPosition(to: adjustedCursorPoint)
           case .up:
               let cursorRect = caretRect(for: currentPosition)
               var adjustedCursorPoint = CGPoint(x: cursorRect.maxX, y: cursorRect.minY)
               return closestPosition(to: adjustedCursorPoint)
           case .left:
               return tokenizer.position(from: currentPosition,
                                                           toBoundary: .word,
                                                           inDirection: .layout(.left))
           case .right:
               return tokenizer.position(from: currentPosition,
                                                           toBoundary: .word,
                                                           inDirection: .layout(.right))
           }
       }()
       
       if let newPosition,
           newPosition != currentPosition,
           let textRange = textRange(from: newPosition, to: newPosition) {
           selectedTextRange = textRange
           scrollToCursor()
       }
   }

    
    
    private func scrollToCursor() {
        if let currentPosition = cursorPosition()  {
            let cursorRect = caretRect(for: currentPosition)
            
            scrollRectToVisible(cursorRect, animated: true)
        }
    }
    
    
    
    public func addText(_ text: String) {
        insertText(text)

//        if let currentPosition = cursorPosition()  {
//            insertText(text)
//        }
    }
    
    
}

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

#if os(iOS)

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


public extension NSAttributedString {
    public func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width,
                                    height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect,
                                       options: .usesLineFragmentOrigin,
                                       context: nil)
        
        return ceil(boundingBox.height)
    }
    
    public func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude,
                                    height: height)
        let boundingBox = boundingRect(with: constraintRect,
                                       options: .usesLineFragmentOrigin,
                                       context: nil)
        
        return ceil(boundingBox.width)
    }
}




extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

#if os(iOS)
extension String {
    
    /// Generates a `UIImage` instance from this string using a specified
    /// attributes and size.
    ///
    /// - Parameters:
    ///     - attributes: to draw this string with. Default is `nil`.
    ///     - size: of the image to return.
    /// - Returns: a `UIImage` instance from this string using a specified
    /// attributes and size, or `nil` if the operation fails.
    ///
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil,
               size: CGSize? = nil) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(in: CGRect(origin: .zero, size: size),
                                    withAttributes: attributes)
        }
    }
    
}
#endif

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
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




extension String {
//    func regex(pattern: String) -> [String] {
//        
//        guard !pattern.isEmpty,
//              let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
//        else { return [] }
//        
//        return regex
//                .matches(in: self, options: [], range: NSRange(location: 0, length: count))
////                .map {  String(self.) }
//        
//    }
}

public extension String {
    public var numberOfWords: Int {
        var count = 0
        let range = startIndex..<endIndex
        enumerateSubstrings(in: range, options: [.byWords, .substringNotRequired, .localized], { _, _, _, _ -> () in
            count += 1
        })
        return count
    }
    
    public var firstLineRange: NSRange? {    
        let nsText = self as NSString
        let range = nsText.paragraphRange(for: .init(location: 0, length: 0))
        return range

    }
    
    public func prefixedString(prefix: Character, at index: Int) -> NSRange? {
        let string = self as NSString
        
        let textLength = string.length
        let preRange = 0...index
        let postRange = index..<textLength


        var foundPrefix = false
        var preIndex: Int? = nil
        var postIndex: Int? = nil
        var range: NSRange? = nil

        for i in preRange {
            let idx = index - i
            print(idx, textLength)
            guard idx >= 0 && idx < textLength else { continue }
            preIndex = idx
            let u16char =  string.character(at: idx)
            if let scalar = UnicodeScalar(u16char) {
                let character = Character(scalar)
                if i > 0, character.isWhitespace {
                    break
                } else if character == prefix {
                    foundPrefix = true
                    break
                }
            }
        }
        
        if foundPrefix {
            for idx in postRange {
                guard idx >= 0 && idx < textLength else { continue }
                postIndex = idx
                let u16char =  string.character(at: idx)
                if let scalar = UnicodeScalar(u16char) {
                    let character = Character(scalar)
                    if idx > 0, character.isWhitespace {
                        break
                    } else if character.isPunctuation {
                        if character == "#" {
                            break
                        }
                    }
                }
            }
        }
        if let preIndex, let postIndex {
            range = .init(location: preIndex, length: postIndex - preIndex)
        }
        
        return range
    }
}
class MyUITextInputStringTokenizer: UITextInputStringTokenizer {
    weak var textInput: (UIResponder & UITextInput)? = nil

    override init(textInput: UIResponder & UITextInput) {
        self.textInput = textInput
        super.init(textInput: textInput)
    }


    // MARK: required methods to override
        override func isPosition(_ position: UITextPosition, atBoundary granularity: UITextGranularity, inDirection direction: UITextDirection) -> Bool {
        guard let textInput = textInput else {
            return false
        }
        if granularity == .word {
            guard let start = textInput.position(from: position, offset: -1) else {
                // position is at the beginning of the document
                guard let end = textInput.position(from: position, offset: 1) else {
                    // the document is empty
                    return false
                }
                guard let range = textInput.textRange(from: position, to: end) else {
                    return false
                }
                guard let text = textInput.text(in: range) else {
                    return false
                }
                if direction == .storage(.forward) || direction == .layout(.right) {
                    return false
                } else {
                    return !self.charIsWhitespace(text[text.startIndex])
                }
            }
            guard let end = textInput.position(from: position, offset: 1) else {
                // position is at the end of a nonempty document
                guard let range = textInput.textRange(from: start, to: position) else {
                    return false
                }
                guard let text = textInput.text(in: range) else {
                    return false
                }
                if direction == .storage(.forward) || direction == .layout(.right) {
                    return !self.charIsWhitespace(text[text.startIndex])
                } else {
                    return false
                }
            }
            guard let range = textInput.textRange(from: start, to: end) else {
                return false
            }
            guard let text = textInput.text(in: range) else {
                return false
            }
            if direction == .storage(.forward) || direction == .layout(.right) {
                return !self.charIsWhitespace(text[text.startIndex]) && self.charIsWhitespace(text[text.index(before: text.endIndex)])
            } else {
                return self.charIsWhitespace(text[text.startIndex]) && !self.charIsWhitespace(text[text.index(before: text.endIndex)])
            }
        } else {
            return super.isPosition(position, atBoundary: granularity, inDirection: direction)
        }
    }

    override func isPosition(_ position: UITextPosition, withinTextUnit granularity: UITextGranularity, inDirection direction: UITextDirection) -> Bool {
        guard let textInput = textInput else {
            return false
        }
        if granularity == .word {
            var offset = 1
            if direction == .storage(.backward) || direction == .layout(.left) {
                offset = -1
            }
            let start = position
            guard let end = textInput.position(from: position, offset: offset) else {
                return false
            }
            guard let range = textInput.textRange(from: start , to: end) else {
                return false
            }
            guard let text = textInput.text(in: range) else {
                return false
            }
            return !self.charIsWhitespace(text[text.startIndex])
        } else {
            return super.isPosition(position, withinTextUnit: granularity, inDirection: direction)
        }
    }

    override func position(from position: UITextPosition, toBoundary granularity: UITextGranularity, inDirection direction: UITextDirection) -> UITextPosition? {
        guard let textInput = textInput else {
            return nil
        }
        if granularity == .word {
            var offset = 1
            if direction == .storage(.backward) || direction == .layout(.left) {
                offset = -1
            }

            var pos = position
            while let newPos = textInput.position(from: pos, offset: offset) {
                pos = newPos
                if self.isPosition(newPos, atBoundary: .word, inDirection: .storage(.forward)) || self.isPosition(newPos, atBoundary: .word, inDirection: .storage(.backward)) {
                    break
                }
            }
            return pos
        } else {
            return super.position(from: position, toBoundary: granularity, inDirection: direction)
        }
    }

    override func rangeEnclosingPosition(_ position: UITextPosition, with granularity: UITextGranularity, inDirection direction: UITextDirection) -> UITextRange? {
        guard let textInput = textInput else {
            return nil
        }
        if granularity == .word {
            let start = self.find(textInput: textInput, position: position, direction: .backward, condition: self.charIsWhitespace)
            let end = self.find(textInput: textInput, position: position, direction: .forward, condition: self.charIsWhitespace)
            if textInput.compare(start, to: end) == .orderedSame {
                return nil
            }
            return textInput.textRange(from: start, to: end)
        } else {
            return super.rangeEnclosingPosition(position, with: granularity, inDirection: direction)
        }
    }

    // MARK: - Helper methods
    func find(textInput: UITextInput, position: UITextPosition, direction: UITextStorageDirection, condition: (Character) -> Bool) -> UITextPosition {
        let offset = direction == .forward ? 1 : -1
        var pos = position
        while let newPos = textInput.position(from: pos, offset: offset) {
            guard let range = textInput.textRange(from: pos, to: newPos) else {
                break
            }
            guard let text = textInput.text(in: range) else {
                break
            }
            if condition(text[text.startIndex]) {
                break
            }
            pos = newPos
        }
        return pos
    }

    func charIsWhitespace(_ ch: Character) -> Bool {
        return ch == " "
    }
    
    
}



//
//
//public class OMTextView2: STTextView {
//    
//    
//    
//    public func undo() {
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
//    }
//    
////    public func move(cursor: CursorMovement) {
////        
////       guard isFirstResponder,
////             let currentPosition = cursorPosition() else { return }
////       
////       let newPosition: UITextPosition? = {
////           switch cursor {
////           case .down:
////               let cursorRect = caretRect(for: currentPosition)
////               var adjustedCursorPoint = CGPoint(x: cursorRect.maxX, y: cursorRect.maxY)
////               return closestPosition(to: adjustedCursorPoint)
////           case .up:
////               let cursorRect = caretRect(for: currentPosition)
////               var adjustedCursorPoint = CGPoint(x: cursorRect.maxX, y: cursorRect.minY)
////               return closestPosition(to: adjustedCursorPoint)
////           case .left:
////               return tokenizer.position(from: currentPosition,
////                                                           toBoundary: .word,
////                                                           inDirection: .layout(.left))
////           case .right:
////               return tokenizer.position(from: currentPosition,
////                                                           toBoundary: .word,
////                                                           inDirection: .layout(.right))
////           }
////       }()
////       
////       if let newPosition,
////           newPosition != currentPosition,
////           let textRange = textRange(from: newPosition, to: newPosition) {
////           selectedTextRange = textRange
////           scrollToCursor()
////       }
////   }
////
////    
////    
////    private func scrollToCursor() {
////        if let currentPosition = cursorPosition()  {
////            let cursorRect = caretRect(for: currentPosition)
////            
////            scrollRectToVisible(cursorRect, animated: true)
////        }
////    }
////    
////    public func cursorPosition() -> UITextPosition? {
////        if let selectedRange = self.selectedTextRange {
////            let offset = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
////               return self.position(from: self.beginningOfDocument, offset: offset)
////        }
////        return nil
////    }
////    
////    
////    public func range(from textRange: UITextRange) -> NSRange {
////        let location:Int = self.offset(from: self.beginningOfDocument, to: textRange.start)
////        let length:Int = self.offset(from: textRange.start, to: textRange.end)
////        return NSMakeRange(location, length)
////    }
//}
