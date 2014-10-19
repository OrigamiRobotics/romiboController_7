//
//  FetchPalettesFromRomiboWebViewController.m
//  romiboController_7
//
//  Created by Daniel Brown on 10/1/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import "FetchPalettesFromRomiboWebViewController.h"
#import "UserPalettesManager.h"
#import "RomibowebAPIManager.h"
#import "UIColor+GSAdditions.h"

@interface FetchPalettesFromRomiboWebViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *paletteOptionsSegmentedControl;
@property (strong, nonatomic) IBOutlet UILabel *allPalettesInfoLabel;
@property (strong, nonatomic) IBOutlet UITableView *paletteSelectorTableView;
@property (nonatomic, weak)UserPalettesManager* palettesManager;

@property (strong, nonatomic) IBOutlet UIView *allPalettesInfoViewContainer;
@property (strong, nonatomic) IBOutlet UILabel *palettesInfoBackgroundLabel;

@property (strong, nonatomic) IBOutlet UIButton *fetchButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UILabel *connectionStatusLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) IBOutlet UIView *mainContainerForWidgets;
@property (strong, nonatomic) IBOutlet UILabel *numberOfSelectedPalettesLabel;

@property (nonatomic, strong)NSMutableDictionary* myPaletteIds;
@property (strong, nonatomic) NSArray* paletteTitles;
@property (assign, nonatomic)NSInteger selectedPaletteOption;
@property (strong, nonatomic) NSMutableSet* palettesSelectedToFetch;
@property (strong, nonatomic) NSDictionary* fetchedPalettes;

@property (strong, nonatomic) IBOutlet UITableView *fetchedPalettesTableView;
- (IBAction)fetchPalettesButtonClicked:(UIButton *)sender;
- (IBAction)palettesOptionSelected:(UISegmentedControl *)sender;

@end

@implementation FetchPalettesFromRomiboWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  self.paletteOptionsSegmentedControl.selectedSegmentIndex = 0;
  self.selectedPaletteOption = 0;
  [self.paletteSelectorTableView setHidden:YES];
  [self.spinner stopAnimating];
  [self initializePalettesManager];
  
  //UI specific
  //set Palettes listing tableview background color
  self.paletteSelectorTableView.backgroundView = nil;
  CGFloat red   = 232.0f/255.0f;
  CGFloat green = 247.0f/255.0f;
  CGFloat blue  = 252.0f/255.0f;
  self.paletteSelectorTableView.backgroundColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
  self.palettesSelectedToFetch  = [[NSMutableSet alloc] init];
  self.fetchedPalettesTableView.tableFooterView = [[UIView alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Buttons Clicked
- (IBAction)fetchPalettesButtonClicked:(UIButton *)sender
{
  [self.spinner startAnimating];
  [self.connectionStatusLabel setHidden:NO];
  [(UIButton *)sender setHidden:YES];
  [self.cancelButton setHidden:YES];
  [self.paletteOptionsSegmentedControl setUserInteractionEnabled:NO];
  
  [self registerAsRomiboWebManagerObserver];
  
  //connect to RomiboWeb and attempt to fetch requested palettes
  RomibowebAPIManager *apiManager = [RomibowebAPIManager sharedRomibowebManagerInstance];
  [apiManager getUserPalettesFromRomiboWeb];
}

- (IBAction)palettesOptionSelected:(UISegmentedControl *)sender
{
  self.selectedPaletteOption = [sender selectedSegmentIndex];
  if ([sender selectedSegmentIndex] == 1) {//specific
    [self.paletteSelectorTableView setHidden:NO];
    [self.numberOfSelectedPalettesLabel setHidden:NO];
    [self.palettesInfoBackgroundLabel setHidden:YES];
    [self.allPalettesInfoLabel setHidden:YES];
    [self.allPalettesInfoViewContainer setHidden:YES];
    if ([self.palettesSelectedToFetch count] > 0){
      [self.fetchButton setHidden:NO];
    } else {
      [self.fetchButton setHidden:YES];
    }
  } else {//all
    [self.paletteSelectorTableView setHidden:YES];
    [self.numberOfSelectedPalettesLabel setHidden:YES];
    [self.palettesInfoBackgroundLabel setHidden:NO];
    [self.allPalettesInfoLabel setHidden:NO];
    [self.allPalettesInfoViewContainer setHidden:NO];
    [self.fetchButton setHidden:NO];
  }
}

#pragma mark - Palettes stuff

-(void) initializePalettesManager
{
  self.myPaletteIds = [[NSMutableDictionary alloc] init];
  
  if (self.palettesManager == NULL)
    self.palettesManager = [UserPalettesManager sharedPalettesManagerInstance];
  
  [self.palettesManager loadPalettes];
  self.paletteTitles = [self.palettesManager paletteTitles];
}

#pragma mark - Palettes List Table delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString * cellIdentifier = @"paletteListViewCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  if (cell == nil)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  }
 
  if (tableView == self.paletteSelectorTableView){
    UIView* bgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"palettes_table_cell_bg_image"]];
    UIView* selectedBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"palettes_table_cell_bg_image"]];;
    
    bgview.opaque = YES;
    cell.selectedBackgroundView = bgview;
    [cell setBackgroundView:selectedBgView];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#6794A2"];
    cell.textLabel.highlightedTextColor = [UIColor colorWithHexString:@"#00517D"];
    NSArray *splitTitleAndId = [self.paletteTitles[indexPath.row] componentsSeparatedByString:@"---+++---"];
    
    cell.textLabel.text = [splitTitleAndId objectAtIndex:0];
    [self.myPaletteIds setObject:[splitTitleAndId objectAtIndex:1] forKey:[NSNumber numberWithLong:indexPath.row]];
  } else {
    NSArray *paletteKeys = [self.fetchedPalettes allKeys];
    NSString *strKey = [NSString stringWithFormat:@"%@", [paletteKeys objectAtIndex:indexPath.row]];
    Palette *palette = [self.fetchedPalettes objectForKey:strKey];
    cell.textLabel.text = palette.title;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    cell.selected = YES;
  }
  
  return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (tableView == self.paletteSelectorTableView){
    return [self.paletteTitles count];
  } else {
    return [[self.fetchedPalettes allKeys] count];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;

  dispatch_async(dispatch_get_main_queue(), ^{
    [self.palettesSelectedToFetch addObject:[NSNumber numberWithLong:indexPath.row]];
    [self updateNumberOfPalettesSelctedToFetchLabel];
  });
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.palettesSelectedToFetch removeObject:[NSNumber numberWithLong:indexPath.row]];
    [self updateNumberOfPalettesSelctedToFetchLabel];
  });

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 40.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  if (tableView == self.paletteSelectorTableView){
    return @"Select Palettes to Fetch";
  } else {
    return @"Fetched Palettes";
  }
}

-(void) updateNumberOfPalettesSelctedToFetchLabel
{
  NSString * palettesSpelling = [self.palettesSelectedToFetch count] == 1 ? @"palette" : @"palettes";
  NSString * strSelectedpaletteMsg = [NSString stringWithFormat:@"%ld %@ selected", [self.palettesSelectedToFetch count], palettesSpelling];
  
  self.numberOfSelectedPalettesLabel.text = strSelectedpaletteMsg;
  if ([self.palettesSelectedToFetch count] > 0){
    [self.fetchButton setHidden:NO];
  } else {
    [self.fetchButton setHidden:YES];
  }
}


#pragma mark - RomiboWebAPI related methods

- (void)registerAsRomiboWebManagerObserver
{
  
  /*
   
   Register 'self' to receive change notifications for the "fetchPalettsObservable" property of
   
   the 'RomibowebAPIManager' object and specify that new values of "fetchPalettsObservable"
   
   should be provided in the observe… method.
   We are using this so that we get notified when the fetch palettes to
   RomiboWeb task is completed
   */
  
  RomibowebAPIManager *apiManager = [RomibowebAPIManager sharedRomibowebManagerInstance];
  [apiManager addObserver:self
               forKeyPath:@"fetchPalettesObservable"
                  options:(NSKeyValueObservingOptionNew)
                  context:NULL];
  
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqual:@"fetchPalettesObservable"]) {
    [self handleFetchPalettesTaskCompletion];
  }
}

-(void)handleFetchPalettesTaskCompletion
{
  RomibowebAPIManager *apiManager = [RomibowebAPIManager sharedRomibowebManagerInstance];
  if ((apiManager.responseCode == 200) || (apiManager.responseCode == 201)){//success: fetch succeeded
    dispatch_async(dispatch_get_main_queue(), ^{
      [apiManager getColorsListFromRomiboWeb];
      self.connectionStatusLabel.textColor = [UIColor colorWithRed:0.2/255.0f green:102.0f/255.0f blue:51.0f/255.0f alpha:1.0];
      NSString *successMessage = @"Successfully fetched the requested palettes from RomiboWeb.";
      self.connectionStatusLabel.text = successMessage;
      if ([self.spinner isAnimating]) {
        [self.spinner stopAnimating];
      }
      
      [self.okButton setHidden:NO];
      [self.mainContainerForWidgets setHidden:YES];
      
      NSMutableDictionary * requestedPalettes = [[NSMutableDictionary alloc] init];
      //select the request palettes
      if (self.selectedPaletteOption == 1){//specific palettes
        for (id selectedId in self.palettesSelectedToFetch){
          id paletteId = [self.myPaletteIds objectForKey:selectedId];
          Palette *palette = [[apiManager fetchedPalettes] objectForKey:[NSString stringWithFormat:@"%@", paletteId]];
          [requestedPalettes setObject:palette forKey:[NSString stringWithFormat:@"%@", paletteId]];
        }
        self.fetchedPalettes = [[NSDictionary alloc] initWithDictionary:[requestedPalettes copy]];
      } else {
        self.fetchedPalettes = [[NSDictionary alloc] initWithDictionary:[[apiManager fetchedPalettes] copy]];
      }
      

      [self.fetchedPalettesTableView reloadData];
      [self.fetchedPalettesTableView setHidden:NO];

      //update users palette list with fetched palettes
      for (id key in self.fetchedPalettes){
        Palette *palette = [self.fetchedPalettes objectForKey:key];
        [[UserPalettesManager sharedPalettesManagerInstance] addPalette:palette];
      }
    });

  } else {//failure:
    self.connectionStatusLabel.textColor = [UIColor redColor];
    NSString *failureMessage = @"";
    NSLog(@"status = %@", apiManager.responseStatus);
    if ([apiManager.responseStatus isEqualToString:@"401 Unauthorized"]){
      failureMessage = @"Failed to log in to RomiboWeb. Invalid email/password combination.";
    } else {
      failureMessage = @"Failed to fetch the requested palettes from RomiboWeb. Please try again.";
    }

  }

  //stop observing
  [apiManager removeObserver:self forKeyPath:@"fetchPalettesObservable"];
}



@end
