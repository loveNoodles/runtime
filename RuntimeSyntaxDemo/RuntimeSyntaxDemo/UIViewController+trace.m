//
//  UIViewController+trace.m
//  RuntimeSyntaxDemo
//
//  Created by zgk on 2017/1/15.
//  Copyright © 2017年 BBAE. All rights reserved.
//

#import "UIViewController+trace.h"
#import <objc/runtime.h>

@implementation UIViewController (trace)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        SEL originalSelector = @selector(viewWillAppear:);
        SEL swizzedSelector = @selector(swizz_viewWillAppear:);
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzedMethod = class_getInstanceMethod(class, swizzedSelector);
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzedMethod), method_getTypeEncoding(swizzedMethod));
        if (didAddMethod) {
            class_replaceMethod(class, originalSelector, method_getImplementation(swizzedMethod), method_getTypeEncoding(swizzedMethod));\
        }
        else {
            method_exchangeImplementations(originalMethod, swizzedMethod);
        }
        
    });
}

- (void)swizz_viewWillAppear:(BOOL)animated {
    [self swizz_viewWillAppear:animated];
    NSLog(@"class name = %@", NSStringFromClass([self class]));
}

@end
