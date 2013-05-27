//
// Created by Li Shuo on 13-5-26.
// Copyright (c) 2013 com.menic. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <CoreGraphics/CoreGraphics.h>
#import "SLFlexibleView.h"
#import "DDLog.h"
#import "UIControl+BlocksKit.h"
#import "NSObject+AssociatedObjects.h"
#import "NSString+Ruby.h"
#import "NSArray+BlocksKit.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;
static char kSubviewDeclarationKey;

@implementation UIView(SLFlexibleView)
-(void)setDeclaration:(NSDictionary *)declaration {
    [self associateCopyOfValue:declaration withKey:&kSubviewDeclarationKey];
}

-(NSDictionary *)declaration {
    return [self associatedValueForKey:&kSubviewDeclarationKey];
}

-(void)loadSubviews {
    if(self.declaration == nil){
        return;
    }

    NSDictionary *declaration = self.declaration;

    //Get current view's frame, which is the baseline of all position calculation
    CGRect frame = self.frame;
    DDLogVerbose(@"current view's frame %@", NSStringFromCGRect(frame));

    //Get grid information
    int columns = 1;
    if (declaration[@"columns"]){
        columns = [declaration[@"columns"] integerValue];
    }

    //All subviews
    NSArray *subviews = declaration[@"subviews"];

    CGFloat lastFrameCompontents[4] = {0.0f};
    UIView *widthFlexibleView = nil;
    UIView *heightFlexibleView = nil;
    for (int i = 0; i < subviews.count; ++i){
        NSDictionary *viewDict = subviews[i];
        UIView *view = nil;

        //Is it provided an object or just a class
        if(viewDict[@"object"]){
            view = viewDict[@"object"];
        }
        else if(viewDict[@"class"]){
            id class = viewDict[@"class"];
            if([class isKindOfClass:[NSString class]]){
                view = [[NSClassFromString(class) alloc]init];
            }
            else{
                view = [[class alloc] init];
            }
        }
        else{
            DDLogError(@"Don't know how to create the subview object, neither object nor class found");
            continue;
        }
        DDLogVerbose(@"view object %@ created or received", view);

        //Add tag
        if(viewDict[@"tag"]){
            view.tag = [viewDict[@"tag"] integerValue];
            DDLogVerbose(@"Set view tag as %d", view.tag);
        }

        //Calculate the position
        NSArray *frameComponents = viewDict[@"frame"];
        if (frameComponents) {
            DDLogVerbose(@"there are %d frame components", frameComponents.count);
            assert(frameComponents.count == 4);

            CGFloat floatValues[4] = {0.0f};
            CGFloat frameValues[4] = {frame.size.width, frame.size.height, frame.size.width, frame.size.height};
            for (int frameComponentIndex = 0; frameComponentIndex < frameComponents.count; ++frameComponentIndex) {
                id frameComponentValue = frameComponents[frameComponentIndex];
                if([frameComponentValue isKindOfClass:[NSNumber class]]) {
                    CGFloat value = [frameComponentValue floatValue];
                    if(value >= 0){
                        floatValues[frameComponentIndex] = value;
                    }
                    else if (value >= -1 ){
                        floatValues[frameComponentIndex] = frameValues[frameComponentIndex] * value * -1;
                    }
                    else{
                        floatValues[frameComponentIndex] = frameValues[frameComponentIndex] + value;
                    }
                }
                else if([frameComponentValue isKindOfClass:[NSString class]]) {
                    // The format of the string should be span3,offset3
                    NSString *stringValue = (NSString *)frameComponentValue;

                    // Both span and offset's value are the same, just make sure they appear in the right position
                    // 4 frames, first is offset, the third one is span
                    if([stringValue startsWith:@"span",nil] || [stringValue startsWith:@"offset",nil]){
                        NSInteger val = [[[stringValue substituteAll:@"span" with:@""] substituteAll:@"offset" with:@""] integerValue];
                        floatValues[frameComponentIndex] = frameValues[frameComponentIndex] / columns * val;

                        DDLogVerbose(@"%@ converted to %f", stringValue, floatValues[frameComponentIndex]);
                    }
                    else if ([stringValue isEqualToString:@"last"]){
                        floatValues[frameComponentIndex] = lastFrameCompontents[frameComponentIndex];
                        DDLogVerbose(@"last converted to %f", floatValues[frameComponentIndex]);
                    }
                    else if ([stringValue isEqualToString:@"follow"]){
                        floatValues[frameComponentIndex] = frameComponentIndex < 2 ?
                                (lastFrameCompontents[frameComponentIndex] + lastFrameCompontents[2-frameComponentIndex]):
                                lastFrameCompontents[frameComponentIndex];
                        DDLogVerbose((@"follow converted to %f"), floatValues[frameComponentIndex]);
                    }
                    else if ([stringValue isEqualToString:@"flexible"]){
                        //Flexible means fill the space. One view can only have one flexible subview
                        switch(frameComponentIndex){
                            case 0:
                            case 1:
                                DDLogError(@"Flexible only valid for width and height");
                                break;
                            case 2:
                                widthFlexibleView = view;
                                break;
                            case 3:
                                heightFlexibleView = view;
                                break;
                            default:
                                DDLogError(@"invalid frame index");
                                break;
                        }
                    }
                }
                else{
                    DDLogError(@"Types other than NSNumber not supported yet");
                }
            }

            CGFloat *lp = lastFrameCompontents;
            CGFloat *lc = floatValues;
            while (lp - lastFrameCompontents < 4) {
                *lp++ = *lc++;
            }

            CGRect normalizedFrame = CGRectMake(floatValues[0], floatValues[1], floatValues[2], floatValues[3]);
            DDLogInfo(@"view's frame: %@", NSStringFromCGRect(normalizedFrame));

            view.frame = normalizedFrame;
        }
        else{
            DDLogError(@"frame not provided");
        }

        if(viewDict[@"touchUpInside"]){
            if([view isKindOfClass:[UIControl class]]){
                UIControl *uiControl = (UIControl *)view;
                [uiControl addEventHandler:viewDict[@"touchUpInside"] forControlEvents:UIControlEventTouchUpInside];
            }
            else{
                DDLogError(@"Only UIControl subclass support touchUpInside");
            }
        }

        if(viewDict[@"declaration"]){
            view.declaration = viewDict[@"declaration"];
            [view loadSubviews];
        }

        if(viewDict[@"backgroundColor"]){
            view.backgroundColor = viewDict[@"backgroundColor"];
        }

        [self addSubview:view];
    }

    if(widthFlexibleView){
        NSNumber *width = [self.subviews reduce:@0.0f withBlock:^id(id sum, id obj) {
            UIView *subview = obj;
            return [NSNumber numberWithFloat:[sum floatValue] + subview.bounds.size.width];
        }];

        CGRect frame = widthFlexibleView.frame;
        frame.size.width = self.bounds.size.width - [width floatValue];
        widthFlexibleView.frame = frame;
    }

    if(heightFlexibleView){
         NSNumber *height = [self.subviews reduce:@0.0f withBlock:^id(id sum, id obj) {
            UIView *subview = obj;
            return [NSNumber numberWithFloat:[sum floatValue] + subview.bounds.size.height];
        }];

        CGRect frame = widthFlexibleView.frame;
        frame.size.height = self.bounds.size.height - [height floatValue];
        heightFlexibleView.frame = frame;
    }
}
@end