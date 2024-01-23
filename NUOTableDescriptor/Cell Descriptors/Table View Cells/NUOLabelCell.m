//
//  LabelCell.m
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

#import "NUOLabelCell.h"

@implementation NUOLabelCell

- (void)awakeFromNib
{
    // Initialization code
    self.leftMargin = 15;
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)layoutSubviews {
    [super layoutSubviews];

    CGRect tmpFrame = self.textLabel.frame;
    tmpFrame.origin.x = self.leftMargin;
    self.textLabel.frame = tmpFrame;

}

@end
