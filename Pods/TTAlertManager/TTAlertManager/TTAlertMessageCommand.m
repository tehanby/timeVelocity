//
//  TTAlertMessageCommand.m
//  TrifectaUtil
//
//  Created by Eric DeLabar on 8/9/12.
//  Copyright (c) 2012 Trifecta Technologies, Inc. All rights reserved.
//

#import "TTAlertMessageCommand.h"

@implementation TTAlertMessageCommand

- (void)display
{
    self.showAlert();
}

+ (TTAlertMessageCommand *)alertWithMessage:(NSString *)message title:(NSString *)title alertCompletion:(void (^)())alertCompletion showAlert:(void (^)())showAlert
{
    TTAlertMessageCommand *messageCmd = [[TTAlertMessageCommand alloc] init];
    messageCmd.message = message;
    messageCmd.title = title;
    messageCmd.alertCompletion = alertCompletion;
    messageCmd.showAlert = showAlert;
    
    return messageCmd;
}

@end
