//
//  HidableStackView.h
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HidableStackView : UIView
-(instancetype)initWithContentsAxis:(UILayoutConstraintAxis)axis displayEdge:(UIRectEdge)displayEdge;
-(void)setContentsDisplayed:(BOOL)contentsDisplayed animated:(BOOL)animated completion:(void(^)(void))completion;
-(void)setContents:(NSArray<UIView*>*)headerContents;
@end
