//
//  ViewController.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "ViewController.h"

#import "MTJSocketStore.h"
#import "MTJSyncedTableViewDataSource.h"

#import "Conversation.h"
#import "PersistentStack.h"

@interface ViewController () <MTJSyncedTableViewDataSourceDelegate> {
    MTJSyncedTableViewDataSource *_dataSource;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    
    _dataSource = [[MTJSocketStore sharedStore] tableViewDataSourceForType:(id<MTJSyncedEntity>)[Conversation class]];    
    [_dataSource setDelegate:self tableView:_tableView withCellIdentifier:@"Cell"];
    
    [_dataSource sync];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height + 44);
        [self.tableView setContentOffset:offset animated:YES];
    }
}


#pragma mark - TextFieldDelegata
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendMessage:textField.text];
    textField.text = @"";
    return NO;
}

- (void)sendMessage:(NSString *)message {
    Conversation *conv = [Conversation findOrCreateEntity:@"bla" inContext:[PersistentStack sharedManager].backgroundManagedObjectContext];
    conv.participants = [NSArray arrayWithObjects:@"WpXM3IIDzc", @"zyDQkU9pQD", nil];
    
    [[MTJSocketStore sharedStore] syncedInsertEntityOfType:conv];
}


#pragma mark - MTJSyncedTableViewDataSourceDelegate



- (void)configureCell:(UITableViewCell *)cell withObject:(id)object {
    Conversation *conv = object;
    cell.textLabel.text = conv.objId;
}

- (void)deleteObject:(id)object {
//    nothing for now
}
@end
