//
//  TableDescriptorViewController.m
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

#import "NUOTableDescriptorViewController_Private.h"
#import "NUOTableDescriptor.h"
#import "NUOTableDescriptor_Private.h"
#import <QuartzCore/QuartzCore.h>
#import "CodingTest-Swift.h"
@import PureLayout;

@interface NUOTableDescriptorViewController () <CAAnimationDelegate>
@property BOOL doNotReloadTableOnViewAppearAfterViewLoad;
@property UITableViewStyle tableViewStyle;

@property NSLayoutConstraint* collapsableHeaderViewTopEdgeLayoutConstraint;
@property NSLayoutConstraint* collapsableHeaderViewTopOffsetEdgeLayoutConstraint;
@property NSLayoutConstraint* collapsableHeaderViewBottomEdgeOffsetLayoutConstraint;

@property NSLayoutConstraint* footerBottomEdgeLayoutConstraint;

@property CGFloat collapsableHeaderViewOffset;

@property NSLayoutConstraint* collapsableHeaderViewHiddenLayoutConstraint;

@property UIRefreshControl* refreshControl;
@property void(^animatedTableViewReloadCompletionBlock)(void);
@property BOOL keyboardIsVisible;
@property BOOL isVisible;
@property BOOL willBeVisible;
@property BOOL hasAppearedBefore;
@property (nonatomic) UIView* customContentView;

@end

@implementation NUOTableDescriptorViewController

-(instancetype)initWithStyle:(UITableViewStyle)style tableDescriptor:(NUOTableDescriptor *)tableDescriptor
{
    self = [super init];
    if (self) {
        self.tableViewStyle = style;
        self.tableDescriptor = tableDescriptor;
        [self configureWithTableDescriptor];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

-(void)initializeTableView
{
    if(!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:self.tableViewStyle];
        self.tableView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
        
        self.collapsableHeaderView = [[HidableStackView alloc] initWithContentsAxis:UILayoutConstraintAxisVertical displayEdge:UIRectEdgeTop];
        
        self.topFixedHeaderView = [[HidableStackView alloc] initWithContentsAxis:UILayoutConstraintAxisVertical displayEdge:UIRectEdgeTop];
        self.bottomFixedHeaderView = [[HidableStackView alloc] initWithContentsAxis:UILayoutConstraintAxisVertical displayEdge:UIRectEdgeTop];
        self.footerView = [[HidableStackView alloc] initWithContentsAxis:UILayoutConstraintAxisVertical displayEdge:UIRectEdgeBottom];
        
        self.view.backgroundColor = [UIColor whiteColor];
        
        //Container Header View
        self.containerHeaderView = [[HidableStackView alloc] initWithContentsAxis:UILayoutConstraintAxisVertical displayEdge:UIRectEdgeTop];
        [self.view addSubview:self.containerHeaderView];
        [self.containerHeaderView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero
                                                           excludingEdge:ALEdgeBottom];

        [self.view addSubview:self.horizontalContainerStackView];
        
        [self.horizontalContainerStackView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero
                                                                    excludingEdge:ALEdgeTop];
        
        [self.horizontalContainerStackView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.containerHeaderView];

        self.containerView = [[UIView alloc] init];
        [self.horizontalContainerStackView addArrangedSubview:self.containerView];

        [self.containerView addSubview:self.topFixedHeaderView];
        [self.containerView addSubview:self.collapsableHeaderView];
        [self.containerView addSubview:self.bottomFixedHeaderView];
        [self.containerView addSubview:self.tableView];
        [self.containerView addSubview:self.footerView];
        
        [self.containerView sendSubviewToBack:self.collapsableHeaderView];
        
        [self.containerView sendSubviewToBack:self.tableView];

        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.tableView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        [self.tableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.bottomFixedHeaderView];
        [self.tableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.footerView];

        [self.bottomFixedHeaderView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.bottomFixedHeaderView autoPinEdgeToSuperviewEdge:ALEdgeRight];
        
        [self.bottomFixedHeaderView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.collapsableHeaderView];

        [self.collapsableHeaderView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
        [self.collapsableHeaderView autoPinEdgeToSuperviewEdge:ALEdgeRight];

        self.collapsableHeaderViewTopEdgeLayoutConstraint = [self.collapsableHeaderView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.topFixedHeaderView];

        [self.topFixedHeaderView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeBottom];
        
        [NSLayoutConstraint autoCreateConstraintsWithoutInstalling:^{
            self.collapsableHeaderViewHiddenLayoutConstraint = [self.collapsableHeaderView autoPinEdge:ALEdgeBottom
                                                                                                toEdge:ALEdgeTop
                                                                                                ofView:self.topFixedHeaderView];
        }];

        [NSLayoutConstraint autoCreateConstraintsWithoutInstalling:^{
            [NSLayoutConstraint autoSetPriority:UILayoutPriorityDefaultLow forConstraints:^{
                self.collapsableHeaderViewTopOffsetEdgeLayoutConstraint = [self.collapsableHeaderView autoPinEdge:ALEdgeTop
                                                                                                           toEdge:ALEdgeBottom
                                                                                                           ofView:self.topFixedHeaderView];
            }];

            self.collapsableHeaderViewBottomEdgeOffsetLayoutConstraint = [self.collapsableHeaderView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.topFixedHeaderView withOffset:0 relation:NSLayoutRelationGreaterThanOrEqual];
        }];

        [self.footerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero excludingEdge:ALEdgeTop];

        if (@available(iOS 15.0, *)) {
            self.tableView.sectionHeaderTopPadding = 0;
        }
    }
}

-(UIStackView*)horizontalContainerStackView
{
    if(!_horizontalContainerStackView) {
        UIStackView* stackView = [[UIStackView alloc] init];
        stackView.axis = UILayoutConstraintAxisHorizontal;
        _horizontalContainerStackView = stackView;
    }
    return _horizontalContainerStackView ;
}

-(void)addRightView:(UIView*)rightView
{
    [self.horizontalContainerStackView addArrangedSubview:rightView];
    [rightView layoutIfNeeded];
}

-(void)removeRightView:(UIView*)rightView
{
    [self.horizontalContainerStackView removeArrangedSubview:rightView];
    [rightView removeFromSuperview];
}

-(void)addRightViewController:(UIViewController *)rightViewController
{
    [self addChildViewController:rightViewController];
    [self addRightView:rightViewController.view];
    [rightViewController didMoveToParentViewController:self];
}

-(void)removeRightViewController:(UIViewController *)rightViewController
{
    [self removeRightView:rightViewController.view];
    [rightViewController removeFromParentViewController];
}

-(NSArray<UIView*>* _Nonnull)rightViews;
{
    NSMutableArray<UIView*>* rightViews =  [NSMutableArray arrayWithArray:[self.horizontalContainerStackView arrangedSubviews]];
    [rightViews removeObject:self.containerView];
    return rightViews;
}

-(void)setRightBarButtonItemsWithBarButtonItems:(NSArray<UIBarButtonItem*>* _Nonnull)barButtonItems;
{
    self.navigationItem.rightBarButtonItems = barButtonItems;
}

-(void)setContainerHeaderContents:(NSArray<UIView*>* _Nonnull)containerHeaderContents;
{
    [self.containerHeaderView setContents:containerHeaderContents];
}

-(void)setContainerHeaderContentsDisplayed:(BOOL)containerHeaderContentsDisplayed
                                  animated:(BOOL)animated
{
    __weak typeof(self) wself = self;
    [self.containerHeaderView setContentsDisplayed:containerHeaderContentsDisplayed animated:animated completion:^{
        [wself.view bringSubviewToFront:wself.containerHeaderView];
        [wself.view layoutIfNeeded];
    }];
}

-(void)setTopFixedHeaderContents:(NSArray<UIView*>*)headerContents;
{
    [self.topFixedHeaderView setContents:headerContents];
}

-(void)setTopFixedHeaderContentsDisplayed:(BOOL)topFixedHeaderContentsDisplayed animated:(BOOL)animated
{
    __weak typeof(self) wself = self;
    [self.topFixedHeaderView setContentsDisplayed:topFixedHeaderContentsDisplayed animated:animated completion:^{
        [wself.view layoutIfNeeded];
    }];
}

-(void)setBottomFixedHeaderContentsDisplayed:(BOOL)bottomFixedHeaderContentsDisplayed animated:(BOOL)animated
{
    __weak typeof(self) wself = self;
    [self.bottomFixedHeaderView setContentsDisplayed:bottomFixedHeaderContentsDisplayed animated:animated completion:^{
        [wself.view layoutIfNeeded];
    }];
}

-(void)setFixedHeaderContentsDisplayed:(BOOL)fixedHeaderContentsDisplayed animated:(BOOL)animated
{
    [self setTopFixedHeaderContentsDisplayed:fixedHeaderContentsDisplayed animated:animated];
    [self setBottomFixedHeaderContentsDisplayed:fixedHeaderContentsDisplayed animated:animated];
}

-(void)setCollapsableHeaderContents:(NSArray<UIView*>*)headerContents
{
    [self.collapsableHeaderView setContents:headerContents];
}

-(void)setCollapsableHeaderContentsDisplayed:(BOOL)collapsableHeaderContentsDisplayed
                                    animated:(BOOL)animated
                                  completion:(void (^)(void))completion
{
    [self.collapsableHeaderView setContentsDisplayed:collapsableHeaderContentsDisplayed
                                            animated:animated
                                          completion:completion];
}

-(void)setBottomFixedHeaderContents:(NSArray<UIView*>*)headerContents
{
    [self.bottomFixedHeaderView setContents:headerContents];
}


-(void)layoutHeaderContentsWithAnimated:(BOOL)animated completion:(void(^)(void))completion
{
    double animationDuration = animated ? 0.3 : 0.0f;

    [self.view setNeedsUpdateConstraints];
    CGRect tableViewFooterFrame = self.tableView.tableFooterView.frame;

    if(animated) {
        [UIView animateWithDuration:animationDuration animations:^{
            [self.view layoutIfNeeded];
            [self.tableView.tableFooterView setFrame:tableViewFooterFrame];
        } completion:^(BOOL finished) {
            if(completion) {
                completion();
            }
        }];
    } else if(completion) {
        completion();
    }
}

-(void)layoutFooterContentsWithAnimated:(BOOL)animated completion:(void(^)(void))completion
{
    double animationDuration = animated ? 0.3 : 0.0f;

    [self.view setNeedsUpdateConstraints];
    CGRect tableViewFooterFrame = self.tableView.tableFooterView.frame;

    [UIView animateWithDuration:animationDuration animations:^{
        [self.tableView.tableFooterView setFrame:tableViewFooterFrame];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if(completion) {
            completion();
        }
    }];
}

-(void)showCollapsableHeaderView
{
    self.collapsableHeaderViewBottomEdgeOffsetLayoutConstraint.active = NO;
    self.collapsableHeaderViewTopOffsetEdgeLayoutConstraint.active = NO;
    self.collapsableHeaderViewHiddenLayoutConstraint.active = NO;
    self.collapsableHeaderViewTopEdgeLayoutConstraint.active = YES;
    self.collapsableHeaderViewOffset = 0;
    self.collapsableHeaderViewTopOffsetEdgeLayoutConstraint.constant = 0;
    [self layoutHeaderContentsWithAnimated:YES completion:nil];
}

-(void)changeCollapsableHeaderViewOffset:(CGFloat)collapsableHeaderViewOffsetChange;
{
    CGFloat originalHeaderViewOffset= self.collapsableHeaderViewOffset;

    CGFloat newHeaderViewOffset = originalHeaderViewOffset + collapsableHeaderViewOffsetChange;

    CGFloat collapsableHeaderViewHeight = [self collapsableHeaderViewHeight];

    if(newHeaderViewOffset >= 0) {
        if(self.collapsableHeaderViewOffset == 0) {
            return;
        }
        self.collapsableHeaderViewBottomEdgeOffsetLayoutConstraint.active = NO;
        self.collapsableHeaderViewTopOffsetEdgeLayoutConstraint.active = NO;
        self.collapsableHeaderViewHiddenLayoutConstraint.active = NO;
        self.collapsableHeaderViewTopEdgeLayoutConstraint.active = YES;
        self.collapsableHeaderViewTopOffsetEdgeLayoutConstraint.constant = 0;
        self.collapsableHeaderViewOffset = 0;
    } else if(fabs(newHeaderViewOffset) > collapsableHeaderViewHeight) {
        if(self.collapsableHeaderViewOffset == - collapsableHeaderViewHeight) {
            return;
        }
        
        self.collapsableHeaderViewTopOffsetEdgeLayoutConstraint.constant = - collapsableHeaderViewHeight;
        self.collapsableHeaderViewOffset = -collapsableHeaderViewHeight;
    } else {
        self.collapsableHeaderViewHiddenLayoutConstraint.active = NO;
        self.collapsableHeaderViewTopEdgeLayoutConstraint.active = NO;
        self.collapsableHeaderViewBottomEdgeOffsetLayoutConstraint.active = YES;
        self.collapsableHeaderViewTopOffsetEdgeLayoutConstraint.active = YES;
        self.collapsableHeaderViewTopOffsetEdgeLayoutConstraint.constant += collapsableHeaderViewOffsetChange;
        self.collapsableHeaderViewOffset = newHeaderViewOffset;
    }
    //[self layoutHeaderContentsWithAnimated:NO completion:nil];
}

-(CGFloat)collapsableHeaderViewHeight
{
    return CGRectGetHeight(self.collapsableHeaderView.frame);
}

-(BOOL)isCollapsableHeaderViewFullyVisible
{
    return [self collapsableHeaderViewOffset] == 0;
}

-(BOOL)isCollapsableHeaderViewFullyHidden
{
    return [self collapsableHeaderViewOffset] == -[self collapsableHeaderViewHeight];
}

-(void)hideCollapsableHeaderView
{
    [self.view sendSubviewToBack:self.collapsableHeaderView];
    self.collapsableHeaderViewBottomEdgeOffsetLayoutConstraint.active = NO;
    self.collapsableHeaderViewTopOffsetEdgeLayoutConstraint.active = NO;
    self.collapsableHeaderViewTopEdgeLayoutConstraint.active = NO;
    self.collapsableHeaderViewHiddenLayoutConstraint.active = YES;

    [self layoutHeaderContentsWithAnimated:YES completion:nil];
}

-(void)setFooterViewContent:(UIView*)footerContents
{
    if(footerContents) {
        [self.footerView setContents:@[footerContents]];
    } else {
        [self.footerView setContents:@[]];
    }
}

-(void)setFooterViewContentDisplayed:(BOOL)footerViewContentDisplayed animated:(BOOL)animated
{
    [self.footerView setContentsDisplayed:footerViewContentDisplayed animated:animated completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeTableView];
    [self.tableDescriptor reloadDescription];
    [self configureWithTableDescriptor];

    //Notification support for scroll to text field
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidBeginEditting)
                                                 name:UITextViewTextDidBeginEditingNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldTextDidBeginEditting)
                                                 name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.willBeVisible = YES;

    if(self.hasAppearedBefore) {
        [self.tableDescriptor willReappear];
    } else {
        [self.tableDescriptor willFirstAppear];
    }

    [self.tableDescriptor willAppear];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.isVisible = YES;
    self.willBeVisible = NO;
    
    if(!self.hasAppearedBefore) {
        [self.tableDescriptor didFirstAppear];
        self.hasAppearedBefore = YES;
    }
    
    [self.tableDescriptor didAppear];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.tableView endEditing:YES];
    [super viewWillDisappear:animated];
    [self.tableDescriptor willDisappear];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.isVisible = NO;
}

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    if(!parent) {
        [self.tableDescriptor willBeDismissed];
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self.tableDescriptor viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.tableDescriptor sectionTitleForSection:section];
}

-(void)pushViewController:(UIViewController*)tableDescriptorViewController
{
    [self pushViewController:tableDescriptorViewController animated:YES];
}

-(void)pushViewController:(UIViewController*)tableDescriptorViewController animated:(BOOL)animated
{
    // @@ 3317 prc To prevent any issues with responder chain, end editting before pushing new
    // view controller
    [self endEditing];
    [self.navigationController pushViewController:tableDescriptorViewController animated:animated];
}

-(void)pushViewControllers:(NSArray*)viewControllers
{
    [self endEditing];

    NSArray* newViewControllers = [[self.navigationController viewControllers] arrayByAddingObjectsFromArray:viewControllers];

    [self.navigationController setViewControllers:newViewControllers animated:YES];
}


-(void)popViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)popToSelf
{
    [self.navigationController popToViewController:self animated:YES];
}

-(void)setTableDescriptorViewControllerTitle:(NSString*)title
{
    self.title = title;
    self.navigationItem.title = title;
}

-(CGFloat)tableViewWidth
{
    return self.tableView.frame.size.width;
}


-(void)setTableViewSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle;
{
    self.tableView.separatorStyle = separatorStyle;
}

-(void)setTableViewHeaderView:(UIView*)tableViewHeaderView
{
    self.tableView.tableHeaderView = tableViewHeaderView;
}

-(void)setTableViewFooterView:(UIView*)tableViewFooterView
{
    self.tableView.tableFooterView = tableViewFooterView;
}

-(void)configureWithTableDescriptor
{
    self.tableView.dataSource = self.tableDescriptor;
    self.tableView.delegate = self.tableDescriptor;
    self.tableDescriptor.delegate = self;

    [self.tableDescriptor registerWithTableView:self.tableView];

    if(self.tableDescriptor.titleView) {
        self.navigationItem.titleView = self.tableDescriptor.titleView;
    } else {
        self.title = [self.tableDescriptor title];
    }

    //Prevent iOS from setting "readable" layout margins
    if([self.tableView respondsToSelector:@selector(setCellLayoutMarginsFollowReadableWidth:)]) {
        [self.tableView setCellLayoutMarginsFollowReadableWidth:NO];
    }

    if(self.tableDescriptor.backTitle) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.tableDescriptor.backTitle style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    //[self.tableView setTableFooterView:[UIView new]];

    if(self.tableDescriptor.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItems = @[self.tableDescriptor.leftBarButtonItem];
    }
    
    //Setup navigation bar button items
    if(self.tableDescriptor.rightBarButtonItems) {
        self.navigationItem.rightBarButtonItems = self.tableDescriptor.rightBarButtonItems;
    } else if(self.tableDescriptor.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = self.tableDescriptor.rightBarButtonItem;
    }

    if(self.tableDescriptor.headerView) {
        [self setCollapsableHeaderContents:@[self.tableDescriptor.headerView]];
    }
}

-(void)setRefreshControlEnabled:(BOOL)refreshControlEnabled
{
    if(!self.refreshControl) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.tintColor = [UIColor colorWithWhite:189./255. alpha:1];
        [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    }

    if(refreshControlEnabled) {
        [self.tableView addSubview:self.refreshControl];
        [self.tableView sendSubviewToBack:self.refreshControl];
    } else {
        [self.refreshControl removeFromSuperview];
    }
}

-(void)refresh:(id)sender
{
    [self.tableDescriptor pullDownToRefreshTriggered];
}

-(void)onPullToRefreshFinished
{
    [self.tableView layoutIfNeeded];
    [self.refreshControl endRefreshing];
}

-(void)reloadTableDescriptor
{
    [self reloadTableDescriptorWithCompletionBlock:nil];
}

-(void)reloadTableDescriptorWithCompletionBlock:(void(^)(void))completionBlock
{
    [self reloadTableDescriptorWithAnimated:self.tableDescriptor.animateTableReload
                            completionBlock:completionBlock];
}

-(void)reloadTableDescriptorWithAnimated:(BOOL)animated
                         completionBlock:(void(^)(void))completionBlock
{
    if(self.tableDescriptor.endEditingOnReload) {
        [self endEditing];
    }
    if(self.isTableDataReloading) {
        //@throw [NSException exceptionWithName:@"TableDescriptionChangedWhileTableBeingReloaded" reason:@"The table description would be modified while uitableview is being reloaded" userInfo:nil];
    }

    if([NSThread isMainThread]) {
        [self.tableDescriptor reloadDescription];
        [self reloadTableWithAnimated:animated completionBlock:completionBlock];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableDescriptor reloadDescription];
            [self reloadTableWithAnimated:animated completionBlock:completionBlock];
        });
    }
}

-(void)reloadTable
{
    [self reloadTableWithCompletionBlock:nil];
}

-(BOOL)isTableReloading
{
    return self.isTableDataReloading;
}

-(void)reloadTableWithCompletionBlock:(void(^)(void))completionBlock
{
    [self reloadTableDescriptorWithAnimated:self.tableDescriptor.animateTableReload completionBlock:completionBlock];
}

-(void)reloadTableWithAnimated:(BOOL)animated completionBlock:(void(^)(void))completionBlock
{
    __weak typeof(self) wself = self;
    void(^reloadTableBlock)(void) = ^{
        __strong typeof(wself) sself = wself;
        if(!sself) {
            return;
        }
        self.isTableDataReloading = YES;
        
        [self.tableDescriptor cacheCellDescriptorsForRedraw];
        
        [sself.tableView reloadData];
        
        if(animated) {
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.fillMode = kCAFillModeForwards;
            transition.duration = 0.2;
            transition.delegate = self;
            sself.animatedTableViewReloadCompletionBlock = completionBlock;
            [[sself.tableView layer] addAnimation:transition forKey:@"UITableViewReloadDataAnimationKey"];
        } else {
            self.isTableDataReloading = NO;
            if(completionBlock) {
                completionBlock();
            }
            [sself.tableDescriptor tableDidReload];
        }
    };
    
    if([NSThread isMainThread]) {
        reloadTableBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), reloadTableBlock);
    }
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if(self.animatedTableViewReloadCompletionBlock) {
        self.animatedTableViewReloadCompletionBlock();
        self.animatedTableViewReloadCompletionBlock = nil;
    }
    self.isTableDataReloading = NO;
    [self.tableDescriptor tableDidReload];
}

-(void)insertRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self insertRowsAtIndexPaths:indexPaths withRowAnimation:animation completion:nil];
}

-(void)insertRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion
{
    [self performTableViewModificationBlock:^(UITableView* tableView){
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } animated:animation != UITableViewRowAnimationNone completionBlock:completion];

}

-(void)deleteRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation completion:nil];
}

-(void)deleteRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion
{
    [self performTableViewModificationBlock:^(UITableView* tableView){
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } animated:animation != UITableViewRowAnimationNone completionBlock:completion];

}

-(void)reloadRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
    [self reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation completion:nil];
}

-(void)reloadRowsAtIndexPaths:(NSArray*)indexPaths withRowAnimation:(UITableViewRowAnimation)animation completion:(void (^)(void))completion
{
    [self performTableViewModificationBlock:^(UITableView* tableView){
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
    } animated:animation != UITableViewRowAnimationNone completionBlock:completion];

}


-(void)reloadSections:(NSIndexSet*)indexSet withRowAnimation:(UITableViewRowAnimation)animation
{
    [self reloadSections:indexSet withRowAnimation:animation completion:nil];
}

-(void)reloadSections:(NSIndexSet*)indexSet withRowAnimation:(UITableViewRowAnimation)animation completion:(void(^)(void))completion;
{
    [self performTableViewModificationBlock:^(UITableView* tableView){
        [tableView reloadSections:indexSet withRowAnimation:animation];
    } animated:animation != UITableViewRowAnimationNone completionBlock:completion];

}

-(void)performTableViewUpdateWithAnimated:(BOOL)animated completionBlock:(void(^)(void))completionBlock
{
    return [self performTableViewModificationBlock:nil animated:YES completionBlock:completionBlock];
}

-(void)performTableViewModificationBlock:(void(^)(UITableView* tableView))modificationBlock completionBlock:(void(^)(void))completionBlock;
{
    return [self performTableViewModificationBlock:modificationBlock animated:YES completionBlock:completionBlock];
}

-(void)performTableViewModificationBlock:(void(^)(UITableView* tableView))modificationBlock animated:(BOOL)animated completionBlock:(void(^)(void))completionBlock
{
    if([NSThread isMainThread]) {
        [self performTableViewModificationBlock:modificationBlock tableView:self.tableView animated:animated completionBlock:completionBlock];
    } else {
        __weak typeof(self) wself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(wself) sself = wself;
            if(!sself) {
                return;
            }
            [wself performTableViewModificationBlock:modificationBlock tableView:self.tableView animated:animated completionBlock:completionBlock];
        });
    }
}

-(void)performTableViewModificationBlock:(void(^)(UITableView* tableView))modificationBlock tableView:(UITableView*)tableView animated:(BOOL)animated completionBlock:(void(^)(void))completionBlock
{
    if(completionBlock) {
        [CATransaction begin];

        [tableView beginUpdates];

        if(modificationBlock) {
            if(!animated) {
                [UIView performWithoutAnimation:^{
                    modificationBlock(tableView);
                }];
            } else {
                modificationBlock(tableView);
            }
        }

        [CATransaction setCompletionBlock: ^{
            if(completionBlock) {
                completionBlock();
            }
        }];

        [self.tableDescriptor cacheCellDescriptorsForRedraw];
        [tableView endUpdates];
        
        [CATransaction commit];
    } else {

        [self.tableDescriptor cacheCellDescriptorsForRedraw];

        [tableView beginUpdates];
        
        if(modificationBlock) {
            if(!animated) {
                [UIView performWithoutAnimation:^{
                    modificationBlock(tableView);
                }];
            } else {
                modificationBlock(tableView);
            }
        }
        [tableView endUpdates];
    }
}

-(void)updateTable
{
    __weak typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(wself) sself = wself;
        if(!sself) {
            return;
        }
        [sself.tableView beginUpdates];
        [sself.tableView endUpdates];
    });

}

-(void)scrollToCellDescriptor:(NUOCellDescriptor*)cellDescriptor atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    [self scrollToCellDescriptor:cellDescriptor atScrollPosition:scrollPosition animated:animated completionBlock:nil];
}
-(void)scrollToCellDescriptor:(NUOCellDescriptor*)cellDescriptor
             atScrollPosition:(UITableViewScrollPosition)scrollPosition
                     animated:(BOOL)animated
                   completionBlock:(void(^)(void))completionBlock
{
    NSIndexPath* indexPath = [self.tableDescriptor indexPathForCellDescriptor:cellDescriptor];
    if(indexPath) {
        self.scrollCompletionBlock = completionBlock;
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }
}



-(void)scrollToSection:(NSUInteger)section atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:section];
    if(indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }
}

-(void)scrollToTopWithAnimated:(BOOL)animated
{
    [self.tableView setContentOffset:CGPointZero animated:animated];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.scrollCompletionBlock) {
            self.scrollCompletionBlock();
            self.scrollCompletionBlock = nil;
        }
    });
}

#pragma mark - Table view data source

-(void)shake
{
    CAKeyframeAnimation * anim = [ CAKeyframeAnimation animationWithKeyPath:@"transform" ] ;
    anim.values = @[ [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-5.0f, 0.0f, 0.0f) ], [ NSValue valueWithCATransform3D:CATransform3DMakeTranslation(5.0f, 0.0f, 0.0f) ] ] ;
    anim.autoreverses = YES ;
    anim.repeatCount = 2.0f ;
    anim.duration = 0.07f ;

    [self.navigationController.view.layer addAnimation:anim forKey:nil ] ;
}

-(void)endEditing
{
    if([NSThread isMainThread]) {
        [self.view endEditing:YES];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
        });
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    //Fix issue where tableFooterView height is malformed
    CGRect oldFrame = self.tableView.tableFooterView.frame;

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

        CGRect frame = self.tableView.tableFooterView.frame;
        CGRect newFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, oldFrame.size.height);
        [self.tableView.tableFooterView setFrame: newFrame];

    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {

    }];
}

-(UIViewController*)viewController
{
    return self;
}

-(void)setTableAccessibilityIdentifier:(NSString*)accessibilityIndentifier
{
    self.tableView.accessibilityIdentifier = accessibilityIndentifier;
}

-(void)setTableAccessibilityValue:(NSString* _Nullable)accessibilityValue
{
    self.tableView.accessibilityValue = accessibilityValue;
}

-(CGFloat)cellsViewOverrunCoefficientWithIgnoreFooterHeight:(BOOL)ignoreFooterHeight;
{
    CGFloat footerViewHeight = 0;
    if(!ignoreFooterHeight && self.tableView.tableFooterView) {
        footerViewHeight = CGRectGetHeight(self.tableView.tableFooterView.frame);
    }
    
    CGFloat tableViewContentHeight = self.tableView.contentSize.height - footerViewHeight;
    
    CGFloat tableViewFrameSize = CGRectGetHeight(self.tableView.frame);
    
    return tableViewContentHeight / tableViewFrameSize;
}

#pragma mark - UI Text Field Keyboard Avoidance
static const CGFloat kMinimumScrollOffsetPadding = 20;

//Derived from https://github.com/michaeltyson/TPKeyboardAvoiding
//Zlib license

- (void)keyboardWillShow:(NSNotification*)notification
{
    self.keyboardIsVisible = YES;
    
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIEdgeInsets newEdgeInsets = UIEdgeInsetsMake(0, 0, keyboardRect.size.height, 0);
    
    [self.tableView setContentInset:newEdgeInsets];
    [self.tableView setScrollIndicatorInsets:newEdgeInsets];
    
    if(self.tableDescriptor.shouldScrollToActiveTextField) {
        [self scrollToActiveTextField];
    }
    UIView* firstResponder = [self findFirstResponderBeneathView:self.view];
    [self.tableDescriptor willDisplayKeyboardWithFirstResponder:firstResponder];
    
    NSTimeInterval duration = [self keyboardAnimationDurationForNotification:notification];
    
    UIViewAnimationCurve curve = [self keyboardAnimationCurveForNotification:notification];
    
    self.footerBottomEdgeLayoutConstraint.constant = -keyboardRect.size.height;
    
    UIViewAnimationOptions options = [UIView viewAnimationOptionsWithCurve:curve];
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    self.keyboardIsVisible = NO;
    [self.tableView setContentInset:UIEdgeInsetsZero];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
    [self.tableDescriptor willHideKeyboard];
    
    NSTimeInterval duration = [self keyboardAnimationDurationForNotification:notification];
    UIViewAnimationCurve curve = [self keyboardAnimationCurveForNotification:notification];
    
    UIViewAnimationOptions options = [UIView viewAnimationOptionsWithCurve:curve];
    
    self.footerBottomEdgeLayoutConstraint.constant = 0;
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardDidHide:(NSNotification*)notification
{
    [self.tableDescriptor didHideKeyboard];
}

- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    return duration;
}

- (UIViewAnimationCurve)keyboardAnimationCurveForNotification:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve curve = 0;
    [value getValue:&curve];
    return curve;
}

- (void)textFieldTextDidBeginEditting
{
    if(self.tableDescriptor.shouldScrollToActiveTextField) {
        [self scrollToActiveTextField];
    }
}

-(void)scrollToActiveTextField
{
    if(!self.keyboardIsVisible) {
        return;
    }
    
    UIView* firstResponder = [self findFirstResponderBeneathView:self.view];
    
    if(!firstResponder) {
        return;
    }
    
    UIScrollView* scrollView = [self scrollViewForScrollToActiveTextField];
    
    CGFloat visibleSpace = scrollView.bounds.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom;
    
    CGFloat visibleSpaceCoveredByFixedHeader = 0.0f;
    
    if([scrollView isKindOfClass:[UITableView class]]) {
        UITableView* tableView =(UITableView*) scrollView;
        if(tableView.style == UITableViewStylePlain) {
            //Find smallest visible section
            NSUInteger smallestSection = [[[tableView indexPathsForVisibleRows] valueForKeyPath:@"@min.section"] unsignedIntegerValue];
            UIView* sectionHeaderView = [tableView headerViewForSection:smallestSection];
            if(sectionHeaderView) {
                CGFloat sectionHeaderHeight = CGRectGetHeight(sectionHeaderView.frame);
                visibleSpaceCoveredByFixedHeader = sectionHeaderHeight;
            }
        }
    }
    
    CGFloat contentOffset = scrollView.contentOffset.y;
    
    visibleSpace -= visibleSpaceCoveredByFixedHeader;
    
    CGFloat offsetY = [self idealOffsetForView:firstResponder
                                    scrollView:scrollView
                             viewingAreaHeight:visibleSpace
                        currentTableViewOffset:contentOffset
                      fixedSectionHeaderHeight:visibleSpaceCoveredByFixedHeader];
    
    offsetY = ceilf(offsetY);
    CGPoint idealOffset = CGPointMake(0, offsetY);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [scrollView setContentOffset:idealOffset animated:YES];
    });
}

-(UIScrollView*)scrollViewForScrollToActiveTextField
{
    return self.tableView;
}

- (UIView*)findFirstResponderBeneathView:(UIView*)view
{
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}

-(CGFloat)idealOffsetForView:(UIView *)view
                  scrollView:(UIScrollView*)scrollView
           viewingAreaHeight:(CGFloat)viewAreaHeight
      currentTableViewOffset:(CGFloat)currentTableViewOffset
    fixedSectionHeaderHeight:(CGFloat)fixedSectionHeaderHeight
{
    CGSize contentSize = scrollView.contentSize;
    CGFloat offset = 0.0;
    
    CGRect subviewRect = [view convertRect:view.bounds toView:self.view];
    
    // Attempt to center the subview in the visible space, but if that means there will be less than kMinimumScrollOffsetPadding
    // pixels above the view, then substitute kMinimumScrollOffsetPadding
    CGFloat padding = (viewAreaHeight - subviewRect.size.height) / 2;
    if ( padding < kMinimumScrollOffsetPadding ) {
        padding = kMinimumScrollOffsetPadding;
    }
    
    // Ideal offset places the subview rectangle origin "padding" points from the top of the scrollview.
    // If there is a top contentInset, also compensate for this so that subviewRect will not be placed under
    // things like navigation bars.
    CGFloat tableViewYOffset = CGRectGetMinY(scrollView.frame);
    offset = subviewRect.origin.y - padding - scrollView.contentInset.top + currentTableViewOffset - tableViewYOffset - fixedSectionHeaderHeight;
    
    // Constrain the new contentOffset so we can't scroll past the bottom. Note that we don't take the bottom
    // inset into account, as this is manipulated to make space for the keyboard.
    if ( offset > (contentSize.height - viewAreaHeight) ) {
        offset = contentSize.height - viewAreaHeight;
    }
    
    // Constrain the new contentOffset so we can't scroll past the top, taking contentInsets into account
    if ( offset < -scrollView.contentInset.top ) {
        offset = -scrollView.contentInset.top;
    }
    
    return offset;
}

-(void)setCustomContentView:(UIView*)customContentView;
{
    if(_customContentView) {
        [_customContentView removeFromSuperview];
    }
    _customContentView = customContentView;
    [self.containerView setHidden:_customContentView != nil];
    if(_customContentView) {
        [self.view addSubview:_customContentView];
        [_customContentView autoPinEdgesToSuperviewEdges];
    }
}

-(void)setInteractivePopGestureRecognizerEnabled:(BOOL)enabled
{
    self.navigationController.interactivePopGestureRecognizer.enabled = enabled;
}

-(void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:navigationBarHidden animated:animated];
}

-(BOOL)isNavigationBarHidden
{
    return [self.navigationController isNavigationBarHidden];
}

-(void)setStatusBarHidden:(BOOL)statusBarHidden animated:(BOOL)animated
{
    self.statusBarHidden = statusBarHidden;
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
}

-(BOOL)prefersStatusBarHidden
{
    return self.statusBarHidden;
}

-(UITableViewCell*)tableViewCellForCellDescriptor:(NUOCellDescriptor*)cellDescriptor
{
    NSIndexPath* indexPath = [self.tableDescriptor indexPathForCellDescriptor:cellDescriptor];
    
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

-(UIView*)viewForCellAtIndexPath:(NSIndexPath* _Nonnull)indexPath
{
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

@end
