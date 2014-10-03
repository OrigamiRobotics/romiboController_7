//
//  PaletteButtonsCollectionViewCell.h
//  romiboController_7
//
//  Created by Daniel Brown on 9/26/14.
//  Copyright (c) 2014 Origami Robotics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaletteButtonsCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *backgroundLabel;
@property (strong, nonatomic) IBOutlet UILabel *foregroundLabel;
@property (strong, nonatomic) IBOutlet UIImageView *checkmarkImage;

@end
