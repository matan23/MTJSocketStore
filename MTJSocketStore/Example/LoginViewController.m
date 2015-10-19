//
//  LoginViewController.m
//  MTJSocketStore
//
//  Created by sintaiyuan on 10/19/15.
//  Copyright © 2015 mataejoon. All rights reserved.
//

#import "LoginViewController.h"

#import "MTJSocketStore.h"
#import "MTJLayerKeysHelper.h"

#import "ConversationsTableViewController.h"

#import "AppDelegate.h"

@interface LoginViewController()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end



#if TARGET_IPHONE_SIMULATOR
//chocobox
// If on simulator set the user ID to Simulator and participant to Device
NSString *const userID = @"zyDQkU9pQD";
#else
// If on device set the user ID to Device and participant to Simulator
//new
NSString *const userID = @"WpXM3IIDzc";
#endif


@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_activityIndicator startAnimating];
    [[MTJSocketStore sharedStore] connectUser:userID completion:^(BOOL success, NSError *error) {
        
        [_activityIndicator stopAnimating];
        if (success ) {
            [self navigateToNextVC];
        } else {
            UIAlertController *alertController = [UIAlertController
                                                  alertControllerWithTitle:@"Network Error"
                                                  message:@"Unable to connect user"
                                                  preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

- (void)navigateToNextVC {
    UIViewController *vc = [AppDelegate instantiateViewControllerWithIdentifier:@"ConversationsVC"];
    
    NSMutableArray *stackViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    [stackViewControllers removeLastObject];
    [stackViewControllers addObject:vc];
    [self.navigationController setViewControllers:stackViewControllers animated:YES];
}

@end
