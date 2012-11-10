//
//  PreferencesController.m
//  Travis Toolbar
//
//  Created by Henrik Hodne on 5/18/12.
//  Copyright (c) 2012 Travis CI GmbH. All rights reserved.
//

#import "Preferences.h"

#import "PreferencesController.h"

@implementation PreferencesController

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
  NSTextField *textField = (NSTextField *)alert.accessoryView;

  [Preferences.sharedPreferences addRepository:textField.stringValue];
  [self.reposTableView reloadData];
}

#pragma mark - Actions

- (IBAction)addRepository:(NSButton *)sender {
  NSAlert *alert = [NSAlert alertWithMessageText:@"Add repository" defaultButton:@"Add" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"Enter the name of the repository you want to add (for example, \"travis-ci/travis-ci\")"];
  NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 15)];
  alert.accessoryView = textField;
  [alert beginSheetModalForWindow:sender.window modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)removeRepository:(id)sender {
  if (self.reposTableView.selectedRow != -1) {
    NSString *repository = [self tableView:self.reposTableView objectValueForTableColumn:nil row:self.reposTableView.selectedRow];
    [Preferences.sharedPreferences removeRepository:repository];
    [self.reposTableView reloadData];
  }
}

- (IBAction)close:(id)sender {
  [self.preferencesPanel performClose:self];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return [Preferences.sharedPreferences.repositories count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  return (Preferences.sharedPreferences.repositories)[row];
}

@end
