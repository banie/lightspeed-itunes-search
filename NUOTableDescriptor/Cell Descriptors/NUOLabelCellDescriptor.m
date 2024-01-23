//
//  LabelCellDescriptor.m
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

#import "NUOLabelCellDescriptor.h"
#import "NUOLabelCell.h"
#import <PureLayout/PureLayout.h>

@interface NUOLabelCellDescriptor ()
@property (weak) NUOLabelCell* cell;
@property (weak) UILabel* label;
@end

@implementation NUOLabelCellDescriptor

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftMargin = 15.f;
        self.cellSelectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

+(Class)cellClass
{
    return [NUOLabelCell class];
}

-(void)configureTableViewCell:(NUOLabelCell*)tableViewCell withTableDescriptorObject:(id)object
{
    [super configureTableViewCell:tableViewCell withTableDescriptorObject:object];

    [self configureLabel:tableViewCell.textLabel withTableDescriptorObject:object];
    tableViewCell.leftMargin = self.leftMargin;
    self.cell = tableViewCell;
}

-(void)setTitleText:(NSString *)titleText
{
    _titleText = titleText;
    if(self.label) {
        [self configureLabel:self.label withTableDescriptorObject:nil];
    } else if(self.cell) {
        [self configureLabel:self.cell.textLabel withTableDescriptorObject:nil];
    }
}

-(void)configureLabel:(UILabel*)label withTableDescriptorObject:(id)object
{
    if (self.attributedTitle) {
        label.attributedText = self.attributedTitle;
    }

    if(self.titleTextBlock) {
        self.titleText = self.titleTextBlock(object);
    }
    if(!self.titleText) {
        NSString* displayString = [self displayStringFromObject:object];
        BOOL displayValue = displayString && [displayString length];
        if(displayValue) {
            self.titleText = displayString;
        }
    }

    if(self.titleText) {
        NSDictionary* attributes = self.titleAttributes;
        if(!attributes && self.titleAttributesBlock) {
            attributes = self.titleAttributesBlock(object);
        }
        if(attributes) {
            label.attributedText = [[NSAttributedString alloc] initWithString:self.titleText attributes:attributes];
        } else {
            label.text = self.titleText;
        }
    }

    UIColor* titleColor = self.titleColor;

    if(!titleColor && self.titleColorBlock) {
        titleColor = self.titleColorBlock(object);
    }
    if(titleColor) {
        label.textColor = titleColor;
    }
}

@end
