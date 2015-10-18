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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureCell:(UITableViewCell *)cell withObject:(id)object {
    Conversation *conv = object;
    cell.textLabel.text = conv.obj_id;
}

- (void)deleteObject:(id)object {
//    nothing for now
}
@end
