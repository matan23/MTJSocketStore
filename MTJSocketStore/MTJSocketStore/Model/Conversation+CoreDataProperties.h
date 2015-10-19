//
//  Conversation+CoreDataProperties.h
//  
//
//  Created by sintaiyuan on 10/19/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Conversation.h"

NS_ASSUME_NONNULL_BEGIN

@interface Conversation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSString *objId;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) id participants;
@property (nullable, nonatomic, retain) NSOrderedSet<NSManagedObject *> *messages;

@end

@interface Conversation (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx;
- (void)insertMessages:(NSArray<NSManagedObject *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray<NSManagedObject *> *)values;
- (void)addMessagesObject:(NSManagedObject *)value;
- (void)removeMessagesObject:(NSManagedObject *)value;
- (void)addMessages:(NSOrderedSet<NSManagedObject *> *)values;
- (void)removeMessages:(NSOrderedSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
