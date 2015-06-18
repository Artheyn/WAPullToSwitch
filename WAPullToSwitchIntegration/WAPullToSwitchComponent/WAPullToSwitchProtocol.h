//
//  WAPullToSwitchProtocol.h
//  WAScrollGravitySwitchComponentBuilding
//
//  Created by Artheyn on 15/08/13.
//  Copyright (c) 2013 Artheyn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WAPullToSwitchDataSource <NSObject>

@required
// Ask the DataSource object for the view at the specified index.
- (UIView *)viewForIndex:(int)index;

@optional
// Default : WAPullToSwitchConstants.h:WAPULLTOSWITCH_DEFAULT_BOUNCE_GRAVITY.
- (float)gravityVectorYComponentForBounce;
// Default : WAPullToSwitchConstants.h:WAPULLTOSWITCH_DEFAULT_BOUNCE_ELASTICITY.
- (float)elasticityCoefficientForBounce;
// Default : WAPullToSwitchConstants.h:WAPULLTOSWITCH_DEFAULT_HIDE_GRAVITY
- (float)gravityVectorYComponentForHide;

@end

