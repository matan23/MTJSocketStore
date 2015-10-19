//
//  Message+CoreDataProperties.m
//  
//
//  Created by sintaiyuan on 10/19/15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Message+CoreDataProperties.h"

@implementation Message (CoreDataProperties)

@dynamic objId;
@dynamic url;
@dynamic receiptsUrl;
@dynamic sentAt;
@dynamic messageText;
@dynamic conversation;

@end
