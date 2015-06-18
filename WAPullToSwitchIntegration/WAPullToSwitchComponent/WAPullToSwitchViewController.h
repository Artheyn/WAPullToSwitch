//
//  WAScrollGravitySwitchViewController.h
//  WAScrollGravitySwitchComponentBuilding
//
//  Created by Artheyn on 14/08/13.
//  Copyright (c) 2013 Artheyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WAPullToSwitchProtocol.h"

enum WAScrollGravitySwitchState {
    WAScrollGravitySwitchStateFirst = 0,
    WAScrollGravitySwitchStateSecond = 1
    };

@interface WAPullToSwitchViewController : UIViewController <UIScrollViewDelegate> {
    @private
    // Flag to know if the user ended a dragging gesture.
    BOOL boolEndDragging;
    
    // Physics animation flags.
    float bounceElasticity;
    float bounceGravity;
    float hideGravity;
    
    @public
    // State which indicates which view is active.
    enum WAScrollGravitySwitchState scrollState;
}


// ScrollViews which will contain the two views we want to switch.
@property (strong, nonatomic) UIScrollView *scrollViewFirst;
@property (strong, nonatomic) UIScrollView *scrollViewSecond;

@property (weak, nonatomic) id <WAPullToSwitchDataSource> dataSource;

- (UIScrollView *)currentScrollView;

@end
