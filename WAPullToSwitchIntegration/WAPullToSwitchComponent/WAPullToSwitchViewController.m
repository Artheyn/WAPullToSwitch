//
//  WAScrollGravitySwitchViewController.m
//
//  Created by Artheyn on 14/08/13.
//  Copyright (c) 2013 Artheyn. All rights reserved.
//

#import "WAPullToSwitchViewController.h"
#import "WAPullToSwitchConstants.h"


#pragma mark - (Public) interface
@interface WAPullToSwitchViewController ()

// Animators to respectively bounce or hide a UIScrollView.
@property (nonatomic) UIDynamicAnimator* animatorBounceView;
@property (nonatomic) UIDynamicAnimator* animatorHideView;

@end

#pragma mark - (Private) interface
@interface WAPullToSwitchViewController (Private)

#pragma mark - Scroll configuration
// Retrieve views and configuration data from dataSource and build the UIScrollView(s).
- (void)configureScrollViews;
// Ask the dataSource for configurations values.
- (void)retrieveDataSourceConfiguration;
// Used to encapsulate a requested view from the dataSource in a UIScrollView.
- (UIScrollView *)encapsulateViewInScrollView:(UIView *)contentView;

#pragma mark - Animation management
// Reset animators and place the active view on the top of the stack.
- (void)resetAnimatorsAndUpdateCurrentScrollZIndex:(UIScrollView *)scrollView;
// Bounce the current UIScrollView with a defined elasticity and a gravity effect.
- (void)bounceCurrentScroll;
// Hide the current UIScrollView with a gravity effect.
- (void)hideCurrentScroll;
// Switch between the active and inactive view with animation.
- (void)switchScroll;
// Enable scroll on scroll views.
- (void)enableScroll;
// Disable scroll on scroll views.
- (void)disableScroll;

#pragma mark - Attributes management
// Switch the state so that it reflects the current displayed scrollView.
- (void)switchState;

@end


#pragma mark - (Public) implementation
@implementation WAPullToSwitchViewController

#pragma mark - Constructors
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        scrollState = WAScrollGravitySwitchStateFirst;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        scrollState = WAScrollGravitySwitchStateFirst;
    }
    return self;
}

#pragma mark - Memory management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Retrieve scroll views and configure them
    [self configureScrollViews];
    
    // We hide content out of bounds
    self.view.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect frameScrollComponent = self.view.frame;
    CGRect frameScrollViewFirst = self.scrollViewFirst.frame;
    CGRect frameScrollViewSecond = self.scrollViewSecond.frame;
    
    // Update the scroll frames so it fit entirely the component frame.
    self.scrollViewFirst.frame = CGRectMake(CGRectGetMinX(frameScrollViewFirst), CGRectGetMinY(frameScrollViewFirst), CGRectGetWidth(frameScrollComponent), CGRectGetHeight(frameScrollComponent));
    self.scrollViewSecond.frame = CGRectMake(CGRectGetMinX(frameScrollViewSecond), CGRectGetMinY(frameScrollViewSecond), CGRectGetWidth(frameScrollComponent), CGRectGetHeight(frameScrollComponent));
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Clear animators.
    [self.animatorBounceView removeAllBehaviors];
    [self.animatorHideView removeAllBehaviors];
}

#pragma mark - Public methods
- (UIScrollView *)currentScrollView
{
    return (scrollState == WAScrollGravitySwitchStateFirst) ? _scrollViewFirst : _scrollViewSecond;
}

#pragma mark - (UIScrollViewDelegate) methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    boolEndDragging = NO;
    [self enableScroll];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // If the contentView inside the scrollView isn't bigger than the scrollView bounds
    // we bypass the bounce scroll of the scrollView.
    if ( scrollView.contentOffset.y > 0.0f && (CGRectGetHeight(scrollView.frame) >= scrollView.contentSize.height) ) {
        scrollView.contentOffset = CGPointMake(0.0f, 0.0f);
    }

    // If the user "pull down" gesture is below a specified offset, we just replace the current view with a bounce animation.
    if (boolEndDragging && (scrollView.contentOffset.y >= WAPULLTOSWITCH_DEFAULT_SWITCH_LIMIT && scrollView.contentOffset.y < -0.0f)) {
        boolEndDragging = NO;
        
        // We bounce the current scroll.
        [self bounceCurrentScroll];
    }

    // If the user "pull down" gesture is above a specified offset, we switch between the two views.
    if (boolEndDragging && scrollView.contentOffset.y < WAPULLTOSWITCH_DEFAULT_SWITCH_LIMIT) {
        boolEndDragging = NO;
        [self switchScroll];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // We want animate our current view, with a bounce animation, only when the user
    // bounce scroll in "pull down" direction.
    if (scrollView.contentOffset.y < 0.0f) {
        boolEndDragging = YES;
    }
}

@end


#pragma mark - (Private) implementation
@implementation WAPullToSwitchViewController (Private)

#pragma mark - Scroll configuration
// Retrieve views and configuration data from dataSource and build the UIScrollView(s).
- (void)configureScrollViews
{
    if (self.dataSource) {
        // Request the two views which will be switched.
        UIView *viewOne = [self.dataSource viewForIndex:0];
        UIView *viewTwo = [self.dataSource viewForIndex:1];
        
        // Check if we have all the requested views.
        if (viewOne == nil || viewTwo == nil) {
            NSLog(@"ERROR - WAScrollGravitySwitchViewController : one of the scroll view requested is nil.");
        } else {
            self.scrollViewFirst = [self encapsulateViewInScrollView:viewOne];
            self.scrollViewSecond = [self encapsulateViewInScrollView:viewTwo];
            
            // Request for gravity/elasticity dataSource values.
            [self retrieveDataSourceConfiguration];
            
            // Add views to our component and present the first one.
            [self.view addSubview:self.scrollViewFirst];
            [self.view addSubview:self.scrollViewSecond];
            [self.view bringSubviewToFront:self.scrollViewFirst];
            
            // Change the origin of the first scroll to fit in position (0,0).
            CGRect frameScroll = self.scrollViewFirst.frame;
            frameScroll.origin.x = 0.0;
            frameScroll.origin.y = 0.0;
            self.scrollViewFirst.frame = frameScroll;
            
            // Change the origin of the second scroll to hide it.
            frameScroll = self.scrollViewSecond.frame;
            frameScroll.origin.x = 0.0;
            frameScroll.origin.y = CGRectGetHeight(self.view.frame);
            self.scrollViewSecond.frame = frameScroll;
            
            // Setup delegation.
            self.scrollViewFirst.delegate = self;
            self.scrollViewSecond.delegate = self;
        }
    } else {
        NSLog(@"ERROR - WAScrollGravitySwitchViewController : dataSource is nil. You must specified a dataSource before you can load the component view.");
    }
}

// Ask the dataSource for configurations values.
- (void)retrieveDataSourceConfiguration
{
    float requestedBounceGravity = 0.0f;
    float requestedHideGravity = 0.0f;
    float requestedBounceElasticity = 0.0f;
    
    if ([self.dataSource respondsToSelector:@selector(gravityVectorYComponentForBounce)]) {
        requestedBounceGravity = [self.dataSource gravityVectorYComponentForBounce];
    }
    
    if ([self.dataSource respondsToSelector:@selector(gravityVectorYComponentForHide)]) {
        requestedHideGravity = [self.dataSource gravityVectorYComponentForHide];
    }
    
    if ([self.dataSource respondsToSelector:@selector(elasticityCoefficientForBounce)]) {
        requestedBounceElasticity = [self.dataSource elasticityCoefficientForBounce];
    }
    
    bounceGravity = requestedBounceGravity != 0.0f ? requestedBounceGravity :  WAPULLTOSWITCH_DEFAULT_BOUNCE_GRAVITY;
    hideGravity = requestedHideGravity != 0.0f ? requestedHideGravity : WAPULLTOSWITCH_DEFAULT_HIDE_GRAVITY;
    bounceElasticity = requestedBounceElasticity != 0.0f ? requestedBounceElasticity : WAPULLTOSWITCH_DEFAULT_BOUNCE_ELASTICITY;
}


// Used to encapsulate a requested view from the dataSource in a UIScrollView.
- (UIScrollView *)encapsulateViewInScrollView:(UIView *)contentView
{
    // The scroll view will fill the component frame.
    UIScrollView *scrollViewContainer = [[UIScrollView alloc] initWithFrame:CGRectNull];
    
    // Configure the scrollView and add the contentView to it.
    scrollViewContainer.contentSize = contentView.frame.size;
    scrollViewContainer.alwaysBounceVertical = YES;
    scrollViewContainer.showsVerticalScrollIndicator = NO;
    scrollViewContainer.autoresizesSubviews = NO;
    [scrollViewContainer addSubview:contentView];
    
    return scrollViewContainer;
}

#pragma mark - Animation management
// Stop an animation and hide the correct UIScrollView.
- (void)resetAnimatorsAndUpdateCurrentScrollZIndex:(UIScrollView *)scrollView
{
    [_animatorHideView removeAllBehaviors];
    [_animatorBounceView removeAllBehaviors];
    [self.view bringSubviewToFront:scrollView];
}

// Bounce the current UIScrollView with a defined elasticity and a gravity effect.
- (void)bounceCurrentScroll
{
    UIScrollView *scrollView = [self currentScrollView];
    
    // Save the current offset.
    float yOffset = scrollView.contentOffset.y;
    // Move the origin of the scroll by the size of the offset.
    CGRect frameScroll = scrollView.frame;
    frameScroll.origin.y -= yOffset;
    scrollView.frame = frameScroll;
    
    // Create animation.
    UIDynamicAnimator* animator = [[UIDynamicAnimator alloc] init];
    
    // -- Gravity.
    UIGravityBehavior* gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[scrollView]];
    [gravityBehavior setGravityDirection:CGVectorMake(0.0, bounceGravity)];
    
    // -- Collision.
    UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[scrollView]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    CGRect frameSelfView = self.view.frame;
    // The collision will occured with the top border of the WAScrollGravitySwitchViewController (self) view.
    [collisionBehavior addBoundaryWithIdentifier:@"Segment" fromPoint:CGPointMake(0.0, -1.0) toPoint:CGPointMake(frameSelfView.size.width, -1.0)];

    // -- Properties : elasticity.
    UIDynamicItemBehavior* propertiesBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[scrollView]];
    propertiesBehavior.elasticity = bounceElasticity;
    
    [animator addBehavior:gravityBehavior];
    [animator addBehavior:collisionBehavior];
    [animator addBehavior:propertiesBehavior];
    
    // Fade in for the next displayed view.
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:1.0f];
    scrollView.alpha = 1.0f;
    [UIView commitAnimations];
    
    self.animatorBounceView = animator;
}

// Hide the current UIScrollView with a gravity effect.
- (void)hideCurrentScroll
{
    UIScrollView *scrollView = [self currentScrollView];

    // Get the scroll current offset and place his origin to this point.
    float yOffset = scrollView.contentOffset.y;
    CGRect frameScroll = scrollView.frame;
    frameScroll.origin.y -= yOffset - 20.0f;
    scrollView.frame = frameScroll;

    // Create animation.
    UIDynamicAnimator* animator = [[UIDynamicAnimator alloc] init];
    
    // -- Gravity.
    UIGravityBehavior* gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:@[scrollView]];
    [gravityBeahvior setGravityDirection:CGVectorMake(0.0, hideGravity)];
    
    // -- Collision.
    UICollisionBehavior* collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[scrollView]];
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    CGRect frameSelfView = self.view.frame;
    // The collision will occured with the top border of the WAScrollGravitySwitchViewController (self) view.
    float bottomStopLineY = frameSelfView.size.height + scrollView.frame.size.height + 50.0f;
    [collisionBehavior addBoundaryWithIdentifier:@"Segment" fromPoint:CGPointMake(0.0, bottomStopLineY) toPoint:CGPointMake(frameSelfView.size.width, bottomStopLineY)];
    
    [animator addBehavior:gravityBeahvior];
    [animator addBehavior:collisionBehavior];
    
    self.animatorHideView = animator;
    
    // Fade out for the hidden view.
    [UIView beginAnimations:@"FadeOut" context:nil];
    [UIView setAnimationDuration:1.0f];
    scrollView.alpha = 0.0f;
    [UIView commitAnimations];
}

- (void)enableScroll
{
    _scrollViewFirst.scrollEnabled = YES;
    _scrollViewSecond.scrollEnabled = YES;
}

- (void)disableScroll
{
    _scrollViewFirst.scrollEnabled = NO;
    _scrollViewSecond.scrollEnabled = NO;
}

// Switch between the active and inactive view with animation.
- (void)switchScroll
{
    // Disable gestures on scrollViews.
    [self disableScroll];
    // Hide the current scroll, animated.
    [self hideCurrentScroll];
    // Switch the state so that it reflects the current displayed scrollView.
    [self switchState];
    // Bounce the new active scrollView.
    [self bounceCurrentScroll];
}

#pragma mark - Attributes management
// Switch the state so that it reflects the current displayed scrollView.
- (void)switchState
{
    // Update the current state.
    scrollState = (scrollState == WAScrollGravitySwitchStateFirst) ? WAScrollGravitySwitchStateSecond : WAScrollGravitySwitchStateFirst;
}


@end



