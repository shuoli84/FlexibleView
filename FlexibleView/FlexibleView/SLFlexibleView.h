//
// Created by Li Shuo on 13-5-26.
// Copyright (c) 2013 com.menic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

/**
* FlexibleView is designed to create the ui layout in a declaration way. All position of subviews
 * can be absolute and relative.
 *
 * @warning:*todo* the changes of attributes should be animatable.
 *
 * There are several ways to specify the positions of subviews:
 * 1. Through absolute points.
 * 2. Relative points to super view.
 * 3. Relative points to last view. The same x, different y means align vertical.
 * 4. Grid, column and row.
 *
 * The final product looks like this:
 *
 *     self.view.declaration = @{
 *         @"columns":@5,                       //Grid layout, inspired by bootstrap, now
 *                                                 row is specified by y, no row supported yet
 *         @"subviews":@[
 *           @{@"class":[UIButton class],     //The class used to create the control object (deprecated)
 *           or
 *           @"object":[UIButton buttonWithType:RoundRectButton], //The object passed in
 *           @"tag":@0,
 *           @"frame":@[@10, @20, @-0.5, @-0.2], //absolute position 10,20, width 50% of the superview, height 20% of
 *                                         the superview
 *           @"touchUpInside":^(id sender){NSLog(@"touched");},
 *           @"tintColor":[UIColor blueColor]},
 *         @{@"class":[UILabel class],
 *           @"frame":@[@-0.5, @20, @-0.5, @-0.2], // stands next to the last button
 *           @"text":@"hello world"},
 *         @{@"class":[UIView class],
 *           @"frame":@[@"offset2",30,@"span3",-1], // offset2 sets the x to bounds.width * 2/columns,
 *                                                  span3 sets width * 3/columns
 *           @"clip":@YES,                     // clip indicate whether we should clip the subview's frame, if clip, the
 *                                            relative part will be calculated
 *           @"declaration":
 *             @{},                             // nested sub view declaration.
 *          }],
 *     };
 *
 * In a declarative way, object can be created as
 *
 *     @"object" = (UIView*)^(){UIView *view = ....; //setup code return view;}()
 *
 *
*/
@interface UIView(SLFlexibleView)

/**
* declaration of subviews
*/
@property (nonatomic, copy) NSDictionary *declaration;

/**
* method which loads subviews, it is recommended that all subview instance created outside, no new object created
* in this method.
*/
-(void)loadSubviews;
@end