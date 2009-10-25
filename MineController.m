//
//  MineController.m
//  MacSweeper
//
//  Created by Morgan Conbere on 3/13/07.
//  Last edited by Morgan Conbere on 8/9/08.
//

#import "MineController.h"

static NSImage *initImage(NSString *name)
{
	// Grab the image from the iChat bundle. This would be easy if iChat didn't constantly change where the images were.
    // In Tiger, the images were in the main Resources folder named *.tiff
    // In Leopard, they renamed the files to *.tif
    // In Snow Leopard, they moved the files into a bundle named "Standard.smileypack"
	
	NSBundle *iChatBundle = [[NSBundle alloc] initWithPath:[[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.iChat"]];
	NSBundle *iChatSmileyBundle = [[NSBundle alloc] initWithPath:[NSString stringWithFormat:@"%@/%@", [iChatBundle builtInPlugInsPath], @"Standard.smileypack"]];

	NSString *imagePath = [iChatSmileyBundle pathForResource:[NSString stringWithFormat:@"%@.tif", name] ofType:nil];

	// Attempt to load the Leopard image location
	if (imagePath == nil) {
		imagePath = [iChatBundle pathForResource:[NSString stringWithFormat:@"%@.tif", name] ofType:nil];
	}

	// Attempt to load the Tiger image location
	if (imagePath == nil) {
		imagePath = [iChatBundle pathForResource:[NSString stringWithFormat:@"%@.tiff", name] ofType:nil];
	}

	[iChatSmileyBundle release];
	[iChatBundle release];

	NSImage *image = [[NSImage alloc] initWithContentsOfFile:imagePath];
    [image setName:name];
	return image;
}

@implementation MineController

@synthesize questions;
@synthesize customRows;
@synthesize customColumns;
@synthesize customMines;

- (void)awakeFromNib
{
    NSString *name = @"MacSweeperMainWindow";
    [mainWindow setFrameAutosaveName:name];
    [mainWindow setFrameUsingName:name];
    
    [NSApp setDelegate:self];

    // Set up image names
    // image names are:
    //  "smile" - smile.tif, default image
    //  "gasp"  - gasp.tif, mouse down image
    //  "frown" - frown.tif, game lost image
    //  "yuck"  - yuck.tif, game won image
    // images are borrowed from iChat, thus the names
	
    initImage(@"smile");    
    initImage(@"gasp");
    initImage(@"frown");
    initImage(@"yuck");

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
    
    [toggleQuestionsMenuItem setState:self.questions];
    
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
            currentSettings.rows = self.customRows;
            currentSettings.columns = self.customColumns;
            currentSettings.mines = self.customMines;
            break;
        default:
            NSLog(@"Bad GameType %d, using beginner game.", currentGameType);
            currentSettings = kBeginnerGame;
            break;
    }
    
    [mineView setTimerField:timerField andMinesLeftField:minesLeftField];
    [mineView setDelegate:self];
    [mineView newGameWithMines:currentSettings.mines
                          rows:currentSettings.rows
                       columns:currentSettings.columns
                     questions:self.questions];
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
    [NSApp beginSheet:customGameSheet 
       modalForWindow:mainWindow 
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:nil];
     
    [NSApp runModalForWindow:customGameSheet];
    
    [NSApp endSheet:customGameSheet];
    [customGameSheet orderOut:self];
}

- (IBAction)newCustomGame:(id)sender
{
    [NSApp stopModal];

    NSFormCell *customRowsCell = [customForm cellAtIndex:0];
    NSFormCell *customColumnsCell = [customForm cellAtIndex:1];
    NSFormCell *customMinesCell = [customForm cellAtIndex:2];
    
    self.customRows = [customRowsCell intValue];
    self.customColumns = [customColumnsCell intValue];
    self.customMines = [customMinesCell intValue];
    
    currentGameType = kCustom;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInt:kCustom] forKey:@"GameType"];
    [defaults setObject:[NSNumber numberWithInt:self.customRows] forKey:@"CustomRows"];
    [defaults setObject:[NSNumber numberWithInt:self.customColumns] forKey:@"CustomColumns"];
    [defaults setObject:[NSNumber numberWithInt:self.customMines] forKey:@"CustomMines"];
    
    [self newGame:nil];
}

- (IBAction)cancelCustomGame:(id)sender
{
    [NSApp stopModal];
}

- (void)endGameWithTime:(int)seconds win:(BOOL)win
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
    self.questions = !self.questions;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.questions forKey:@"Questions"];

    [self newGame:nil];
}

- (void)setDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // If settings are not present, give sane defaults
    if (![defaults objectForKey:@"GameType"])
        [defaults setObject:[NSNumber numberWithInt:kBeginner] forKey:@"GameType"];
    if (![defaults objectForKey:@"Questions"])
        [defaults setBool:YES forKey:@"Questions"];
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
    self.questions = [defaults boolForKey:@"Questions"];
    
    // Set default custom game settings
    self.customRows = [defaults integerForKey:@"CustomRows"];
    self.customColumns = [defaults integerForKey:@"CustomColumns"];
    self.customMines = [defaults integerForKey:@"CustomMines"];
    
    NSFormCell *customRowsCell = [customForm cellAtIndex:0];
    NSFormCell *customColumnsCell = [customForm cellAtIndex:1];
    NSFormCell *customMinesCell = [customForm cellAtIndex:2];
    
    [customRowsCell setObjectValue:[NSNumber numberWithInt:self.customRows]];
    [customColumnsCell setObjectValue:[NSNumber numberWithInt:self.customColumns]];
    [customMinesCell setObjectValue:[NSNumber numberWithInt:self.customMines]];
 
    // Set default high scores
    NSArray *highScoreNames = [defaults objectForKey:@"HighScoreNames"];
    NSArray *highScoreScores = [defaults objectForKey:@"HighScoreScores"];
    
    for (int difficulty = 0; difficulty < 3; ++difficulty)
    {
        HighScore *scores = scoreList[difficulty];
        
        for (int tag = 0; tag < 3; ++tag)
        {
            scores[tag].name = [highScoreNames objectAtIndex:(difficulty * 3 + tag)];
            scores[tag].score = [[highScoreScores objectAtIndex:(difficulty * 3 + tag)] intValue];;
        }
    }  
}

- (void)setHighScores
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *tempNames = [defaults objectForKey:@"HighScoreNames"];
    NSArray *tempScores = [defaults objectForKey:@"HighScoreScores"];
    NSMutableArray *highScoreNames = [NSMutableArray arrayWithCapacity:9];
    [highScoreNames addObjectsFromArray:tempNames];
    NSMutableArray *highScoreScores = [NSMutableArray arrayWithCapacity:9];
    [highScoreScores addObjectsFromArray:tempScores];
    
    for (int difficulty = 0; difficulty < 3; ++difficulty)
    {
        HighScore *scores = scoreList[difficulty];
        
        for (int tag = 0; tag < 3; ++tag)
        {
            [highScoreNames replaceObjectAtIndex:(difficulty * 3 + tag) withObject:scores[tag].name];
            [highScoreScores replaceObjectAtIndex:(difficulty * 3 + tag) withObject:[NSNumber numberWithInt:scores[tag].score]];
        }
    } 
    
    [defaults setObject:highScoreNames forKey:@"HighScoreNames"];
    [defaults setObject:highScoreScores forKey:@"HighScoreScores"];    
    
    for (int difficulty = 0; difficulty < 3; ++difficulty)
    {
        NSForm *form = formList[difficulty];
        HighScore *scores = scoreList[difficulty];
        
        for (int tag = 0; tag < 3; ++tag)
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
            timerField = [[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, width, height)];
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
    } else if ([itemIdentifier isEqualToString:@"MinesLeftItem"]) {
        if (!minesLeftField) {
            minesLeftField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, width, height)];
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
    } else if ([itemIdentifier isEqualToString:@"SmileyItem"]) {
        int smileySize = 18;
        if (!smileyView) {
            smileyView = [[SmileyImageView alloc] initWithFrame:NSMakeRect(0, 0, smileySize, smileySize)];
            smileyView.delegate = self;
            [smileyView setImage:[NSImage imageNamed:@"smile"]];
            [smileyView setTarget:self];
        }
        
        [item setView:smileyView];
        
        [item setMinSize:NSMakeSize(smileySize, smileySize)];
        [item setMaxSize:NSMakeSize(smileySize, smileySize)];

        [item setLabel:@""];
        [item setPaletteLabel:@"Status Display"];
        [item setTarget:self];
        [item setAction:@selector(newGame:)];
    }
    
    return [item autorelease];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:@"MinesLeftItem",  
                                     @"SmileyItem",
                                     @"TimerItem",
                                     NSToolbarFlexibleSpaceItemIdentifier, nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:@"MinesLeftItem", NSToolbarFlexibleSpaceItemIdentifier,
                                     @"SmileyItem", NSToolbarFlexibleSpaceItemIdentifier,
                                     @"TimerItem", nil];
}

- (void)newHighScoreWithDifficulty:(GameType)game andTime:(int)timeToComplete
{
    NSString *gameTypeString = nil;
    if (game == kBeginner) gameTypeString = @"Beginner";
    else if (game == kIntermediate) gameTypeString = @"Intermediate";
    else if (game == kExpert) gameTypeString = @"Expert";
    else return;
    
    [[newHighScoreForm cellAtIndex:0] setStringValue:gameTypeString];
    [[newHighScoreForm cellAtIndex:1] setIntValue:timeToComplete];
    
    [NSApp beginSheet:newHighScoreSheet 
       modalForWindow:mainWindow 
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:nil];
    
    [NSApp runModalForWindow:newHighScoreSheet];
    
    [NSApp endSheet:newHighScoreSheet];
    [newHighScoreSheet orderOut: self];
    
    HighScore *scores = scoreList[game];
    
    int properPosition = -1;
    for (int i = 0; i < 3; ++i)
    {
        if ([scores[i].name isEqualToString:@""] || scores[i].score >= timeToComplete)
        {
            properPosition = i;
            break;
        }
    }
    if (properPosition == -1)
        return;
    
    for (int i = 2; i >= 0; --i)
    {
        if (i >= properPosition && i < 2)
            scores[i+1] = scores[i];
        if (i == properPosition)
        {
            scores[i].name = [[newHighScoreForm cellAtIndex:2] stringValue];
            scores[i].score = timeToComplete;
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

- (void)SmileyImageViewMouseDown
{
    [self mouseDownAction];
}

- (void)SmileyImageViewMouseUp
{
    [self mouseUpAction];
    [self newGame:self];
}

@end
