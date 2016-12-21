//
//  AppDelegate.m
//  RuntimeSyntaxDemo
//
//  Created by zgk on 2016/12/21.
//  Copyright © 2016年 BBAE. All rights reserved.
//

#import "AppDelegate.h"
#import <objc/message.h>
#import "MyClass.h"


@interface AppDelegate ()

@end

void TestMetaClass(id self, SEL _cmd) {
    NSLog(@"this object is %p", self);
    NSLog(@"Class is %@, super class is %@", [self class], [self superclass]);
    
    Class currentClass = [self class];
    for (int i = 0; i < 4; i++) {
        NSLog(@"Following the isa pointer %d times gives %p", i, currentClass);
        currentClass = objc_getClass((__bridge void *)currentClass);
    }
    
    NSLog(@"NSObject's class is %p", [NSObject class]);
    NSLog(@"NSObject's meta class is %p", objc_getClass((__bridge void *)[NSObject class]));
    NSLog(@"NSObject's size is %zu  version %d", class_getInstanceSize([NSObject class]), class_getVersion([NSObject class]));
    
    NSObject *obj = [NSObject new];
    NSLog(@"%s, superClass:%s, isMetaClass:%d", class_getName(obj.class), class_getName(class_getSuperclass(obj.class)), class_isMetaClass(obj.class));
}

void imp_submethod1(id self, SEL _cmd) {
    NSLog(@"call imp_submethod1 now");
    
}


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //////////////////////////////////////////////////////////////////
    // 本工程已经将Objective-C Automatic Reference Counting 设置为了NO //
    /////////////////////////////////////////////////////////////////
    
    /////////////////// 第一个栗子
    // 这个例子是在运行时创建了一个NSError的子类TestClass，然后为这个子类添加一个方法testMetaClass，这个方法的实现是TestMetaClass函数。
    Class newClass = objc_allocateClassPair([NSError class], "TTestClass", 0);      // 创建一个新的对象TTestClass
    class_addMethod(newClass, @selector(testMetaClass), (IMP)TestMetaClass, "v@:"); // 向TTestClass添加一个方法testMetaClass,并由TestMetaClass函数实现
    objc_registerClassPair(newClass);
    
    id instance = [[newClass alloc] initWithDomain:@"some domain" code:0 userInfo:nil];
    [instance performSelector:@selector(testMetaClass)];
    
    
    ///////////////////////////// 分割线 /////////////////////////////
    
    /////////////////// 第二个栗子
    // 类操作函数
    MyClass *myClass = [[MyClass alloc] init];
    unsigned int outCount = 0;
    Class cls = myClass.class;
    
    NSLog(@"================= 获取类名 =================");
    NSLog(@"class name : %s", class_getName(cls));
    NSLog(@"================= 获取父类 =================");
    NSLog(@"super class name : %s", class_getName(class_getSuperclass(cls)));
    NSLog(@"================= 是否是元类 =================");
    NSLog(@"MyClass is %@ a meta-class", (class_isMetaClass(cls))?@"":@"not");
    NSLog(@"================= 获取元类 =================");
    Class meta_class = objc_getMetaClass(class_getName(cls));
    NSLog(@"%s's meta-class is %s", class_getName(cls), class_getName(meta_class));
    NSLog(@"================= 实例变量大小 =================");
    NSLog(@"instance size: %zu", class_getInstanceSize(cls));
    NSLog(@"================= MyClass的成员变量 =================");
    Ivar *ivars = class_copyIvarList(cls, &outCount);
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        NSLog(@"instance variables's name: %s at index:%d", ivar_getName(ivar), i);
        NSLog(@"ivar typeEncoding: %s", ivar_getTypeEncoding(ivar));
    }
    free(ivars);
    
    Ivar string = class_getInstanceVariable(cls, "_string");
    if (string != NULL) {
        NSLog(@"instance variable : %s", ivar_getName(string));
    }
    NSLog(@"================= 属性操作 =================");
    objc_property_t *properties = class_copyPropertyList(cls, &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSLog(@"property's name: %s", property_getName(property));
    }
    free(properties);
    
    objc_property_t array = class_getProperty(cls, "array");
    if (array != NULL) {
        NSLog(@"property : %s", property_getName(array));
    }
    
    NSLog(@"================= 方法操作 =================");
    Method *methods = class_copyMethodList(cls, &outCount);
    for (int i = 0; i < outCount; i++) {
        Method method = methods[i];
        NSLog(@"method's signature : %s", sel_getName(method_getName(method)));
    }
    free(methods);
    
    Method method1 = class_getInstanceMethod(cls, @selector(method1));
    if (method1 != NULL) {
        NSLog(@"method : %s", sel_getName(method_getName(method1)));
    }
    
    Method classMethod = class_getClassMethod(cls, @selector(classMethod1));
    if (classMethod != NULL) {
        NSLog(@"class method : %s", sel_getName(method_getName(classMethod)));
    }
    
    NSLog(@"MyClass is %@ respond to selector: method3WithArg1:arg2:", (class_respondsToSelector(cls, @selector(method3WithArg1:arg2:)))?@"":@"not");
    
    IMP imp = class_getMethodImplementation(cls, @selector(method1));
    imp();
    
    NSLog(@"================= 协议 =================");
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList(cls, &outCount);
    Protocol *protocol;
    for (int i = 0; i < outCount; i++) {
        protocol = protocols[i];
        NSLog(@"protocol name: %s", protocol_getName(protocol));
    }
    
    NSLog(@"MyClass is %@ resonsed to protocol %s", class_conformsToProtocol(cls, protocol)?@"":@"not", protocol_getName(protocol));
    
    ///////////////////////////// 分割线 /////////////////////////////
    
    /////////////////// 第三个栗子
    // 动态创建类
    Class newCls = objc_allocateClassPair(myClass.class, "MySubClass", 0);
    class_addMethod(newCls, @selector(submethod1), (IMP)imp_submethod1, "v@:");
    class_replaceMethod(newCls, @selector(method1), (IMP)imp_submethod1, "v@:");
    class_addIvar(newCls, "_ivar1", sizeof(NSString *), log(sizeof(NSString *)), "i");
    
    objc_property_attribute_t type = {"T", "@\"NSString\""};
    objc_property_attribute_t ownership = {"C", ""};
    objc_property_attribute_t backingvar = {"V", "_ivar1"};
    objc_property_attribute_t attrs[] = {type, ownership, backingvar};
    
    class_addProperty(newCls, "property2", attrs, 3);
    objc_registerClassPair(newCls);
    
    id instance1 = [[newCls alloc] init];
    [instance1 performSelector:@selector(submethod1)];
    [instance1 performSelector:@selector(method1)];
    
    ///////////////////////////// 分割线 /////////////////////////////
    
    /////////////////// 第四个栗子
    // 动态创建对象 (在非ARC环境下使用)
    id theObject = class_createInstance([NSString class], sizeof(unsigned));
    id str1 = [theObject init];
    NSLog(@"str1: %@", [str1 class]);
    
    id str2 = [[NSString alloc] initWithString:@"test"];
    NSLog(@"str2 : %@", [str2 class]);
    
    ///////////////////////////// 分割线 /////////////////////////////
    
    /////////////////// 第五个栗子
    // 获取类定义: objc_getClassList函数,获取已注册的类定义的列表。
    // 注意下方会有很多输出
    int numClasses;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        classes = malloc(sizeof(Class)*numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        NSLog(@"number of classes : %d", numClasses);
        for (int i = 0; i < numClasses; i++) {
            Class cls = classes[i];
            NSLog(@"class name : %s", class_getName(cls));
        }
        free(classes);
    }

    
    return YES;
}


@end
