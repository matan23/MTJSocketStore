//
//  Message+CoreDataProperties.h
//  
//
//  Created by sintaiyuan on 10/19/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message.h"

NS_ASSUME_NONNULL_BEGIN

@interface Message (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *objId;
@property (nullable, nonatomic, retain) NSString *url;
@property (nullable, nonatomic, retain) NSString *receiptsUrl;
@property (nullable, nonatomic, retain) NSDate *sentAt;
@property (nullable, nonatomic, retain) NSString *messageText;
@property (nullable, nonatomic, retain) Conversation *conversation;

@end

NS_ASSUME_NONNULL_END
