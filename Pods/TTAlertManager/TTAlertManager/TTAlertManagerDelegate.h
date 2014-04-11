//
//  TTAlertManagerDelegate.h
//  TrifectaUtil
//
//  Created by Eric DeLabar on 8/9/12.
//  Copyright (c) 2012 Trifecta Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TTAlertManagerDelegate <NSObject>

@optional

- (void)displayMessage:(NSString *)message withTitle:(NSString *)title completion:(void (^)())completion;
- (void)displayPrompt:(NSString *)message withTitle:(NSString *)title buttonTexts:(NSArray *)buttonTexts buttonHandler:(void (^)(NSUInteger selectedIndex))buttonHandler;

@end
