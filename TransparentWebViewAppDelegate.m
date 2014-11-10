//
//  TransparentWebViewAppDelegate.m
//  TransparentWebView
//
//  Created by Dirk van Oosterbosch on 22-12-10.
//  Copyright 2010 IR labs. All rights reserved.
//

#import "TransparentWebViewAppDelegate.h"
#import "WebViewWindow.h"
#import "PreferenceController.h"

NSString *const TWVLocationUrlKey = @"WebViewLocationUrl";
NSString *const TWVBorderlessWindowKey = @"OpenBorderlessWindow";
NSString *const TWVDrawCroppedUnderTitleBarKey = @"DrawCroppedUnderTitleBar";
NSString *const TWVMainTransparantWindowFrameKey = @"MainTransparentWindow";

NSString *const usernameKey = @"username";
NSString *const followKey = @"follow";


CGFloat const titleBarHeight = 22.0f;

@implementation TransparentWebViewAppDelegate

@synthesize window;//, theWebView;
@synthesize borderlessWindowMenuItem, cropUnderTitleBarMenuItem;
//@synthesize locationSheet, urlString;
@synthesize usernameSheet, usernameString;
@synthesize followSheet, followString;

@synthesize preferenceController;


- (id) init {
	if (!(self = [super init])) return nil;
	
	// Register the Defaults in the Preferences
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	

	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TWVBorderlessWindowKey];
	[defaultValues setObject:[NSNumber numberWithBool:YES] forKey:TWVDrawCroppedUnderTitleBarKey];
	[defaultValues setObject:[NSNumber numberWithBool:NO] forKey:TWVShouldAutomaticReloadKey];
	[defaultValues setObject:[NSNumber numberWithInt:15] forKey:TWVAutomaticReloadIntervalKey];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	
	// Set the url from the Preferences file
	//self.urlString = [[NSUserDefaults standardUserDefaults] objectForKey:TWVLocationUrlKey];
    self.usernameString = [[NSUserDefaults standardUserDefaults] objectForKey:usernameKey];
    self.followString = [[NSUserDefaults standardUserDefaults] objectForKey:followKey];

	// Register for Preference Changes
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleAutomaticReloadChange:)
												 name:TWVAutomaticReloadChangedNotification
											   object:nil];
	
    // Setup PubNub
    [self initPubNub];
    
    // Broadcast my mouse position
    [NSTimer scheduledTimerWithTimeInterval:.2
                                     target:self
                                   selector:@selector(broadcastMouse)
                                   userInfo:nil
                                    repeats:YES];
    
    // Update mouse position received
    [NSTimer scheduledTimerWithTimeInterval:.2
                                     target:self
                                   selector:@selector(moveMouse)
                                   userInfo:nil
                                    repeats:YES];
    



    [self subscribePubNub];
    
	return self;
}

-(void)initPubNub{
    
    NSString *origin = @"pubsub.pubnub.com";
    NSString *publishKey = @"pub-c-022feac7-95c3-46e1-a272-28074a6a94ce";
    NSString *subscribeKey = @"sub-c-d560da0c-669b-11e4-984a-02ee2ddab7fe";
    NSString *secretKey = @"sec-c-ZWJmZmI0NzAtNTU2My00Mjg3LTgyZTgtZmMzNDdjZjhlZjI1";
    NSString *authorizationKey = @"";

    [PubNub setDelegate: self];
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin: origin publishKey: publishKey subscribeKey: subscribeKey secretKey: secretKey authorizationKey: authorizationKey];
    [PubNub setConfiguration: configuration];
    
    [PubNub connect];
}
-(void)subscribePubNub{
    //Define a channel
    PNChannel *channel = [PNChannel channelWithName:self.followString shouldObservePresence:YES];
    [PubNub subscribeOnChannel:channel];
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    followX=[[message.message objectForKey:@"x"]floatValue];
    followY=[[message.message objectForKey:@"y"]floatValue];
    NSLog(@"received x %f, y %f",followX,followY);
}

-(void)moveMouse{
    NSRect frame = [window frame];
    frame.origin.x=followX*screenRect.size.width;
    frame.origin.y=followY*screenRect.size.height;
    [window setFrame:frame display:YES animate:YES];
}

-(void)broadcastMouse{
    
    // log data
    //NSLog(@"%@ x %f, y %f",[self usernameString], [NSEvent mouseLocation].x, [NSEvent mouseLocation].y);
    
    // Normalize mouse position
    CGFloat x = [NSEvent mouseLocation].x / screenRect.size.width;
    CGFloat y = [NSEvent mouseLocation].y / screenRect.size.height;
    
    // Send mouse position w/ pubnub (published under chosen username?
    NSLog(@"sending x %f, y %f", x, y);
    
    NSString *xs = [NSString stringWithFormat:@"%f", x];
    NSString *ys = [NSString stringWithFormat:@"%f", y];
    
    //Publish on the channel
    TransparentWebViewAppDelegate *weakSelf = self;
    [PubNub sendMessage:@{@"x":xs, @"y":ys}
              toChannel:[PNChannel channelWithName:[self usernameString]]
    withCompletionBlock:^(PNMessageState sendingSate, id data) {
        
        switch (sendingSate) {
            case PNMessageSending:
                
                PNLog(PNLogGeneralLevel, weakSelf, @"Sending message: %@", data);
                break;
            case PNMessageSent:
                
                PNLog(PNLogGeneralLevel, weakSelf, @"Message sent: %@", data);
                break;
            case PNMessageSendingError:
                
                PNLog(PNLogGeneralLevel, weakSelf, @"Message sending error: %@", data);
                break;
        }
    }];
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
	NSLog(@"TransparentWebView app got launched ...");
	//[self loadUrlString:self.urlString IntoWebView:self.theWebView];

    // PubNub init
    [PubNub setDelegate:self];
    
	// Deal with the borderless and crop under title bar settings
	BOOL borderlessState = [[[NSUserDefaults standardUserDefaults] objectForKey:TWVBorderlessWindowKey] boolValue];
	BOOL cropUnderTitleState = [[[NSUserDefaults standardUserDefaults] objectForKey:TWVDrawCroppedUnderTitleBarKey] boolValue];
	
	// Set the state of the menu items
	[self setBorderlessWindowMenuItemState:borderlessState];
	[self setCropUnderTitleBarMenuItemState:cropUnderTitleState];
	
	// Make us the delegate of the Main Window
	[window setDelegate:self];
	
	// Set the window type and the content frame
	if (borderlessState) {
		//NSRect borderlessContentRect = [[window contentView] frame];
        NSRect borderlessContentRect = CGRectMake(100, 100, 40, 40);

		if (cropUnderTitleState) {
			borderlessContentRect = [window frame];
		}
		[self replaceWindowWithBorderlessWindow:YES WithContentRect:borderlessContentRect];
	} else {
		if (cropUnderTitleState) {
			[self cropContentUnderTitleBar:YES];
		}
	}
	
	// Start a timer if the Transparent Web View is set to reload with a given interval
	//[self resetAutomaticReloadTimer];
    
    NSArray *screenArray = [NSScreen screens];
    unsigned screenCount = [screenArray count];
    
    for (int index; index < screenCount; index++)
    {
        NSScreen *screen = [screenArray objectAtIndex: index];
        screenRect = [screen visibleFrame];
    }
    


    NSLog(@"width %f",screenRect.size.width);
    
    
    //inital position
    followX=.2;
    followY=.3;
    [self moveMouse];
    
    
}

#pragma mark -
#pragma mark prefs Sheet

- (IBAction)showUsernameSheet:(id)sender {
    [NSApp beginSheet:usernameSheet
       modalForWindow:window
        modalDelegate:nil
       didEndSelector:NULL
          contextInfo:NULL];
}
- (IBAction)endUsernameSheet:(id)sender {
    [NSApp endSheet:usernameSheet];
    [usernameSheet orderOut:sender];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.usernameString forKey:usernameKey];
}

- (IBAction)cancelUsernameSheet:(id)sender {
    [NSApp endSheet:usernameSheet];
    [usernameSheet orderOut:sender];
}

- (IBAction)showFollowSheet:(id)sender {
    [NSApp beginSheet:followSheet
       modalForWindow:window
        modalDelegate:nil
       didEndSelector:NULL
          contextInfo:NULL];
}
- (IBAction)endFollowSheet:(id)sender {
    [NSApp endSheet:followSheet];
    [followSheet orderOut:sender];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.followString forKey:followKey];
}

- (IBAction)cancelFollowSheet:(id)sender {
    [NSApp endSheet:followSheet];
    [followSheet orderOut:sender];
}





#pragma mark -
#pragma mark Preferences Panel

- (IBAction)showPreferencePanel:(id)sender {
	// Lazy loading
	if (self.preferenceController == nil) {
		PreferenceController *prefController = [[PreferenceController alloc] init];
		self.preferenceController = prefController;
	}
	NSLog(@"showing %@", preferenceController);
	[preferenceController showWindow:self];
}



- (void)setCropUnderTitleBarMenuItemState:(BOOL)booleanState {
	
	if (booleanState) {
		// YES CropUnderTitleBar
		[cropUnderTitleBarMenuItem setState:NSOnState];
	} else {
		// NO CropUnderTitleBar
		[cropUnderTitleBarMenuItem setState:NSOffState];
	}
}


#pragma mark -
#pragma mark NSWindow Delegate Methods

- (void)windowDidResize:(NSNotification *)notification {
	// Save the frame (since it wasn't working out of the box on our own created windows)
	[window saveFrameUsingName:TWVMainTransparantWindowFrameKey];

}

- (void)windowDidMove:(NSNotification *)notification {
	// Save the frame (since it wasn't working out of the box on our own created windows)
	[window saveFrameUsingName:TWVMainTransparantWindowFrameKey];
}

#pragma mark -

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
