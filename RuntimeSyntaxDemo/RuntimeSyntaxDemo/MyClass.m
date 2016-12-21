//
//  MyClass.m
//  RunTimeDemo
//
//  Created by zgk on 2016/12/20.
//  Copyright © 2016年 ZGK. All rights reserved.
//

#import "MyClass.h"

@interface MyClass ()
{
    NSInteger _instance1;
    NSString *_instance2;
}

@property (nonatomic, assign) NSUInteger integer;

- (void)method3WithArg1:(NSInteger)arg1 arg2:(NSString *)arg2;

@end


@implementation MyClass

+ (void)classMethod1 {

}

- (void)method1 {
    NSLog(@"call method1 now");
}

- (void)method2 {

}

- (void)method3WithArg1:(NSInteger)arg1 arg2:(NSString *)arg2 {

}

@end
