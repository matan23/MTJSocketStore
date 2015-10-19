//
//  MTJSyncedTableViewDataSource.h
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/18/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@protocol MTJSyncedTableViewDataSourceDelegate <NSObject>

- (void)configureCell:(UITableView *)cell withObject:(id)object;
- (void)dataInserted;

@optional
- (void)deleteObject:(id)object;

@end

@interface MTJSyncedTableViewDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak, readonly) id<MTJSyncedTableViewDataSourceDelegate> delegate;


- (instancetype)initWithFRC:(NSFetchedResultsController *)frc;
- (void)setDelegate:(id<MTJSyncedTableViewDataSourceDelegate>)delegate tableView:(UITableView *)tableView withCellIdentifier:(NSString *)identifier;

//connects the delegate with the underlying dataSource
- (NSError *)sync;

- (id)itemAtIndexPath:(NSIndexPath *)path;

@end
