//
//  ConversationsTableViewController.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/19/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "ConversationsTableViewController.h"

//dataSource and models
#import "MTJSocketStore.h"
#import "MTJSyncedTableViewDataSource.h"
#import "Conversation.h"

//next vc
#import "MessagesViewController.h"

@interface ConversationsTableViewController () <MTJSyncedTableViewDataSourceDelegate> {
    MTJSyncedTableViewDataSource *_dataSource;
}

@end

@implementation ConversationsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDataSource];
    [self loadConversations];
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)setupDataSource {
    _dataSource = [[MTJSocketStore sharedStore] tableViewDataSourceForType:[Conversation class]];
    [_dataSource setDelegate:self tableView:self.tableView withCellIdentifier:@"ConvCell"];
    
    [_dataSource sync];
}

- (void)loadConversations {
    [[MTJSocketStore sharedStore] syncCollectionOfType:(id<MTJSyncedEntity>)[Conversation class] completion:^(NSArray *collection, NSError *error) {
       
        if (error) NSLog(@"error: %@", error);
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MessagesViewController *vc = [segue destinationViewController];
    
    Conversation *conv = [_dataSource itemAtIndexPath:[self.tableView indexPathForCell:sender]];
    NSAssert(conv, @"no conv for index path..");
    vc.conversationID = conv.objId;
}

#pragma mark - MTJSyncedTableViewDataSourceDelegate

- (void)configureCell:(UITableViewCell *)cell withObject:(id)object {
    Conversation *conv = object;
    
    NSString *participantsString = [conv.participants componentsJoinedByString:@"-"];
    cell.textLabel.text = participantsString;
}

#pragma mark - TableViewDelegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}
@end
