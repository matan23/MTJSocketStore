//
//  Conversation.m
//  
//
//  Created by sintaiyuan on 10/18/15.
//
//

#import "Conversation.h"

@implementation TransformableParticipantsArray

//transformable participants array
+ (Class)transformedValueClass
{
    return [NSArray class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}
@end

@implementation Conversation

- (void)loadFromDictionary:(NSDictionary *)dictionary
{
    self.objId = dictionary[[Conversation identifierString]];
    self.url = dictionary[@"url"];
    self.participants = dictionary[@"participants"];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormat dateFromString:dictionary[@"created_at"]];
    self.createdAt = date;
}

//"data": {
//  "participants": [ "1234", "5678" ],
//  "distinct": false,
//  "metadata": {
//      "background_color": "#3c3c3c"
//  }
//}
- (NSDictionary *)serializedCreateRequestDictionary {
    NSDictionary *data = @{@"participants": self.participants,
                           @"distinct":@YES,
                           @"metadata":@{@"background_color":@"#3c3c3c"}
                           };
    NSDictionary *body = @{ @"method": @"Conversation.create",
                            @"request_id": [NSString stringWithFormat:@"conversation.create.%@", [NSString stringWithFormat:@"%@-%@", self.participants[0], self.participants[1]]],
                            @"data": data};
    NSDictionary *parameters = @{ @"type": @"request", @"body": body};
    return parameters;
}

- (void)deserializedCreateRequestDictionary:(NSDictionary *)dictionary {
    
}

+ (id<MTJSyncedEntity>)findOrCreateEntity:(NSString *)objID inContext:(NSManagedObjectContext *)context
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
    return @"createdAt";
}

- (void)addCollection:(NSSet<NSManagedObject *> *)values {
    [self addMessages:(NSSet<Message *> *)values];
}

+ (instancetype)insertNewObjectIntoContext:(NSManagedObjectContext*)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
}

//name of the field to identify the object in core data
+ (NSString *)identifierString {
    return @"id";
}

- (NSString *)endpointURL {
    NSString *cleanConvObjID = [self.objId stringByReplacingOccurrencesOfString:@"layer:///conversations/" withString:@""];
    return [NSString stringWithFormat:@"conversations/%@", cleanConvObjID];
}

+ (NSString *)collectionEndpointURL {
    return @"conversations";
}

- (NSString *)collectionWithRelationshipEndpointURL {
    NSString *cleanConvObjID = [self.objId
                                stringByReplacingOccurrencesOfString:@"layer:///conversations/" withString:@""];
    return [NSString stringWithFormat:@"conversations/%@/messages", cleanConvObjID];
}


- (NSString *)description {
    return [NSString stringWithFormat:@" id: %@\n url: %@\n created_at:%@\n",
            self.objId, self.url, self.createdAt];
}


@end
