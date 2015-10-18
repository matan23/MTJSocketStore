//
//  Conversation.h
//  
//
//  Created by sintaiyuan on 10/18/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Conversation : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

+ (Conversation *)findOrCreateConversation:(NSString *)objID inContext:(NSManagedObjectContext *)context;

- (void)loadFromDictionary:(NSDictionary *)dictionary;

@end


NS_ASSUME_NONNULL_END

#import "Conversation+CoreDataProperties.h"
