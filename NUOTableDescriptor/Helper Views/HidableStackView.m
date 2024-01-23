//
//  HidableStackView.m
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

#import "HidableStackView.h"
@import PureLayout;

@interface HidableStackView ()
@property NSLayoutConstraint* headerViewHeightLayoutConstraint;
@property NSLayoutConstraint* headerViewSuperViewDisplayEdgeLayoutConstraint;
@property UIStackView* stackView;
@property UIRectEdge displayEdge;
@property UILayoutConstraintAxis contentAxis;
@end

@implementation HidableStackView
-(instancetype)initWithContentsAxis:(UILayoutConstraintAxis)contentAxis
                        displayEdge:(UIRectEdge)displayEdge;
{
    self = [super init];
    if (self) {
        self.contentAxis = contentAxis;
        self.displayEdge = displayEdge;
        self.layer.masksToBounds = YES;
        [self installViewLayout];
    }
    return self;
}

-(void)installViewLayout
{
    self.stackView = [[UIStackView alloc] init];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    [self addSubview:self.stackView];
    
    ALEdge edge;
    switch (self.displayEdge) {
        case UIRectEdgeTop:
            edge = ALEdgeTop;
            break;
        case UIRectEdgeLeft:
            edge = ALEdgeLeft;
            break;
        case UIRectEdgeRight:
            edge = ALEdgeRight;
            break;
        case UIRectEdgeBottom:
            edge = ALEdgeBottom;
            break;
        default:
            edge = ALEdgeTop;
            break;
    }
    
    [self.stackView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:edge];
    self.headerViewSuperViewDisplayEdgeLayoutConstraint = [self.stackView autoPinEdgeToSuperviewEdge:edge];
    self.headerViewHeightLayoutConstraint = [self autoSetDimension:ALDimensionHeight toSize:0];
}

-(void)setContents:(NSArray<UIView*>*)contents
{
    NSArray<UIView*>* fixedHeaderContents = [self.stackView arrangedSubviews];
    
    if([fixedHeaderContents isEqualToArray:contents]) {
        return;
    }
    
    for (UIView* subview in self.stackView.subviews) {
        [subview removeFromSuperview];
    }
    
    self.headerViewHeightLayoutConstraint.active = ![contents count];
    
    for (UIView* view in contents) {
        [self.stackView addArrangedSubview:view];
    }
}

-(void)setContentsDisplayed:(BOOL)contentsDisplayed animated:(BOOL)animated completion:(void (^)(void))completion
{
    if(contentsDisplayed) {
        self.headerViewHeightLayoutConstraint.active = [self.stackView arrangedSubviews].count == 0;
        self.headerViewSuperViewDisplayEdgeLayoutConstraint.active = YES;
    } else {
        self.headerViewSuperViewDisplayEdgeLayoutConstraint.active = NO;
        self.headerViewHeightLayoutConstraint.active = YES;
    }
    
    CGFloat animationDuration = animated ? 0.3 : 0;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(completion) {
            completion();
        }
    }];
}

@end
