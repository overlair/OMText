//
//  File.swift
//  
//
//  Created by John Knowles on 9/27/24.
//


@MainActor
protocol OMFindSessionDelegate {
    
    var view: OMTextView { get }
//    func replaceCurrentSearchResult(with replacementText: String)
//    func replaceAllSearchResults(with replacementText: String)
}

#if os(iOS)
import UIKit



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




#endif

#if os(macOS)
import AppKit


//class OMFindSession: UIFindSession {
//    
//    private var delegate: OMFindSessionDelegate
//
//    init(delegate: OMFindSessionDelegate) {
//        self.delegate = delegate
//    }
//    
//    override var resultCount: Int {
//        0
////        guard let outline = delegate.outline else { return 0 }
////        return outline.searchResultCount
//    }
//    
//    override var highlightedResultIndex: Int {
//        0
////        guard let outline = delegate.outline else { return 0 }
////        return outline.currentSearchResult
//    }
//    
//    override var supportsReplacement: Bool {
//        return true
//    }
//    
//    override var allowsReplacementForCurrentlyHighlightedResult: Bool {
//        true
////        guard let outline = delegate.outline else { return false }
////        return outline.isCurrentSearchResultReplacable
//    }
//    
//    override var searchResultDisplayStyle: UIFindSession.SearchResultDisplayStyle {
//        set {}
//        get { .none } // The other two options simply don't work right now...
//    }
//    
//    override func performSearch(query: String, options: UITextSearchOptions?) {
////        var outlineSearchOptions = Outline.SearchOptions()
////
////        if options?.stringCompareOptions.contains(.caseInsensitive) ?? false {
////            outlineSearchOptions.formUnion(.caseInsensitive)
////        }
////
////        if options?.wordMatchMethod == .fullWord {
////            outlineSearchOptions.formUnion(.wholeWords)
////        }
////
////        guard let outline = delegate.outline else { return }
////        outline.search(for: query, options: outlineSearchOptions)
//    }
//    
//    override func highlightNextResult(in direction: UITextStorageDirection) {
////        guard let outline = delegate.outline else { return }
////
////        switch direction {
////        case .forward:
////            outline.nextSearchResult()
////        case .backward:
////            outline.previousSearchResult()
////        @unknown default:
////            fatalError()
////        }
//    }
//    
//    override func performSingleReplacement(query searchQuery: String, replacementString: String, options: UITextSearchOptions?) {
//        let options = UITextSearchOptions()
//        delegate.view.replaceAllOccurrences(ofQueryString: searchQuery, using: options, withText: replacementString)//        delegate.replaceCurrentSearchResult(with: replacementString)
//    }
//    
//    override func replaceAll(searchQuery: String, replacementString: String, options: UITextSearchOptions?) {
//        let options = UITextSearchOptions()
//        delegate.view.replaceAllOccurrences(ofQueryString: searchQuery, using: options, withText: replacementString)
//        
//    }
//    
//    override func invalidateFoundResults() {
////        guard let outline = delegate.outline else { return }
////        outline.search(for: "", options: [])
//    }
//    
//}




#endif
