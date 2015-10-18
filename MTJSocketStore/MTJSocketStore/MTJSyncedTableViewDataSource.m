//
//  MTJSyncedTableViewDataSource.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/18/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "MTJSyncedTableViewDataSource.h"

@interface MTJSyncedTableViewDataSource() {
    NSString *_reuseIdentifier;
    UITableView *_tableView;;
}

@end

@implementation MTJSyncedTableViewDataSource


- (instancetype)initWithFRC:(NSFetchedResultsController *)frc {
    self = [super init];
    if (self) {
        _fetchedResultsController = frc;
        _fetchedResultsController.delegate = self;
    }
    return self;
}

- (void)setDelegate:(id<MTJSyncedTableViewDataSourceDelegate>)delegate tableView:(UITableView *)tableView withCellIdentifier:(NSString *)identifier {
    _delegate = delegate;
    _tableView = tableView;
    _tableView.dataSource = self;
    _reuseIdentifier = identifier;
}

- (NSError *)sync {
    if (!_fetchedResultsController ||
        !_tableView ||
        !_delegate) {
        @throw @"Did you call: setDelegate:tableView:withCellIdentifier: ?";
    }

    NSError *error = nil;
    [_fetchedResultsController performFetch:&error];
    assert(!error);
    if (error) NSLog(@"Sync error, performFetch failed: %@", error);
    return error;
}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return _fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    id<NSFetchedResultsSectionInfo> section = _fetchedResultsController.sections[sectionIndex];
    return section.numberOfObjects;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    id object = [_fetchedResultsController objectAtIndexPath:indexPath];
    id cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdentifier forIndexPath:indexPath];
    [_delegate configureCell:cell withObject:object];
    return cell;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_delegate deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{
    [_tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{
    [self scrollToBottom];
    [_tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{
    if (type == NSFetchedResultsChangeInsert) {
        [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeMove) {
        [_tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    } else if (type == NSFetchedResultsChangeDelete) {
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        NSAssert(NO,@"");
    }
}

-(void)scrollToBottom{
    if (_tableView.contentSize.height > _tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height + 44);
        [_tableView setContentOffset:offset animated:YES];
    }
}
@end
