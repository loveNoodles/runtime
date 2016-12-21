//
//  MyClass.h
//  RunTimeDemo
//
//  Created by zgk on 2016/12/20.
//  Copyright © 2016年 ZGK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyClass : NSObject<NSCopying, NSCoding>

@property (nonatomic, strong) NSArray *array;

@property (nonatomic, copy) NSString *string;

- (void)method1;

- (void)method2;

+ (void)classMethod1;

@end
