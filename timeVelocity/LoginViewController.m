//
//  LoginViewController.m
//  timeVelocity
//
//  Created by Tim Hanby on 3/18/14.
//  Copyright (c) 2014 Timothy Hanby. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

static NSString * const baseURL = @"https://jira.trifecta.com/rest/auth/1/session";

- (IBAction)usernameExit:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)passwordExit:(id)sender {
    [sender resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.password.secureTextEntry = YES;
    [self.password setReturnKeyType:UIReturnKeyDone];
    [self.username setReturnKeyType:UIReturnKeyDone];

}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    [self.view endEditing:YES];
    __block BOOL shouldAuthorizeForUser;
    if([self.username.text length] == 0 || [self.password.text length] == 0){
        [self displayError];
        return NO;
    }else {
         [self authorizeForUser:^(BOOL authorizeForUser) {
             shouldAuthorizeForUser = authorizeForUser;
             return authorizeForUser;
         }];
    }
    return shouldAuthorizeForUser;
}

- (void)authorizeForUser:(BOOL(^)(BOOL authorizeForUser))completionBlock
{

    NSDictionary *parameters = @{@"username":self.username.text, @"password":self.password.text};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    __weak typeof (self) weakSelf = self;
    [manager POST:baseURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        completionBlock(YES);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [weakSelf displayError];
        completionBlock(NO);
    }];

}

-(void)displayError
{
    TTAlertManager *alertManager = [[TTAlertManager alloc] init];
    [alertManager enqueuePrompt:@"Invalid Credentials."
                      withTitle:@"Login Error"
                   cancelButton:@"OK"
                    buttonTexts:@[@"Cancel"]
                  buttonHandler:^(NSUInteger selectedIndex) {
                      
                      
                  }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    TableViewController *tvc = [segue destinationViewController];
    [tvc setNameOfUserToBuildTableArray:self.username.text];
    
}


@end
