//
//  NUOTableDescriptorViewController_Private.h
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

#import "NUOTableDescriptorViewController.h"
#import "HidableStackView.h"

@interface NUOTableDescriptorViewController () <UIAdaptivePresentationControllerDelegate>
@property (nonnull) UIView* containerView;
@property (nonnull, nonatomic) HidableStackView* containerHeaderView;
@property (nonnull, nonatomic) UIStackView* horizontalContainerStackView;
@property (nonnull)HidableStackView* collapsableHeaderView;

@property (nonnull) HidableStackView* bottomFixedHeaderView;
@property (nonnull) HidableStackView* topFixedHeaderView;
@property (nonnull) HidableStackView* footerView;

@property BOOL isTableDataReloading;
@property BOOL statusBarHidden;

@property (nullable) void(^scrollCompletionBlock)(void);

-(UIScrollView* _Nonnull)scrollViewForScrollToActiveTextField;
- (void)keyboardWillShow:(NSNotification* _Nonnull)notification;
- (void)keyboardWillHide:(NSNotification* _Nonnull)notification;
- (void)keyboardDidHide:(NSNotification* _Nonnull)notification;
-(void)refresh:(id _Nullable)sender;
@end
