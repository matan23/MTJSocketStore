//
//  Conversation.m
//  
//
//  Created by sintaiyuan on 10/18/15.
//
//

#import "Conversation.h"

@implementation Conversation

// Insert code here to add functionality to your managed object subclass

- (void)loadFromDictionary:(NSDictionary *)dictionary
{
    self.obj_id = dictionary[@"id"];
    self.url = dictionary[@"url"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormat dateFromString:dictionary[@"created_at"]];
    self.created_at = date;
}

+ (Conversation *)findOrCreateConversation:(NSString *)objID inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"obj_id = %@", objID];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result.lastObject) {
        return result.lastObject;
    } else {
        Conversation *conv = [self insertNewObjectIntoContext:context];
        conv.obj_id = objID;
        return conv;
    }
}

+ (id)entityName
{
    return NSStringFromClass(self);
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}


- (NSString *)description {
    return [NSString stringWithFormat:@" id: %@\n url: %@\n created_at:%@\n",
            self.obj_id, self.url, self.created_at];
}


@end
