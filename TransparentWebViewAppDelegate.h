//
//  TransparentWebViewAppDelegate.h
//  TransparentWebView
//
//  Created by Dirk van Oosterbosch on 22-12-10.
//  Copyright 2010 IR labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebView.h>
#import <WebKit/WebFrame.h>

@class PreferenceController;

extern NSString *const TWVBorderlessWindowKey;
extern NSString *const TWVDrawCroppedUnderTitleBarKey;
extern NSString *const TWVMainTransparantWindowFrameKey;

#if (MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5)
@interface TransparentWebViewAppDelegate : NSObject {
#else
@interface TransparentWebViewAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, PNDelegate> {
#endif
    NSWindow *window;
	
	NSMenuItem *__weak borderlessWindowMenuItem;

    NSWindow *__weak usernameSheet;
    NSWindow *__weak followSheet;

	//NSString *urlString;
	NSString *usernameString;
    NSString *followString;
    
	PreferenceController *preferenceController;
    NSRect screenRect;
    
    
    float followX ,followY;

}

    
@property (strong) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSMenuItem *borderlessWindowMenuItem;
@property (weak) IBOutlet NSMenuItem *cropUnderTitleBarMenuItem;

@property (weak) IBOutlet NSWindow *usernameSheet;
@property (weak) IBOutlet NSWindow *followSheet;

//@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *usernameString;
@property (nonatomic, strong) NSString *followString;

//@property (nonatomic, strong) PreferenceController *preferenceController;

- (IBAction)showUsernameSheet:(id)sender;
- (IBAction)endUsernameSheet:(id)sender;
- (IBAction)cancelUsernameSheet:(id)sender;
    
- (IBAction)showFollowSheet:(id)sender;
- (IBAction)endFollowSheet:(id)sender;
- (IBAction)cancelFollowSheet:(id)sender;

//- (IBAction)showPreferencePanel:(id)sender;
//- (void)setBorderlessWindowMenuItemState:(BOOL)booleanState;
- (void)setCropUnderTitleBarMenuItemState:(BOOL)booleanState;
- (void)replaceWindowWithBorderlessWindow:(BOOL)borderlessFlag WithContentRect:(NSRect)contentRect;
//- (void)cropContentUnderTitleBar:(BOOL)cropUnderTitleFlag;

@end
