//
//  GameViewController.m
//  NameGame
//
//  Created by Greg Fiore on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import "NSMutableArray+Shuffle.h"
#import "CircleCounterView.h"
#import <AudioToolbox/AudioToolbox.h>

@interface GameViewController ()

@end

@implementation GameViewController

@synthesize timeLabel, team1ScoreLabel, team2ScoreLabel, roundLabel, clueLabel, directionsLabel, headerLabel, pauseButton, nextButton, containerView;
@synthesize window = _window;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"stripe_background.png"]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated
{
    // This is a new game
    
    // Load in the names plist
    NSString *errorDesc = nil;
    NSPropertyListFormat format;
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"Names.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle] pathForResource:@"Names" ofType:@"plist"];
    }
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSDictionary *temp = (NSDictionary *)[NSPropertyListSerialization
                                          propertyListFromData:plistXML
                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                          format:&format
                                          errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
    }
    
    // Assemble the allClues array from the selected categories
    allClues = [[NSMutableArray alloc] init];
    NSUserDefaults *gameSettings = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *categories = [gameSettings objectForKey:@"categories"];
    for (NSString *key in categories) {
        NSString *value = [categories objectForKey:key];
        //NSLog(@"%@ = %@",key,value);
        if ([value isEqualToString:(NSString *)@"On"]) {
            // This element is turned on
            [allClues addObjectsFromArray:[temp objectForKey:key]];
        } else {

        }
    }
    
    if ([allClues count] == 0) {
        NSLog(@"Error, no categories are enabled");
    }
    
    // Need to recycle the game conditions here...
    
    if (pollingTimer) {
        [pollingTimer invalidate];
        pollingTimer = nil;
    }
    
    pollingTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(pollTime) userInfo:nil repeats:YES];
    
    timerStart = [[gameSettings objectForKey:@"timerStart"] intValue];
    timerValue = (double)timerStart;
    team1Score = 0;
    team2Score = 0;
    roundNumber = 1;
    gameQuestions =  [[gameSettings objectForKey:@"numQuestions"] intValue];
    currentQuestion = 1;
    currentTeam = 1;  
    gameActive = NO;    
    gameState = 3;

    [clueLabel setText:@"Blue Team!\nYou're up!"];
    [nextButton setTitle:@"Start" forState:UIControlStateNormal];
    [timeLabel setText:[NSString stringWithFormat:@"%.1f",timerValue]];
    [team1ScoreLabel setText:[NSString stringWithFormat:@"%d",team1Score]];
    [team2ScoreLabel setText:[NSString stringWithFormat:@"%d",team2Score]];
    [roundLabel setText:@"Round 1"];
    [pauseButton setHidden:NO];
    [pauseButton setTitle:@"Quit" forState:UIControlStateNormal];
    
    [clueLabel setText:[NSString stringWithFormat:@"Round %d!",roundNumber]];
    [roundLabel setText:[NSString stringWithFormat:@"Round %d", roundNumber]];
    
    [headerLabel setText:[NSString stringWithFormat:@"Team 1 is up!"]];
    
    [pauseButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -80.0, 0.0, 0.0)];
    [pauseButton setTitle:@"Quit" forState:UIControlStateNormal];
    [nextButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -210.0, 0.0, 0.0)];
    [nextButton setTitle:@"Start" forState:UIControlStateNormal];
    [directionsLabel setHidden:YES];
    [headerLabel setHidden:NO];
    
    // Trim gameClues to be the size of the number of clues
    gameClues = [allClues mutableCopy];
    [gameClues shuffle];
    NSRange theRange;
    theRange.location = gameQuestions;
    theRange.length = [gameClues count]-gameQuestions;
    [gameClues removeObjectsInRange:theRange];
    currentClues = [gameClues mutableCopy];
    
    // DO THE PIE DRAWING
    for (UIView *subView in [containerView subviews])
    {
        [subView removeFromSuperview];
    }
    
    CGSize size = CGSizeMake(100, 100);
    CGRect frame = CGRectInset(containerView.bounds, 
                               (CGRectGetWidth(containerView.bounds) - size.width)/2.0f, 
                               (CGRectGetHeight(containerView.bounds) - size.height)/2.0f);
    
    
    CircleCounterView *circleView = [[CircleCounterView alloc] initWithFrame:frame];
    [self.containerView addSubview:circleView];
    
    // Set the variables
    [circleView setTimerStart:timerStart];
    [circleView setTimerValue:timerValue];
    
    [circleView setNeedsDisplay];
    
}


- (void) pollTime
{
    if (gameActive) {
        timerValue -= 0.1;
                
        if (timerValue < 0) {
            timerValue = 0;
            // Play the buzzer sound
            CFBundleRef mainBundle = CFBundleGetMainBundle();
            CFURLRef soundFileURLRef;
            soundFileURLRef = CFBundleCopyResourceURL(mainBundle, (CFStringRef)@"Buzzer2", CFSTR ("mp3"), NULL);
            UInt32 soundID;
            AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
            AudioServicesPlaySystemSound(soundID);
            
            gameState = 4;
            // Update the screen for the next team
            gameActive = NO;  // Pause the timer
            [headerLabel setText:@"Time's up!"];
            if (currentTeam == 1) {
                // Set up for the next team
                [clueLabel setText:[NSString stringWithFormat:@"Red Team!\nYou're up!"]];
                currentTeam = 2;       
            } else {
                [clueLabel setText:[NSString stringWithFormat:@"Blue Team!\nYou're up!"]];
                currentTeam = 1;
            }
            
            [directionsLabel setHidden:YES];  // Hide the directions label
            [nextButton setTitle:@"Start!" forState:UIControlStateNormal];  // set the title of the button
            [pauseButton setTitle:@"Quit" forState:UIControlStateNormal];  // set the title of the pause button
            
        }
        [timeLabel setText:[NSString stringWithFormat:@"%.1f",timerValue]];
        
        // DO THE PIE DRAWING
        for (UIView *subView in [containerView subviews])
        {
            [subView removeFromSuperview];
        }
        
        CGSize size = CGSizeMake(100, 100);
        CGRect frame = CGRectInset(containerView.bounds, 
                                   (CGRectGetWidth(containerView.bounds) - size.width)/2.0f, 
                                   (CGRectGetHeight(containerView.bounds) - size.height)/2.0f);
        
        
        CircleCounterView *circleView = [[CircleCounterView alloc] initWithFrame:frame];
        [self.containerView addSubview:circleView];
        
        // Set the variables
        [circleView setTimerStart:(float)timerStart];
        [circleView setTimerValue:timerValue];
        
        [circleView setNeedsDisplay];
                
    }
}

- (IBAction)nextButton:(id)sender
{
    // Need to determine what the game state is, to take the right course of action
    if (gameState == 1) {
            // Is the game running and the next button should increment the point for the team and show the next question
            
            
            if (currentTeam == 1) {
                // Team 1 is up
                team1Score += 1;
                [team1ScoreLabel setText:[NSString stringWithFormat:@"%d",team1Score]];
            } else {
                // Team 2 is up
                team2Score += 1;
                [team2ScoreLabel setText:[NSString stringWithFormat:@"%d",team2Score]];
            }

            if (currentQuestion >= gameQuestions) {
                // The round is over
                
                // Play the round over sound
                CFBundleRef mainBundle = CFBundleGetMainBundle();
                CFURLRef soundFileURLRef;
                soundFileURLRef = CFBundleCopyResourceURL(mainBundle, (CFStringRef)@"GameshowBellDing3", CFSTR ("mp3"), NULL);
                UInt32 soundID;
                AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
                AudioServicesPlaySystemSound(soundID);
                
                // Determine if the game is over...
                if (roundNumber == 3) {
                    // The game is over
                    CFBundleRef mainBundle = CFBundleGetMainBundle();
                    CFURLRef soundFileURLRef;
                    soundFileURLRef = CFBundleCopyResourceURL(mainBundle, (CFStringRef)@"applause", CFSTR ("mp3"), NULL);
                    UInt32 soundID;
                    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
                    AudioServicesPlaySystemSound(soundID);
                    gameActive = NO;
                    gameState = 5;
                    if (team1Score == team2Score) {
                        // We have a tie
                        [clueLabel setText:@"It's a tie!"];
                    } else if (team1Score > team2Score) {
                        // Team 1 wins
                        [clueLabel setText:@"Blue Team Wins!"];
                    } else {
                        // Team 2 wins
                        [clueLabel setText:@"Red Team Wins!"];
                    }
                    [headerLabel setText:@"Game Over!"];
                    [directionsLabel setHidden:YES];
                    [nextButton setTitle:[NSString stringWithFormat:@"Play Again"] forState:UIControlStateNormal];
                    [pauseButton setTitle:@"Quit" forState:UIControlStateNormal];
                    [nextButton setTitle:@"Play\nAgain" forState:UIControlStateNormal];
    
                } else {
                    // The round is changing but the game isn't over
                    gameState = 3;                
                    gameActive = NO;
                    roundNumber += 1;
                    [clueLabel setText:[NSString stringWithFormat:@"Round %d!",roundNumber]];
                    [roundLabel setText:[NSString stringWithFormat:@"Round %d", roundNumber]];
                    if (roundNumber == 1) {
                        [directionsLabel setText:@""];
                    } else if (roundNumber == 2) {
                        [directionsLabel setText:@"(Silently act it out)"];
                    } else {
                        [directionsLabel setText:@"(One word only)"];
                    }          
                    [directionsLabel setHidden:NO];
                    if (currentTeam == 1) {
                        [headerLabel setText:[NSString stringWithFormat:@"Blue Team is still up!"]];
                    } else {
                        [headerLabel setText:[NSString stringWithFormat:@"Red Team is still up!"]];
                    }
                    [pauseButton setTitle:@"Quit" forState:UIControlStateNormal];
                    [nextButton setTitle:@"Start" forState:UIControlStateNormal];
                }
            } else {
                // Display the next clue
                // Remove this clue from the array
                [currentClues removeObjectAtIndex:0];
                // Show the next clue
                [clueLabel  setText:[currentClues objectAtIndex:0]];
                currentQuestion += 1;
            }
    } else if (gameState == 2) {
        // The game is paused and the start button will resume the game
        [clueLabel setText:[currentClues objectAtIndex:0]];
        [directionsLabel setHidden:NO];
        [headerLabel setHidden:NO];
        if (roundNumber == 1) {
            [directionsLabel setHidden:YES];
        } else if (roundNumber == 2) {
            [directionsLabel setHidden:NO];
            [directionsLabel setText:@"...by silently acting it out"];
        } else {
            [directionsLabel setHidden:NO];
            [directionsLabel setText:@"...with ONE word"];
        }
        [headerLabel setText:@"Get your team to guess..."];
        [pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [nextButton setTitle:@"Next" forState:UIControlStateNormal];
        gameActive = YES;
        gameState = 1;
    } else if (gameState == 3) {
        // The game had a round swap and the start button will resume the game
        // Need to reset the clues array and shuffle it
        currentClues = [gameClues mutableCopy];
        [currentClues shuffle];
         //NSLog(@"currentClues = %@",currentClues);
        currentQuestion = 1;
        [clueLabel setText:[currentClues objectAtIndex:0]];
        if (roundNumber == 1) {
            [directionsLabel setHidden:YES];
        } else if (roundNumber == 2) {
            [directionsLabel setHidden:NO];
            [directionsLabel setText:@"...by silently acting it out"];
        } else {
            [directionsLabel setHidden:NO];
            [directionsLabel setText:@"...with ONE word"];
        }
        [headerLabel setText:@"Get your team to guess..."];
        [pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [nextButton setTitle:@"Next" forState:UIControlStateNormal];
        gameActive = YES;
        gameState = 1;
    } else if (gameState == 4) {
        // The game had a team swap (timer expired) and the start button will resume the game
        // shuffle the clues for the next team
        timerValue = (double)timerStart;
        [currentClues shuffle];
        [clueLabel setText:[currentClues objectAtIndex:0]];
        if (roundNumber == 1) {
            [directionsLabel setHidden:YES];
        } else if (roundNumber == 2) {
            [directionsLabel setHidden:NO];
            [directionsLabel setText:@"...by silently acting it out"];
        } else {
            [directionsLabel setHidden:NO];
            [directionsLabel setText:@"...with ONE word"];
        }
        [headerLabel setHidden:NO];
        [headerLabel setText:@"Get your team to guess..."];
        [pauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        [nextButton setTitle:@"Next" forState:UIControlStateNormal];
        gameActive = YES;
        gameState = 1;
    } else if (gameState == 5) {
        // The game has ended and the play again game will recycle the teams
        // reset the settings
        // Trim gameClues to be the size of the number of clues
        gameClues = [allClues mutableCopy];
        [gameClues shuffle];
        NSRange theRange;
        theRange.location = gameQuestions;
        theRange.length = [gameClues count]-gameQuestions;
        [gameClues removeObjectsInRange:theRange];
        currentClues = [gameClues mutableCopy];
       // NSLog(@"gameClues = %@",gameClues);
        
        timerValue = (double)timerStart;
        team1Score = 0;
        team2Score = 0;
        roundNumber = 1;
        currentQuestion = 1;
        currentTeam = 1;  // indexed from zero
        gameActive = NO;    
        gameState = 3;
        
        [clueLabel setText:@"Blue Team!\nYou're up!"];
        [nextButton setTitle:@"Start" forState:UIControlStateNormal];
        [timeLabel setText:[NSString stringWithFormat:@"%.1f",timerValue]];
        [team1ScoreLabel setText:[NSString stringWithFormat:@"%d",team1Score]];
        [team2ScoreLabel setText:[NSString stringWithFormat:@"%d",team2Score]];
        [roundLabel setText:@"Round 1"];
        [pauseButton setHidden:NO];
        [directionsLabel setHidden:YES];
        [pauseButton setTitle:@"Quit" forState:UIControlStateNormal];
    } else {
        NSLog(@"Error: Unrecognized gameState (%d) when ""nextButton"" pressed",gameState);
    }

}

- (IBAction)pauseButton:(id)sender
{
    if (gameState == 1) {
        // Pause button pressed in game play
        gameState = 2;
        [clueLabel setText:@"Paused"];
        [headerLabel setHidden:YES];
        [directionsLabel setHidden:YES];
        [pauseButton setTitle:@"Quit" forState:UIControlStateNormal];
        [nextButton setTitle:@"Resume" forState:UIControlStateNormal];
        gameActive = NO;
    } else {
        // The pause button is a Quit button and the game should quit
        // Recycle the game for the next time
        currentClues = gameClues;
        [currentClues shuffle];
        
        timerValue = (double)timerStart;
        team1Score = 0;
        team2Score = 0;
        roundNumber = 1;
        currentQuestion = 1;
        currentTeam = 0;  // indexed from zero
        gameActive = NO;    
        gameState = 3;
        
        [clueLabel setText:@"Blue Team!\nYou're up!"];
        [nextButton setTitle:@"Start" forState:UIControlStateNormal];
        [timeLabel setText:[NSString stringWithFormat:@"%.1f",timerValue]];
        [team1ScoreLabel setText:[NSString stringWithFormat:@"%d",team1Score]];
        [team2ScoreLabel setText:[NSString stringWithFormat:@"%d",team2Score]];
        [roundLabel setText:@"Round 1"];
        [pauseButton setHidden:NO];
        [pauseButton setTitle:@"Quit" forState:UIControlStateNormal];
        [headerLabel setHidden:NO];
        [directionsLabel setHidden:NO];
        
        [self.navigationController popToRootViewControllerAnimated:YES];

    }
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
