//
//  MineController.m
//  MacSweeper
//
//  Created by Morgan Conbere on 3/13/07.
//  Last edited by Morgan Conbere on 8/9/08.
//

#import "MineController.h"

static NSImage * initImage(NSString *path, NSString *name)
{
	/*
	 iChat changed the file ending from .tiff to .tif, to support both OSs
	 without doing any weird checks, try one, and then the other if there
	 is a failure.
	 */
	NSString *tiger = @".tiff";
	NSString *leopard = @".tif";
	
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", path, [name stringByAppendingString:leopard] ] ];
	
	if(image == nil)
	{
		image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", path, [name stringByAppendingString:tiger] ] ];	
	}
	
	return image;
}

@implementation MineController

- (void)awakeFromNib
{
    NSString *name = @"MacSweeperMainWindow";
    [mainWindow setFrameAutosaveName:name];
    [mainWindow setFrameUsingName:name];
    
    [NSApp setDelegate:self];

    /* Set up image names */
    /* image names are:
        "smile" - smile.tiff, default image
        "gasp"  - gasp.tiff, mouse down image
        "frown" - frown.tiff, game lost image
        "yuck"  - yuck.tiff, game won image
       images are borrowed from iChat, thus the names
     */
    NSString *appPath = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.iChat"];
    NSString *path = [NSString stringWithFormat:@"%@/%@", appPath, @"Contents/Resources" ];
	
    NSImage *smile = initImage(path, @"smile");
    [smile setName:@"smile"];
    
    NSImage *gasp = initImage(path, @"gasp");
    [gasp setName:@"gasp"];
    
    NSImage *frown = initImage(path, @"frown");
    [frown setName:@"frown"];
    
    NSImage *yuck = initImage(path, @"yuck");
    [yuck setName:@"yuck"];
    
    scoreList[0] = beginnerScores;
    scoreList[1] = intermediateScores;
    scoreList[2] = expertScores;
    formList[0] = beginnerForm;
    formList[1] = intermediateForm;
    formList[2] = expertForm;
    
    [self setDefaults];
    [self setToolbar];
    
    [self newGame:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)myApp
{
    return YES;
}

- (IBAction)newGame:(id)sender
{
    [smileyView setImage:[NSImage imageNamed:@"smile"]];   
    int menuState[4] = {NSOffState, NSOffState, NSOffState, NSOffState};
    menuState[currentGameType] = NSOnState;
    
    [beginnerMenuItem setState:menuState[kBeginner]];
    [intermediateMenuItem setState:menuState[kIntermediate]];
    [expertMenuItem setState:menuState[kExpert]];
    [customMenuItem setState:menuState[kCustom]];
    
    [toggleQuestionsMenuItem setState:questions];
    
    GameSettings currentSettings;
    
    switch (currentGameType)
    {
        case kBeginner:
            currentSettings = kBeginnerGame;
            break;
        case kIntermediate:
            currentSettings = kIntermediateGame;
            break;
        case kExpert:
            currentSettings = kExpertGame;
            break;
        case kCustom:
            currentSettings.rows = customRows;
            currentSettings.columns = customColumns;
            currentSettings.mines = customMines;
            break;
        default:
            NSLog(@"Bad GameType %d, using beginner game.", currentGameType);
            currentSettings = kBeginnerGame;
    }
    
    [mineView setTimerField:timerField andMinesLeftField:minesLeftField];
    [mineView setDelegate:self];
    [mineView newGameWithMines:currentSettings.mines
                          rows:currentSettings.rows
                       columns:currentSettings.columns
                     questions:questions];
}

- (IBAction)beginnerGame:(id)sender
{    
    currentGameType = kBeginner;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:kBeginner] forKey:@"GameType"];
    
    [self newGame:nil];
}

- (IBAction)intermediateGame:(id)sender
{
    currentGameType = kIntermediate;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:kIntermediate] forKey:@"GameType"];
    
    [self newGame:nil];
}

- (IBAction)expertGame:(id)sender
{
    currentGameType = kExpert;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:kExpert] forKey:@"GameType"];
    
    [self newGame:nil];
}

- (IBAction)customGame:(id)sender
{
    [NSApp beginSheet: customGameSheet 
       modalForWindow: mainWindow 
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
     
    [NSApp runModalForWindow: customGameSheet];
    
    [NSApp endSheet: customGameSheet];
    [customGameSheet orderOut: self];
}

- (IBAction)newCustomGame:(id)sender
{
    [NSApp stopModal];

    NSFormCell *customRowsCell = [customForm cellAtIndex:0];
    NSFormCell *customColumnsCell = [customForm cellAtIndex:1];
    NSFormCell *customMinesCell = [customForm cellAtIndex:2];
    
    customRows = [customRowsCell intValue];
    customColumns = [customColumnsCell intValue];
    customMines = [customMinesCell intValue];
    
    currentGameType = kCustom;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:kCustom] forKey:@"GameType"];
    [defaults setObject:[NSNumber numberWithInt:customRows] forKey:@"CustomRows"];
    [defaults setObject:[NSNumber numberWithInt:customColumns] forKey:@"CustomColumns"];
    [defaults setObject:[NSNumber numberWithInt:customMines] forKey:@"CustomMines"];
    
    [self newGame:nil];
}

- (IBAction)cancelCustomGame:(id)sender
{
    [NSApp stopModal];
}

- (void)endGameWithTime:(int)seconds win:(bool)win
{
    if (win)
        [smileyView setImage:[NSImage imageNamed:@"yuck"]];
    else
        [smileyView setImage:[NSImage imageNamed:@"frown"]];
    
    if (win && currentGameType < kCustom)
    {
        HighScore curr = scoreList[currentGameType][2];
        if (seconds <= curr.score || [curr.name isEqualToString:@""])
        {
            [self newHighScoreWithDifficulty:currentGameType andTime:seconds];
        }
    }
}

- (IBAction)toggleQuestions:(id)sender
{
    questions = !questions;
    
    [self newGame:nil];
}

- (void)setDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // If settings are not present, give sane defaults
    if (![defaults objectForKey:@"GameType"])
        [defaults setObject:[NSNumber numberWithInt:kBeginner] forKey:@"GameType"];
    if (![defaults objectForKey:@"Questions"])
        [defaults setObject:@"YES" forKey:@"Questions"];
    if (![defaults objectForKey:@"CustomRows"])
        [defaults setObject:[NSNumber numberWithInt:16] forKey:@"CustomRows"];
    if (![defaults objectForKey:@"CustomColumns"])
        [defaults setObject:[NSNumber numberWithInt:30] forKey:@"CustomColumns"];
    if (![defaults objectForKey:@"CustomMines"])
        [defaults setObject:[NSNumber numberWithInt:99] forKey:@"CustomMines"];
    if (![defaults objectForKey:@"HighScoreNames"] || ![defaults objectForKey:@"HighScoreScores"])
    {
        NSArray *highScoreNames = [NSArray arrayWithObjects:
            @"", @"", @"", 
            @"", @"", @"",
            @"", @"", @"",
            nil];
        
        NSArray *highScoreScores = [NSArray arrayWithObjects:
            [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], 
            [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
            [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
            nil];
        
        [defaults setObject:highScoreNames forKey:@"HighScoreNames"];
        [defaults setObject:highScoreScores forKey:@"HighScoreScores"];
    }
    
    // Set default game type
    currentGameType = [defaults integerForKey:@"GameType"];
    if (currentGameType > 4 || currentGameType < 0)
    {
        NSLog(@"Bad defaults value for GameType.");
        currentGameType = kBeginner;
        [defaults setObject:[NSNumber numberWithInt:kBeginner] forKey:@"GameType"];
    }
    
    // Set default questions state
    questions = [defaults boolForKey:@"Questions"];
    
    // Set default custom game settings
    customRows = [defaults integerForKey:@"CustomRows"];
    customColumns = [defaults integerForKey:@"CustomColumns"];
    customMines = [defaults integerForKey:@"CustomMines"];
    
    NSFormCell *customRowsCell = [customForm cellAtIndex:0];
    NSFormCell *customColumnsCell = [customForm cellAtIndex:1];
    NSFormCell *customMinesCell = [customForm cellAtIndex:2];
    
    [customRowsCell setObjectValue:[NSNumber numberWithInt:customRows]];
    [customColumnsCell setObjectValue:[NSNumber numberWithInt:customColumns]];
    [customMinesCell setObjectValue:[NSNumber numberWithInt:customMines]];
 
    // Set default high scores
    int difficulty, tag;
    NSArray *highScoreNames = [defaults objectForKey:@"HighScoreNames"];
    NSArray *highScoreScores = [defaults objectForKey:@"HighScoreScores"];
    
    for (difficulty = 0; difficulty < 3; ++difficulty)
    {
        HighScore *scores = scoreList[difficulty];
        
        for (tag = 0; tag < 3; ++tag)
        {
            scores[tag].name = [highScoreNames objectAtIndex:(difficulty*3+tag)];
            scores[tag].score = [[highScoreScores objectAtIndex:(difficulty*3+tag)] intValue];;
        }
    }  
}

- (void)setHighScores
{
    int difficulty, tag;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempNames = [defaults objectForKey:@"HighScoreNames"];
    NSArray *tempScores = [defaults objectForKey:@"HighScoreScores"];
    NSMutableArray *highScoreNames = [NSMutableArray arrayWithCapacity:9];
    [highScoreNames addObjectsFromArray:tempNames];
    NSMutableArray *highScoreScores = [NSMutableArray arrayWithCapacity:9];
    [highScoreScores addObjectsFromArray:tempScores];
    
    for (difficulty = 0; difficulty < 3; ++difficulty)
    {
        HighScore *scores = scoreList[difficulty];
        
        for (tag = 0; tag < 3; ++tag)
        {
            [highScoreNames replaceObjectAtIndex:(difficulty*3+tag) withObject:scores[tag].name];
            [highScoreScores replaceObjectAtIndex:(difficulty*3+tag) withObject:[NSNumber numberWithInt:scores[tag].score]];
        }
    } 
    
    [defaults setObject:highScoreNames forKey:@"HighScoreNames"];
    [defaults setObject:highScoreScores forKey:@"HighScoreScores"];    
    
    for (difficulty = 0; difficulty < 3; ++difficulty)
    {
        NSForm *form = formList[difficulty];
        HighScore *scores = scoreList[difficulty];
        
        for (tag = 0; tag < 3; ++tag)
        {
            NSFormCell *cell = [form cellAtIndex:tag];
            if (![scores[tag].name isEqualToString:@""])
            {
                [cell setEnabled:YES];
                [cell setTitle:scores[tag].name];
                [cell setIntValue:scores[tag].score];
            }
            else
            {
                [cell setEnabled:NO];
                [cell setTitle:@"None"];
                [cell setStringValue:@""];
            }
        }
    }
    
}

- (void)setToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
    [mainWindow setToolbar:[toolbar autorelease]];
}

- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar itemForItemIdentifier:(NSString*)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    // Settings for larger, square text (good fit, but not as pretty)
    /*
    NSControlSize size = NSSmallControlSize;
    int height = 19;
    int width = 38;
    NSTextFieldBezelStyle style = NSTextFieldSquareBezel;
    */
    // Settings for smaller, rounded text (pretty, but too small)
    
    NSControlSize size = NSMiniControlSize;
    int height = 15;
    int width = 44;
    NSTextFieldBezelStyle style = NSTextFieldRoundedBezel;
    
    
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    
    if ( [itemIdentifier isEqualToString:@"TimerItem"] ) {
        if (!timerField) {
            timerField = [[NSTextField alloc] initWithFrame: NSMakeRect(0,0,width,height)];
            float fontSize = [NSFont systemFontSizeForControlSize:size];
            NSCell *cell = [timerField cell];
            NSFont *font = [NSFont fontWithName:[[cell font] fontName] size:fontSize];
            [cell setFont:font];
            //[cell setControlSize:size];
            [timerField sizeToFit];
            [timerField setEditable:NO];
            [timerField setBezeled:YES];
            [timerField setBezelStyle:style];
            [timerField setAlignment:NSCenterTextAlignment];
            [timerField setStringValue:@"0"];
        }
        
        [item setView: timerField];
        
        [item setMinSize: NSMakeSize(width, height)];
        [item setMaxSize: NSMakeSize(width, height)];
        
        [item setLabel: @"Time"];
        [item setPaletteLabel: @"Time Elapsed Counter"];
        [item setToolTip: @"Time Elapsed"];
    } else if ( [itemIdentifier isEqualToString:@"MinesLeftItem"] ) {
        if (!minesLeftField) {
            minesLeftField = [[NSTextField alloc] initWithFrame: NSMakeRect(0,0,width,height)];
            float fontSize = [NSFont systemFontSizeForControlSize:size];
            NSCell *cell = [minesLeftField cell];
            NSFont *font = [NSFont fontWithName:[[cell font] fontName] size:fontSize];
            [cell setFont:font];
            //[cell setControlSize:size];
            [minesLeftField sizeToFit];
            [minesLeftField setEditable:NO];
            [minesLeftField setBezeled:YES];
            [minesLeftField setBezelStyle:style];
            [minesLeftField setAlignment:NSCenterTextAlignment];
            [minesLeftField setStringValue:@"99"];
        }
        
        [item setView: minesLeftField];
        
        [item setMinSize: NSMakeSize(width, height)];
        [item setMaxSize: NSMakeSize(width, height)];
        
        [item setLabel: @"Mines"];
        [item setPaletteLabel: @"Mines Left Counter"];
        [item setToolTip: @"Mines Left"];
    } else if ( [itemIdentifier isEqualToString:@"SmileyItem"] ) {
        /*
        SmileyView *smileyView = [[SmileyView alloc] initWithFrame: NSMakeRect(0,0,18,18)];
        [smileyView setDelegate: self];
         */
        int smileySize = 18;
        if (!smileyView) {
            smileyView = [[NSImageView alloc] initWithFrame: NSMakeRect(0,0,smileySize,smileySize)];
            [smileyView setImage:[NSImage imageNamed:@"smile"]];
            [smileyView setTarget: self];
        }
        
        [item setView: smileyView];
        
        [item setMinSize: NSMakeSize(smileySize,smileySize)];
        [item setMaxSize: NSMakeSize(smileySize,smileySize)];

        [item setLabel: @""];
        [item setPaletteLabel: @"Status Display"];
        [item setTarget: self];
        [item setAction: @selector(newGame:)];
    }
    
    return [item autorelease];
}

- (NSArray*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:@"MinesLeftItem",  
                                     @"SmileyItem",
                                     @"TimerItem",
                                     NSToolbarFlexibleSpaceItemIdentifier, nil];
}

- (NSArray*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:@"MinesLeftItem", NSToolbarFlexibleSpaceItemIdentifier,
                                     @"SmileyItem", NSToolbarFlexibleSpaceItemIdentifier,
                                     @"TimerItem", nil];
}

- (void)newHighScoreWithDifficulty:(GameType)game andTime:(int)time
{
    NSString *gameTypeString = nil;
    if (game == kBeginner) gameTypeString = @"Beginner";
    else if (game == kIntermediate) gameTypeString = @"Intermediate";
    else if (game == kExpert) gameTypeString = @"Expert";
    else return;
    
    [[newHighScoreForm cellAtIndex:0] setStringValue:gameTypeString];
    [[newHighScoreForm cellAtIndex:1] setIntValue:time];
    
    [NSApp beginSheet: newHighScoreSheet 
       modalForWindow: mainWindow 
        modalDelegate: nil
       didEndSelector: nil
          contextInfo: nil];
    
    [NSApp runModalForWindow: newHighScoreSheet];
    
    [NSApp endSheet: newHighScoreSheet];
    [newHighScoreSheet orderOut: self];
    
    HighScore *scores = scoreList[game];
    
    int properPosition = -1;
    int i;
    for (i = 0; i < 3; ++i)
    {
        if ([scores[i].name isEqualToString:@""] || scores[i].score >= time)
        {
            properPosition = i;
            break;
        }
    }
    if (properPosition == -1)
        return;
    
    for (i = 2; i >=0; --i)
    {
        if (i >= properPosition && i < 2)
            scores[i+1] = scores[i];
        if (i == properPosition)
        {
            scores[i].name = [[newHighScoreForm cellAtIndex:2] stringValue];
            scores[i].score = time;
            break;
        }
    }
    
    [self setHighScores];
}

- (IBAction)saveNewHighScore:(id)sender
{
    saveScore = YES;
    [NSApp stopModal];
}

- (IBAction)cancelNewHighScore:(id)sender
{
    saveScore = NO;
    [NSApp stopModal];
}

- (IBAction)showHighScores:(id)sender
{
    [self setHighScores];
    
    NSString *name = @"MacSweeperHighScoresPanel";
    [highScoresPanel setFrameAutosaveName:name];
    [highScoresPanel setFrameUsingName:name];
    
    [highScoresPanel makeKeyAndOrderFront:nil];
}

- (void)mouseDownAction
{
    [smileyView setImage:[NSImage imageNamed:@"gasp"]];
}

- (void)mouseUpAction
{
    [smileyView setImage:[NSImage imageNamed:@"smile"]];
}

@end
