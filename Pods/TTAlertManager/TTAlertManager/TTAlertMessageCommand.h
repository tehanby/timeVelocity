//
//  TTAlertMessageCommand.h
//  TrifectaUtil
//
//  Created by Eric DeLabar on 8/9/12.
//  Copyright (c) 2012 Trifecta Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAlertManager.h"

@interface TTAlertMessageCommand : NSObject<TTAlertCommand>

@property (copy, nonatomic) void (^showAlert)();
@property (copy, nonatomic) void (^alertCompletion)();

@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *title;

+ (TTAlertMessageCommand *)alertWithMessage:(NSString *)message title:(NSString *)title alertCompletion:(void (^)())alertCompletion showAlert:(void (^)())showAlert;

@end
