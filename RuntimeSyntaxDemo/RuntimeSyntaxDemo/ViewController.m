//
//  ViewController.m
//  RuntimeSyntaxDemo
//
//  Created by zgk on 2016/12/21.
//  Copyright © 2016年 BBAE. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"我是viewController的viewWillAppear:方法。viewWillAppear:方法将会被UIViewController+trace中的swizz_viewWillAppear:方法监测到");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
