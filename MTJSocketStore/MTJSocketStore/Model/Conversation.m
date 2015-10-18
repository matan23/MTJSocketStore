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
    self.objId = dictionary[[Conversation identifierString]];
    self.url = dictionary[@"url"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormat dateFromString:dictionary[@"created_at"]];
    self.createdAt = date;
}

+ (Conversation *)findOrCreateConversation:(NSString *)objID inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"objId = %@", objID];
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"error: %@", error.localizedDescription);
    }
    if (result.lastObject) {
        return result.lastObject;
    } else {
        Conversation *conv = [self insertNewObjectIntoContext:context];
        conv.objId = objID;
        return conv;
    }
}

+ (id)entityName
{
    return NSStringFromClass(self);
}

+ (NSString *)sortKey {
    return @"created_at";
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

//name of the field to identify the object in core data
+ (NSString *)identifierString {
    return @"id";
}

+ (NSString *)endpointURL {
    return @"conversations";
}


- (NSString *)description {
    return [NSString stringWithFormat:@" id: %@\n url: %@\n created_at:%@\n",
            self.objId, self.url, self.createdAt];
}


@end
