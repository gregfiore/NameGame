//
//  SettingsViewController.m
//  NameGame
//
//  Created by Greg Fiore on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

#define SectionHeaderHeight 200

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripescreen.png"]];
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    //self.navigationItem.title = @"Settings";
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor]; // change this color
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(@"Settings", @"");
    [label sizeToFit];
    
    numCategoriesEnabled = 0;
    // Count the number of categories currently enabled
    NSMutableDictionary *categories = [[NSUserDefaults standardUserDefaults] objectForKey:@"categories"];
    for (NSString *key in categories) {
        NSString *value = [categories objectForKey:key];
        if ([value isEqualToString:(NSString *)@"On"]) {
            //NSLog(@"%@ is disabled",key);
            numCategoriesEnabled += 1;
        }
    }
    
    NSLog(@"%i categories enabled",numCategoriesEnabled);
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"categories"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stripescreen.png"]];
    // Check for a reusable cell first, use that if it exists
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    // If there is no reusable cell of this type, create a new one
    if (!cell) {
        cell = [[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSMutableDictionary *categories = [[NSUserDefaults standardUserDefaults] objectForKey:@"categories"]; 
    NSArray *allKeys = [categories allKeys];
    [[cell textLabel] setText:[allKeys objectAtIndex:[indexPath row]]];
    NSString *categoryValue = [categories objectForKey:[allKeys objectAtIndex:[indexPath row]]];
    if ([categoryValue isEqualToString:(NSString *)@"On"]) {
        //NSLog(@"%@ is disabled",key);
        // This element is turned on
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Is this checked right now or not?
    NSMutableDictionary *categories = [[[NSUserDefaults standardUserDefaults] objectForKey:@"categories"] mutableCopy]; 
    NSArray *allKeys = [categories allKeys];
    NSString *categoryValue = [categories objectForKey:[allKeys objectAtIndex:[indexPath row]]];
    if ([categoryValue isEqualToString:(NSString *)@"On"]) {
        //NSLog(@"%@ is disabled",key);
        // This element is on, it should now be disabled
        if (numCategoriesEnabled == 1) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" 
                                                            message:@"You need at least one category selected to have any clues to play with." 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
    }
        numCategoriesEnabled -= 1;
        [categories setObject:@"Off" forKey:[allKeys objectAtIndex:[indexPath row]]];
         NSLog(@"%i categories enabled",numCategoriesEnabled);
    } else {
        [categories setObject:@"On" forKey:[allKeys objectAtIndex:[indexPath row]]];
        numCategoriesEnabled += 1;
         NSLog(@"%i categories enabled",numCategoriesEnabled);
    }
    [[NSUserDefaults standardUserDefaults] setObject:categories forKey:@"categories"];
    [tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, SectionHeaderHeight)];
    
    tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"stripescreen.png"]];

    // Add label for "Number of clues"
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, tableView.bounds.size.width, 25)];
    [label1 setTextColor:[UIColor darkGrayColor]];
    [label1 setBackgroundColor:[UIColor clearColor]];
    [label1 setTextAlignment:UITextAlignmentCenter];
    [label1 setText:@"Clues Per Round"];
    [headerView addSubview:label1];
    
    // Add segementd control for "Number of clues"
    NSArray *segmentedText1 = [NSArray arrayWithObjects:@"10",@"20",@"30", nil];
    UISegmentedControl *segmentedControl1 = [[UISegmentedControl alloc] initWithItems:segmentedText1];
    int numQuestions = [[[NSUserDefaults standardUserDefaults] objectForKey:@"numQuestions"] intValue];
    
    switch (numQuestions) {
        case 10:
            segmentedControl1.selectedSegmentIndex = 0;
            break;
        case 20:
            segmentedControl1.selectedSegmentIndex = 1;
            break;
        case 30:
            segmentedControl1.selectedSegmentIndex = 2;
            break;
    }
    
    //segmentedControl1.selectedSegmentIndex = 0;
    segmentedControl1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    segmentedControl1.segmentedControlStyle = UISegmentedControlStylePlain;
    segmentedControl1.frame = CGRectMake(0, 40, tableView.bounds.size.width, 40);
    UIFont *font = [UIFont boldSystemFontOfSize:18.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:UITextAttributeFont];
    [segmentedControl1 setTitleTextAttributes:attributes 
                                    forState:UIControlStateNormal];
    [segmentedControl1 addTarget:self action:@selector(updateNumQuestions:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:segmentedControl1];
    
    // Add label for "Timer Value"
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, tableView.bounds.size.width, 25)];
    [label2 setTextColor:[UIColor darkGrayColor]];
    [label2 setBackgroundColor:[UIColor clearColor]];
    [label2 setTextAlignment:UITextAlignmentCenter];
    [label2 setText:@"Time Per Round"];
    [headerView addSubview:label2];
    
    // Add segementd control for Timer
    NSArray *segmentedText2 = [NSArray arrayWithObjects:@"30",@"60",@"90", nil];
    UISegmentedControl *segmentedControl2 = [[UISegmentedControl alloc] initWithItems:segmentedText2];
    int timerStart = [[[NSUserDefaults standardUserDefaults] objectForKey:@"timerStart"] intValue];

    switch (timerStart) {
        case 30:
            segmentedControl2.selectedSegmentIndex = 0;
            break;
        case 60:
            segmentedControl2.selectedSegmentIndex = 1;
            break;
        case 90:
            segmentedControl2.selectedSegmentIndex = 2;
            break;
    }
    //segmentedControl2.selectedSegmentIndex = 0;
    segmentedControl2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    segmentedControl2.segmentedControlStyle = UISegmentedControlStylePlain;
    segmentedControl2.frame = CGRectMake(0, 120, tableView.bounds.size.width, 40);
    UIFont *font2 = [UIFont boldSystemFontOfSize:18.0f];
    NSDictionary *attributes2 = [NSDictionary dictionaryWithObject:font2
                                                           forKey:UITextAttributeFont];
    [segmentedControl2 setTitleTextAttributes:attributes2 
                                     forState:UIControlStateNormal];
    [segmentedControl2 addTarget:self action:@selector(updateTimer:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:segmentedControl2];
    
    // Add label for "Categories"
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 170, tableView.bounds.size.width, 25)];
    [label3 setTextColor:[UIColor darkGrayColor]];
    [label3 setBackgroundColor:[UIColor clearColor]];
    [label3 setTextAlignment:UITextAlignmentCenter];
    [label3 setText:@"Clue Categories"];
    [headerView addSubview:label3];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return SectionHeaderHeight;
}

- (IBAction)updateNumQuestions:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl*) sender;
    switch ([segmentedControl selectedSegmentIndex]) {
        case 0:
            [[NSUserDefaults standardUserDefaults]  setObject:[NSNumber numberWithInt:10] forKey:@"numQuestions"];
            //NSLog(@"Updated numQuestions to 10");
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults]  setObject:[NSNumber numberWithInt:20] forKey:@"numQuestions"];
            //NSLog(@"Updated numQuestions to 20");
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults]  setObject:[NSNumber numberWithInt:30] forKey:@"numQuestions"];
            //NSLog(@"Updated numQuestions to 30");
            break;
        default:
            NSLog(@"Error: improper index for segmented control selection of number of questions");
            break;
    }
        
}

- (IBAction)updateTimer:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl*) sender;
    switch ([segmentedControl selectedSegmentIndex]) {
        case 0:
            [[NSUserDefaults standardUserDefaults]  setObject:[NSNumber numberWithInt:30] forKey:@"timerStart"];
            //NSLog(@"Updated numQuestions to 30");
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults]  setObject:[NSNumber numberWithInt:60] forKey:@"timerStart"];
            //NSLog(@"Updated numQuestions to 60");
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults]  setObject:[NSNumber numberWithInt:90] forKey:@"timerStart"];
            //NSLog(@"Updated numQuestions to 90");
            break;
        default:
            NSLog(@"Error: improper index for segmented control selection of timer length");
            break;
    }
}

@end
