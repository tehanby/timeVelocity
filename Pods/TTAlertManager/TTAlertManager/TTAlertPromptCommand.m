//
//  TTAlertPromptCommand.m
//  TrifectaUtil
//
//  Created by Eric DeLabar on 8/9/12.
//  Copyright (c) 2012 Trifecta Technologies, Inc. All rights reserved.
//

#import "TTAlertPromptCommand.h"

@implementation TTAlertPromptCommand

- (void)display
{
    self.showAlert();
}

+ (TTAlertPromptCommand *)alertWithMessage:(NSString *)message title:(NSString *)title buttonTitles:(NSArray *)buttonTitles buttonHandler:(void (^)(NSUInteger selectedIndex))buttonHandler showAlert:(void (^)())showAlert
{
    TTAlertPromptCommand *messageCmd = [[TTAlertPromptCommand alloc] init];
    messageCmd.message = message;
    messageCmd.title = title;
    messageCmd.buttonTitles = buttonTitles;
    messageCmd.buttonHandler = buttonHandler;
    messageCmd.showAlert = showAlert;
    
    return messageCmd;
}

@end
