//
//  ViewController.m
//  ECTouchLabel
//
//  Created by 刘超 on 15/2/16.
//  Copyright (c) 2015年 elecCore. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,weak) ECTouchLabel *testLableView;

@end

@implementation ViewController
@synthesize testLableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ECTouchLabel *p_testLableView = [[ECTouchLabel alloc] initWithFrame:CGRectMake(50, 100, 240, 30)];
    [self.view addSubview:p_testLableView];
    testLableView = p_testLableView;
    [testLableView setBackgroundColor:[UIColor yellowColor]];
    [testLableView setFont:[UIFont systemFontOfSize:14]];
    [testLableView setText:@"中文的测试#中文的测试#中文的测试中文的测试#中文的测试#中文的测试中文的测试#中文的测试#中文的测试中文的测试#中文的测试#中文的测试"];
    testLableView.eventTopicCheck = ^(NSString *TopicName){
        [[[UIAlertView alloc] initWithTitle:@"" message:TopicName
                                   delegate:self
                          cancelButtonTitle:@"确定"
                            otherButtonTitles:nil] show];
    };
    
    NSString *test4;
    
    [testLableView sizeToFitWithMaxSize:CGSizeMake(testLableView.frame.size.width, MAXFLOAT)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    //All right
}

@end
