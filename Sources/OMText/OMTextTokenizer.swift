//
//  File.swift
//  
//
//  Created by John Knowles on 9/27/24.
//

#if os(iOS)
import UIKit

class OMTextTokenizer: UITextInputStringTokenizer {
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
#endif
