//
//  SLViewController.m
//  FlexibleView
//
//  Created by Li Shuo on 05/26/13.
//  Copyright (c) 2013 com.menic. All rights reserved.
//

#import "SLViewController.h"
#import "SLFlexibleView.h"
#import "UIColor+FlatUI.h"
#import "UIFont+FlatUI.h"
#import "UIImage+FlatUI.h"
#import <FUIButton.h>
@interface SLViewController ()

@end

@implementation SLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIView *flexibleView = [[UIView alloc] initWithFrame:self.view.bounds];
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
    flexibleView.declaration = @{
            @"subviews":@[
                   @{
                            @"class":[UIView class],
                            @"frame":@[@0, @0, @-1, @44],
                            @"backgroundColor":[UIColor clearColor],
                            @"tag":@4,
                            @"declaration":@{
                                    @"subviews":@[
                                        @{
                                            @"object":(UIButton *)^(){
                                                UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
                                                button.backgroundColor = [UIColor midnightBlueColor];
                                                [button  setImage:
                                                                [UIImage imageNamed:@"pacman.png"] forState:UIControlStateNormal];
                                                return button;
                                            }(),
                                                @"frame":@[@0, @0, @44, @-1],
                                                @"tag":@12,

                                        },
                                        @{
                                                @"object":(UITextField *)^(){
                                            UITextField *field = [[UITextField alloc] init];
                                            field.backgroundColor = [UIColor cloudsColor];
                                            return field;
                                        }(),
                                                @"frame":@[@"follow", @"last", @-100, @"follow"],
                                                @"tag":@11,
                                        },
                                        @{
                                                @"object":(UIButton*)^(){
                                            FUIButton* button = [FUIButton buttonWithType:UIButtonTypeCustom];
                                            button.buttonColor = [UIColor peterRiverColor];
                                            button.shadowColor = [UIColor belizeHoleColor];
                                            button.cornerRadius = 0.0f;
                                            button.shadowHeight = 3.0f;

                                            [button setTitle:@"Click" forState:UIControlStateNormal];
                                            button.titleLabel.font = [UIFont boldFlatFontOfSize:16];
                                            [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateNormal];
                                            [button setTitleColor:[UIColor cloudsColor] forState:UIControlStateHighlighted];
                                            return button;
                                        }(),
                                                @"frame":@[@"follow", @"follow", @60, @"follow"],
                                                @"touchUpInside":^(id sender){
                                                    UIButton *button = sender;
                                                    UITextField *textField = (UITextField *)[button.superview viewWithTag:11];
                                                    NSLog(@"%@ input", textField.text);
                                                }
                                        }
                                    ]
                            }
                    },
            ]
    };
    [flexibleView loadSubviews];

    [self.view addSubview:flexibleView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end