//
//  AppDelegate.h
//  NameGame
//
//  Created by Greg Fiore on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    HomeViewController *homeViewController;
}

@property (strong, nonatomic) UIWindow *window;

@end
