//
//  Message.h
//  
//
//  Created by sintaiyuan on 10/19/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "MTJSocketStore.h"

@class Conversation;

NS_ASSUME_NONNULL_BEGIN

@interface Message : NSManagedObject <MTJSyncedEntity>

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "Message+CoreDataProperties.h"
