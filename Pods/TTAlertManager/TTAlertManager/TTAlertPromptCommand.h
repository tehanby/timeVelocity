//
//  TTAlertPromptCommand.h
//  TrifectaUtil
//
//  Created by Eric DeLabar on 8/9/12.
//  Copyright (c) 2012 Trifecta Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TTAlertMessageCommand.h"

@interface TTAlertPromptCommand : TTAlertMessageCommand

@property (strong, nonatomic) NSArray *buttonTitles;
@property (copy, nonatomic) void (^buttonHandler)(NSUInteger selectedIndex);

+ (TTAlertPromptCommand *)alertWithMessage:(NSString *)message title:(NSString *)title buttonTitles:(NSArray *)buttonTitles buttonHandler:(void (^)(NSUInteger selectedIndex))buttonHandler showAlert:(void (^)())showAlert;

@end
