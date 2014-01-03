//
//  GameViewController.h
//  NameGame
//
//  Created by Greg Fiore on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController
{
    NSMutableArray *currentClues;   // Current clues left in the game
    NSMutableArray *allClues;              // All available clues in a fresh game (with these settings)
    NSMutableArray *gameClues;      // All clues in the game
    
    NSTimer *pollingTimer;
    int timerStart;     // Timer starting value
    double timerValue;     // Current value of the timer
    int team1Score;        // Score for Team #1
    int team2Score;        // Score for Team #2
    int roundNumber;       // Current round number
    int gameQuestions;     // Number of questions in the game
    int currentQuestion;   // Current question in the game
    int currentTeam;      // Current team (0 for team #1)
    int gameState;
    BOOL gameActive;       // Is the current game running
    
    IBOutlet UIButton *pauseButton;
    IBOutlet UIButton *nextButton;
}




@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITextField *team1ScoreLabel;
@property (nonatomic, retain) IBOutlet UITextField *team2ScoreLabel;
@property (nonatomic, retain) IBOutlet UILabel *roundLabel;
@property (nonatomic, retain) IBOutlet UILabel *clueLabel;
@property (nonatomic, retain) IBOutlet UILabel *directionsLabel;
@property (nonatomic, retain) IBOutlet UILabel *headerLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIButton *pauseButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;

@property (nonatomic, retain) IBOutlet UIView *containerView;

- (IBAction)nextButton:(id)sender;
- (IBAction)pauseButton:(id)sender;

@end
