//
//  MineController.h
//  MacSweeper
//
//  Created by Morgan Conbere on 3/13/07.
//
#pragma once

#import <Cocoa/Cocoa.h>
#import "MineView.h"
#import "SmileyImageView.h"

typedef enum {
    kBeginner = 0,
    kIntermediate = 1,
    kExpert = 2,
    kCustom = 3
} GameType;

typedef struct {
    int rows;
    int columns;
    int mines;
} GameSettings;

typedef struct {
    NSString *name;
    int score;
} HighScore;

static const GameSettings kBeginnerGame = {9, 9, 10};
static const GameSettings kIntermediateGame = {16, 16, 40};
static const GameSettings kExpertGame = {16, 30, 99};

@interface MineController : NSWindowController <MineFieldDelegate, SmileyImageViewDelegate> {
@private
    // Main minesweeper view
    IBOutlet MineView *mineView;
    
    // Windows and panels
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSPanel *customGameSheet;
    IBOutlet NSPanel *newHighScoreSheet;
    IBOutlet NSPanel *highScoresPanel;
    
    // Custom game cells
    IBOutlet NSForm *customForm;
    
    // High Scores Forms
    IBOutlet NSForm *beginnerForm;
    IBOutlet NSForm *intermediateForm;
    IBOutlet NSForm *expertForm;    

    // New High Score Form
    IBOutlet NSForm *newHighScoreForm;
    
    // Menu items
    IBOutlet NSMenuItem *beginnerMenuItem;
    IBOutlet NSMenuItem *intermediateMenuItem;
    IBOutlet NSMenuItem *expertMenuItem;
    IBOutlet NSMenuItem *customMenuItem;
    
    IBOutlet NSMenuItem *toggleQuestionsMenuItem;
    
    // Toolbar item views
    NSTextField *timerField;
    NSTextField *minesLeftField;
    SmileyImageView *smileyView;

    // Current game state
    GameType currentGameType;
    
    // Properties
    BOOL questions;
    int customRows;
    int customColumns;
    int customMines;

    // High Scores
    HighScore beginnerScores[3];
    HighScore intermediateScores[3];
    HighScore expertScores[3];
    bool saveScore;
    HighScore *scoreList[3];
    NSForm *formList[3];
}

@property BOOL questions;
@property int customRows;
@property int customColumns;
@property int customMines;

- (IBAction)newGame:(id)sender;

- (IBAction)beginnerGame:(id)sender;
- (IBAction)intermediateGame:(id)sender;
- (IBAction)expertGame:(id)sender;

- (IBAction)customGame:(id)sender;
- (IBAction)newCustomGame:(id)sender;
- (IBAction)cancelCustomGame:(id)sender;

- (void)endGameWithTime:(int)seconds win:(BOOL)win;

- (void)newHighScoreWithDifficulty:(GameType)game andTime:(int)time;
- (IBAction)saveNewHighScore:(id)sender;
- (IBAction)cancelNewHighScore:(id)sender;

- (IBAction)showHighScores:(id)sender;

- (IBAction)toggleQuestions:(id)sender;

- (void)setDefaults;
- (void)setToolbar;

- (void)mouseDownAction;
- (void)mouseUpAction;

// Toolbar delegation
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar;

- (void)SmileyImageViewMouseDown;
- (void)SmileyImageViewMouseUp;

@end
