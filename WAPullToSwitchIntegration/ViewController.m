//
//  ViewController.m
//  WAPullToSwitchIntegration
//
//  Created by Alexandre KARST on 04/05/2015.
//  Copyright (c) 2015 Alexandre KARST. All rights reserved.
//

#import "ViewController.h"
#import "WAPullToSwitchViewController.h"

@interface ViewController () <WAPullToSwitchDataSource>

@end

@implementation ViewController


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Instantiate our component and setup the data source.
    pullToSwitchViewController = [[WAPullToSwitchViewController alloc] init];
    pullToSwitchViewController.dataSource = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    UIView *componentView = pullToSwitchViewController.view;
    
    // Add the component view to our current view.
    [self.view addSubview:componentView];
    
    // Setup the component to fit its superview.
    NSArray *fitSuperviewConstraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[componentView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(componentView)];
    NSArray *fitSuperviewConstraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[componentView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(componentView)];
    
    [self.view addConstraints:fitSuperviewConstraintsHorizontal];
    [self.view addConstraints:fitSuperviewConstraintsVertical];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - @WAPullToSwitchDataSource

- (UIView *)viewForIndex:(int)index {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height + 200.0f)];
    
    if (index % 2 == 0) {
        view.backgroundColor = [UIColor lightGrayColor];
    } else {
        view.backgroundColor = [UIColor brownColor];
    }

    return view;
}

- (float)gravityVectorYComponentForHide {
    return 4.0f;
}

- (float)gravityVectorYComponentForBounce {
    return -3.0f;
}

- (float)elasticityCoefficientForBounce {
    return 0.1f;
}



@end
