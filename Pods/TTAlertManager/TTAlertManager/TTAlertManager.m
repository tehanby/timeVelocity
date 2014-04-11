//
//  TTAlertManager.m
//  TrifectaUtil
//
//  Created by Eric DeLabar on 8/2/12.
//  Copyright (c) 2012 Trifecta Technologies, Inc. All rights reserved.
//

#import "TTAlertManager.h"

#import "TTAlertMessageCommand.h"
#import "TTAlertPromptCommand.h"

@interface TTAlertManager () {
    NSMutableArray *_queue;
}

@property (assign, atomic) BOOL messageDisplayed;
@property (strong, atomic) id<TTAlertCommand> currentMessage;
@property (readonly, atomic) NSMutableArray *queue;

- (void)push:(id<TTAlertCommand>)command;
- (void)popAndDisplay;

@end

@implementation TTAlertManager

- (void)enqueueMessage:(NSString *)message withTitle:(NSString *)title
{
    [self enqueueMessage:message withTitle:title completion:nil];
}

- (void)enqueueMessage:(NSString *)message withTitle:(NSString *)title completion:(void (^)())completion
{
    TTAlertMessageCommand *cmd = [TTAlertMessageCommand alertWithMessage:message title:title alertCompletion:completion showAlert:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(displayMessage:withTitle:completion:)]) {
            
            [self.delegate displayMessage:message withTitle:title completion:completion];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
            
        }
    }];
    [self push:cmd];
    
    [self processQueue];
}

- (void)enqueuePrompt:(NSString *)message withTitle:(NSString *)title cancelButton:(NSString *)cancelButton buttonTexts:(NSArray *)buttonTexts buttonHandler:(void (^)(NSUInteger selectedIndex))buttonHandler
{
    TTAlertPromptCommand *cmd = [TTAlertPromptCommand alertWithMessage:message title:title buttonTitles:buttonTexts buttonHandler:buttonHandler showAlert:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(displayPrompt:withTitle:buttonTexts:buttonHandler:)]) {
            
            [self.delegate displayPrompt:message withTitle:title buttonTexts:buttonTexts buttonHandler:buttonHandler];
            
        } else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButton otherButtonTitles:nil];
            for (NSString *buttonTitle in buttonTexts) {
                [alert addButtonWithTitle:buttonTitle];
            }
            alert.delegate = self;
            [alert show];
            
        }
    }];
    [self push:cmd];
    
    [self processQueue];
}

- (void)processQueue
{
    if (!self.messageDisplayed) {
        [self popAndDisplay];
    }
}

- (void)push:(id<TTAlertCommand>)command
{
    [self.queue addObject:command];
}

- (void)popAndDisplay
{
    if ([self.queue count]) {
        id<TTAlertCommand> cmd = [self.queue objectAtIndex:0];
        [self.queue removeObjectAtIndex:0];
        
        self.messageDisplayed = YES;
        self.currentMessage = cmd;
        [cmd display];
    }
}

#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.currentMessage) {
        
        if ([self.currentMessage respondsToSelector:@selector(buttonHandler)]) {
            
            TTAlertPromptCommand *cmd = self.currentMessage;
            if (cmd.buttonHandler) {
                cmd.buttonHandler(buttonIndex);
            }
            
        } else {
            
            TTAlertMessageCommand *cmd = self.currentMessage;
            if (cmd.alertCompletion) {
                cmd.alertCompletion();
            }
            
        }
        
    }
    
    self.currentMessage = nil;
    self.messageDisplayed = NO;
    
    [self processQueue];
}

#pragma mark Singleton implementation

+ (TTAlertManager *)manager
{
    static TTAlertManager *__sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[self alloc] init];
    });
    return __sharedInstance;
}

#pragma mark Private helper methods

- (NSMutableArray *)queue
{
    if (!_queue) {
        _queue = [NSMutableArray array];
    }
    return _queue;
}

@end

