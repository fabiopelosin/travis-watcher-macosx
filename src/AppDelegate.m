//
//  AppDelegate.m
//  Travis Toolbar
//
//  Created by Henrik Hodne on 5/16/12.
//  Copyright (c) 2012 Travis CI GmbH. All rights reserved.
//

#import "AppDelegate.h"

#import "TravisEventFetcher.h"
#import "TravisEvent.h"
#import "Preferences.h"
#import "Notification.h"
#import "NotificationDisplayer.h"

@interface AppDelegate () <TravisEventFetcherDelegate>

@property (strong) TravisEventFetcher *eventFetcher;
@property (strong) NSStatusItem *statusItem;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  [self setupGrowl];

  self.eventFetcher = [[TravisEventFetcher alloc] init];
  self.eventFetcher.delegate = self;

  [self setupStatusBarItem];
}

- (void)setupGrowl {
  NSBundle *mainBundle = [NSBundle mainBundle];
  NSString *path = [[mainBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl"];
  if (NSAppKitVersionNumber >= 1038)
    path = [path stringByAppendingPathComponent:@"1.3"];
  else
    path = [path stringByAppendingPathComponent:@"1.2.3"];

  path = [path stringByAppendingPathComponent:@"Growl.framework"];
  NSBundle *growlFramework = [NSBundle bundleWithPath:path];
  [growlFramework load];
}

- (void)setupStatusBarItem {
  self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];

  self.statusItem.image = [[NSImage alloc] initByReferencingFile:[NSBundle.mainBundle pathForImageResource:@"tray.png"]];
  self.statusItem.alternateImage = [[NSImage alloc] initByReferencingFile:[NSBundle.mainBundle pathForImageResource:@"tray-alt.png"]];

  self.statusItem.menu = self.statusMenu;
  self.statusItem.toolTip = @"Travis Toolbar";
  self.statusItem.highlightMode = YES;
}

- (IBAction)showPreferences:(id)sender {
  [NSApp activateIgnoringOtherApps:YES];
  [self.preferencesPanel makeKeyAndOrderFront:self];
}

- (BOOL)shouldShowNotificationFor:(TravisEvent *)eventData {
  NSArray *repositories = Preferences.sharedPreferences.repositories;
  return Preferences.sharedPreferences.firehoseEnabled || [repositories containsObject:eventData.name];
}

#pragma mark - TravisEventFetcherDelegate

- (void)eventFetcher:(TravisEventFetcher *)eventFetcher gotEvent:(TravisEvent *)event {
  if ([self shouldShowNotificationFor:event]) {
    Notification *notification = [Notification notificationWithEventData:event];
    NSLog(@"Got notification: %@", notification);
    [NotificationDisplayer.sharedNotificationDisplayer deliverNotification:notification];
  }
}

@end
