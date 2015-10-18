//
//  Conversation.h
//  
//
//  Created by sintaiyuan on 10/18/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "MTJSocketStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface Conversation : NSManagedObject <MTJSyncedEntity>
@end


NS_ASSUME_NONNULL_END

#import "Conversation+CoreDataProperties.h"
