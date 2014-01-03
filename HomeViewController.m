//
//  HomeViewController.m
//  NameGame
//
//  Created by Greg Fiore on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeViewController.h"
#import "SettingsViewController.h"
#import "GameViewController.h"
#import "HowToViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"homescreen.png"]];
        
        // Determine if this is the first time the app is running, if so, set the settings to default
        NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];  
        if (![settings objectForKey:@"numQuestions"]) {
            [settings setObject:[NSNumber numberWithInt:10] forKey:@"numQuestions"];
            [settings setObject:[NSNumber numberWithInt:60] forKey:@"timerStart"];
        
            NSMutableDictionary *categories = [[NSMutableDictionary alloc] init];
            [categories setObject:@"On" forKey:@"General"];
            [categories setObject:@"On" forKey:@"Hollywood"];
            [categories setObject:@"Off" forKey:@"Music"];
            [categories setObject:@"Off" forKey:@"History"];
            [categories setObject:@"Off" forKey:@"Sports"];
            [settings setObject:categories forKey:@"categories"]; 
        }
        
    }
    return self;
}

- (IBAction)startButton:(id)sender
{
    if (!gameViewController) {
        gameViewController = [[GameViewController alloc] init];
    }
    
    // Push it onto the top of the navigation controller's stack
    [[self navigationController] pushViewController:gameViewController animated:YES];
    
}


- (IBAction)settingsButton:(id)sender
{
    if (!settingsViewController) {
        settingsViewController = [[SettingsViewController alloc] init];
    }
        
    // Push it onto the top of the navigation controller's stack
    [[self navigationController] pushViewController:settingsViewController animated:YES];
}


- (IBAction)howToButton:(id)sender
{
    if (!howToViewController) {
        howToViewController = [[HowToViewController alloc] init];
    }
    
    // Push it onto the top of the navigation controller's stack
    [[self navigationController] pushViewController:howToViewController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
