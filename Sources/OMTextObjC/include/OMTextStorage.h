//
//  Header.h
//  
//
//  Created by John Knowles on 7/29/24.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
#import <AppKit/NSTextStorage.h>
#else
#import <UIKit/NSTextStorage.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol OMTextStorageDelegate;

@interface OMTextStorage : NSTextStorage

- (instancetype)initWithStorage:(NSTextStorage *)textStorage NS_DESIGNATED_INITIALIZER;

@property (nullable, weak) id <OMTextStorageDelegate> storageDelegate;

@property (nonatomic, readonly) NSTextStorage *internalStorage;

@end

@protocol OMTextStorageDelegate <NSTextStorageDelegate>
@optional

- (void)textStorage:(OMTextStorage *)textStorage willReplaceCharactersInRange:(NSRange)range withString:(NSString *)string;
- (void)textStorage:(OMTextStorage *)textStorage didReplaceCharactersInRange:(NSRange)range withString:(NSString *)string;
- (void)textStorageWillBeginProcessingEdit:(OMTextStorage *)textStorage; // editedRange:(NSRange)range changeInLength: (NSUInteger)delta;
- (void)textStorageWillCompleteProcessingEdit:(OMTextStorage *)textStorage;
- (void)textStorageDidCompleteProcessingEdit:(OMTextStorage *)textStorage;

#if TARGET_OS_OSX
- (NSRange)textStorage:(OMTextStorage *)textStorage doubleClickRangeForLocation:(NSUInteger)location;
- (NSUInteger)textStorage:(OMTextStorage *)textStorage nextWordIndexFromLocation:(NSUInteger)location direction:(BOOL)forward;
#endif

@end

NS_ASSUME_NONNULL_END
