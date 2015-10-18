//
//  FetchedResultControllerDataSource.h
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/18/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@protocol FetchedResultsControllerDataSourceDelegate

- (void)configureCell:(UITableView *)cell withObject:(id)object;
- (void)deleteObject:(id)object;

@end

@interface MTJSyncedTableViewDataSource : NSObject <UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) id<FetchedResultsControllerDataSourceDelegate> delegate;


- (instancetype)initWithFRC:(NSFetchedResultsController *)frc;
- (void)setTableView:(UITableView *)tableView withCellIdentifier:(NSString *)identifier;
- (NSError *)sync;

@end
