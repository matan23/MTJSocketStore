//
//  ViewController.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/17/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "MessagesViewController.h"

#import "MTJSocketStore.h"
#import "MTJSyncedTableViewDataSource.h"

#import "Message.h"
#import "Conversation.h"
#import "PersistentStack.h"

#import "Message+CoreDataProperties.h"


@interface MessagesViewController () <MTJSyncedTableViewDataSourceDelegate, UITextFieldDelegate> {
    MTJSyncedTableViewDataSource *_dataSource;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end



@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    some margin for the bottom
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 88, 0);
    
    [self setupDataSource];
    [self loadMessages];
    
    self.tableView.tableFooterView = [UIView new];
}

- (Conversation *)conversation {
    return [[MTJSocketStore sharedStore] entityWithId:_conversationID ofType:[Conversation class]];
}

- (Message *)message {
    return [[MTJSocketStore sharedStore] entityWithId:@"tmp" ofType:[Message class]];
}


- (void)setupDataSource {
    _dataSource = [[MTJSocketStore sharedStore] tableViewDataSourceForType:[Message class]];
    [_dataSource setDelegate:self tableView:self.tableView withCellIdentifier:@"MessageCell"];
    
    [_dataSource sync];
}

- (void)loadMessages {
    Conversation *conversation = [self conversation];
    
    
    [[MTJSocketStore sharedStore] syncCollectionOfType:[Message class] belongingToType:conversation completion:^(NSArray *collection, NSError *error) {
       
        if (error) NSLog(@"error: %@", error);
    }];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height + 44);
        [self.tableView setContentOffset:offset animated:YES];
    }
}

#pragma mark - Interactor/Business Method
- (void)sendMessage:(NSString *)message {
    
    Message *messageEntity = [self message];
    messageEntity.conversation = [self conversation];
    messageEntity.messageText = message;
    
    [[MTJSocketStore sharedStore] syncedInsertEntity:messageEntity];
    self.textField.text = @"";
}

#pragma mark - Events

- (IBAction)sendButtonTapped:(id)sender {
    [self sendMessage:self.textField.text];
}

#pragma mark - TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    send typingindicator finish event
    [self moveViewUpToShowKeyboard:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    send typingindicator begin event
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self sendMessage:textField.text];
    [self.textField resignFirstResponder];
    [self moveViewUpToShowKeyboard:NO];
    return NO;
}

- (void)moveViewUpToShowKeyboard:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    if (movedUp) {
        if (rect.origin.y == 0) {
            rect.origin.y = self.view.frame.origin.y - 255;
        }
    } else {
        if (rect.origin.y < 0) {
            rect.origin.y = self.view.frame.origin.y + 255;
        }
    }
    self.view.frame = rect;
    [UIView commitAnimations];
}

#pragma mark - MTJSyncedTableViewDataSourceDelegate

- (void)configureCell:(UITableViewCell *)cell withObject:(id)object {
    Message *msg = object;
    cell.textLabel.text = msg.messageText;
}

- (void)dataInserted {
    [self scrollToBottom];
}

- (void)deleteObject:(id)object {
//    nothing for now
}

#pragma mark - Helpers

-(void)scrollToBottom{
    if (_tableView.contentSize.height > _tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, _tableView.contentSize.height - _tableView.frame.size.height + 88);
        [_tableView setContentOffset:offset animated:YES];
    }
}

@end
