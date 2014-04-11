//
//  TTAlertManager.h
//  TrifectaUtil
//
//  Created by Eric DeLabar on 8/2/12.
//  Copyright (c) 2012 Trifecta Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "TTAlertManagerDelegate.h"

@interface TTAlertManager : NSObject<UIAlertViewDelegate>

@property (strong,nonatomic) id<TTAlertManagerDelegate> delegate;

- (void)enqueueMessage:(NSString *)message withTitle:(NSString *)title;
- (void)enqueueMessage:(NSString *)message withTitle:(NSString *)title completion:(void (^)())completion;
- (void)enqueuePrompt:(NSString *)message withTitle:(NSString *)Title cancelButton:(NSString *)cancelButton buttonTexts:(NSArray *)buttonTexts buttonHandler:(void (^)(NSUInteger selectedIndex))buttonHandler;
- (void)processQueue;

+ (TTAlertManager *)manager;

@end

@protocol TTAlertCommand <NSObject>

@property (copy, nonatomic) void (^alertCompletion)();
- (void)display;

@end