//
//  SettingsViewController.h
//  NameGame
//
//  Created by Greg Fiore on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
{
    int numCategoriesEnabled;
}

- (IBAction)updateNumQuestions:(id)sender;
- (IBAction)updateTimer:(id)sender;

@end
