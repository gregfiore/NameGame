//
//  HomeViewController.h
//  NameGame
//
//  Created by Greg Fiore on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "GameViewController.h"
#import "HowToViewController.h"

@interface HomeViewController : UIViewController
{
    SettingsViewController *settingsViewController;
    GameViewController *gameViewController;
    HowToViewController *howToViewController;
}

- (IBAction)startButton:(id)sender;
- (IBAction)settingsButton:(id)sender;
- (IBAction)howToButton:(id)sender;

@end
