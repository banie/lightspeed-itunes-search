//
//  TableDescriptorViewControllerDelegate.h
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

@import Foundation;

@class NUOTableDescriptorViewController;

@protocol NUOTableDescriptorViewControllerDelegate <NSObject>

/**
 *  Instruct the view controller to push specific table descriptor view controller onto view stack
 *
 *  @param viewController The view controller to display ontop of the
 *  view stack
 */
-(void)pushViewController:(UIViewController* _Nonnull)viewController;

/**
 *  Instruct the view controller to push specific table descriptor view controller onto view stack
 *
 *  @param tableDescriptorViewController The view controller to display ontop of the view stack
 *  @param animated Whether the push should be animated
 */
-(void)pushViewController:(UIViewController* _Nonnull)tableDescriptorViewController
                 animated:(BOOL)animated;

/**
 *  Instruct the view controller to push a list of table descriptor view controller onto the view stack
 *  Only the last table descriptor view controller will be animated
 *
 *  @param viewControllers A list of view controllers to display ontop of the view stack
 */
-(void)pushViewControllers:(NSArray<UIViewController*>* _Nonnull)viewControllers;

/**
 *  Instruct the navigation controller to pop the current view controller from the
 *  view controller stack
 */
-(void)popViewController;

/**
 *  Instruct the navigation controller to pop the navigation stack until this view controller
 *  is the top view controller in the stack
 */
-(void)popToSelf;

/**
 *  Present a view controller
 *
 *  @param viewControllerToPresent The view controller to present
 *  @param animated                Whether the presentation should be animated
 *  @param completion              Block to be called on completion
 */
-(void)presentViewController:(UIViewController* _Nonnull)viewControllerToPresent
                    animated:(BOOL)animated
                  completion:(void (^ _Nullable)(void))completion;

/**
 *  Dismissed the currently presented view controller
 *
 *  @param animated   Whether the dismissal is animated
 *  @param completion Block to be called on completion
 */
-(void)dismissViewControllerAnimated:(BOOL)animated
                          completion:(void (^ _Nullable)(void))completion;

-(UIViewController* _Nullable)presentedViewController;
/**
 *  Set the view controllers title beyond configured title set on initialization
 *
 *  @param title The desired title to set on the view controller
 */
-(void)setTableDescriptorViewControllerTitle:(NSString* _Nonnull)title;

/**
 *  Set the current Table Descriptor
 *
 *  @param tableDescriptor The table descriptor
 */
-(void)setTableDescriptor:(NUOTableDescriptor* _Nonnull)tableDescriptor;

-(void)setRightBarButtonItemsWithBarButtonItems:(NSArray<UIBarButtonItem*>* _Nonnull)barButtonItems;

/**
 *  Reload the table descriptor on to the table view
 */
-(void)reloadTableDescriptor;

-(void)insertRowsAtIndexPaths:(NSArray<NSIndexPath*>* _Nonnull)indexPaths
             withRowAnimation:(UITableViewRowAnimation)animation;

-(void)insertRowsAtIndexPaths:(NSArray<NSIndexPath*>* _Nonnull)indexPaths
             withRowAnimation:(UITableViewRowAnimation)animation
                   completion:(void (^ _Nullable)(void))completion;

-(void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath*>* _Nonnull)indexPaths
             withRowAnimation:(UITableViewRowAnimation)animation;

-(void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath*>* _Nonnull)indexPaths
             withRowAnimation:(UITableViewRowAnimation)animation
                   completion:(void (^ _Nullable)(void))completion;

-(void)performTableViewModificationBlock:(void(^ _Nullable)(UITableView* _Nonnull tableView))modificationBlock
                         completionBlock:(void(^ _Nullable)(void))completionBlock;

-(void)performTableViewModificationBlock:(void(^ _Nullable)(UITableView* _Nonnull tableView))modificationBlock
                                animated:(BOOL)animated
                         completionBlock:(void(^ _Nullable)(void))completionBlock;

/**
 Perform a simple table view update. This will not modify any cells, but
 will recalculate all tableviewcell heights.

 @param animated Whether the operation should be animated
 @param completionBlock Called when update is complete
 */
-(void)performTableViewUpdateWithAnimated:(BOOL)animated
                          completionBlock:(void(^ _Nullable)(void))completionBlock;
/**
 *  Reload the table descriptor on to the table view
 */
-(void)reloadTableDescriptorWithCompletionBlock:(void(^ _Nullable)(void))completionBlock;

/**
 *  Reload specific rows at defined indexPaths
 *
 *  @param indexPaths A list of indexPaths to reload
 *  @param animation  The type of animation used when reloading rows
 */
-(void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath*>* _Nonnull)indexPaths
             withRowAnimation:(UITableViewRowAnimation)animation;

/**
 *  Reload specific rows at defined indexPaths
 *
 *  @param indexPaths A list of indexPaths to reload
 *  @param animation  The type of animation used when reloading rows
 *  @param completion Called when reload of rows is complete. Always called from main thread
 */
-(void)reloadRowsAtIndexPaths:(NSArray<NSIndexPath*>* _Nonnull)indexPaths
             withRowAnimation:(UITableViewRowAnimation)animation
                   completion:(void(^ _Nullable)(void))completion;
/**
 *  Instruct the table view controller to reload specific sections
 *
 *  @param indexSet  The section indicies to reload
 *  @param animation The type of animation for the reload
 */
-(void)reloadSections:(NSIndexSet* _Nonnull)indexSet
     withRowAnimation:(UITableViewRowAnimation)animation;

/**
 *  Instruct the table view controller to reload specific sections
 *
 *  @param indexSet   The section indicies to reload
 *  @param animation  The type of animation for the reload
 *  @param completion Called when reload of section is complete. Always called from main thread
 */
-(void)reloadSections:(NSIndexSet* _Nonnull)indexSet
     withRowAnimation:(UITableViewRowAnimation)animation
           completion:(void(^ _Nullable)(void))completion;
/**
 *  Instruct the table view controller to perform segue with specific identifier
 *
 *  @param identifier The identifier of the segue
 *  @param sender     The sender for the segue
 */
-(void)performSegueWithIdentifier:(NSString* _Nonnull)identifier
                           sender:(id _Nullable)sender;

/**
 *  Update the table drawn. This allows redrawing of row height changes
 */
-(void)updateTable;

/**
 *  Scroll to a specific cell descriptor
 *
 *  @param cellDescriptor The cell descriptor to scrol lto
 *  @param scrollPosition The scroll position related to the cell
 *  @param animated       Whether the scroll should be animated
 */
-(void)scrollToCellDescriptor:(NUOCellDescriptor* _Nonnull)cellDescriptor
             atScrollPosition:(UITableViewScrollPosition)scrollPosition
                     animated:(BOOL)animated;

-(void)scrollToCellDescriptor:(NUOCellDescriptor* _Nonnull)cellDescriptor
             atScrollPosition:(UITableViewScrollPosition)scrollPosition
                     animated:(BOOL)animated
              completionBlock:(void(^ _Nullable)(void))completion;

-(void)scrollToSection:(NSUInteger)section
      atScrollPosition:(UITableViewScrollPosition)scrollPosition
              animated:(BOOL)animated;

-(void)scrollToTopWithAnimated:(BOOL)animated;

/**
 *  Set the tables separator style
 *
 *  @param separatorStyle The desired separator style
 */
-(void)setTableViewSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle;

/**
 *  The the tableviews header view
 *
 *  @param tableViewHeaderView The view that will be displayed as the header for the table view
 */
-(void)setTableViewHeaderView:(UIView* _Nullable)tableViewHeaderView;

/**
 *  The the tableviews footer view
 *
 *  @param tableViewFooterView The view that will be displayed as the footer for the table view
 */
-(void)setTableViewFooterView:(UIView* _Nullable)tableViewFooterView;

/**
 *  Animate a "shake" effect on the current view controller.
 *  This is often used to provide notice that validation on the current form has failed, or an error has occured
 */
-(void)shake;

/**
 *  Instruct the view controller to cease all editing tasks on the current view controller
 */
-(void)endEditing;

/**
 *  Instruct the table to reload from the current data source
 */
-(void)reloadTable;

-(BOOL)isTableReloading;

-(void)reloadTableWithCompletionBlock:(void(^ _Nullable)(void))completionBlock;

-(void)reloadTableWithAnimated:(BOOL)animated completionBlock:(void(^ _Nullable)(void))completionBlock;

/**
 *  Provide the table view's width
 *
 *  @return The table view's width
 */
-(CGFloat)tableViewWidth;

-(void)setTitle:(NSString* _Nonnull)title;

/**
 *  Trigger the table to layout the current header contents
 *
 *  @param animated   Whether the layout should be animated
 *  @param completion Called on completion of the layout operation
 */
-(void)layoutHeaderContentsWithAnimated:(BOOL)animated
                             completion:(void(^ _Nullable)(void))completion;

/**
 *  Trigger the table to layout the current footer contents
 *
 *  @param animated   Whether the layout should be animated
 *  @param completion Called on completion of the layout operation
 */
-(void)layoutFooterContentsWithAnimated:(BOOL)animated
                             completion:(void(^ _Nullable)(void))completion;

-(void)setTopFixedHeaderContents:(NSArray<UIView*>* _Nonnull)headerContents;

-(void)setContainerHeaderContents:(NSArray<UIView*>* _Nonnull)containerHeaderContents;


/**
 Set display of container header contents
 
 @param containerHeaderContentsDisplayed whether fixed header views are displayed
 @param animated Whether animated or not
 */
-(void)setContainerHeaderContentsDisplayed:(BOOL)containerHeaderContentsDisplayed
                                  animated:(BOOL)animated;


/**
 Set display of both top and bottom fixed views

 @param fixedHeaderContentsDisplayed whether fixed header views are displayed
 @param animated Whether animated or not
 */
-(void)setFixedHeaderContentsDisplayed:(BOOL)fixedHeaderContentsDisplayed
                              animated:(BOOL)animated;

/**
 Set display of top fixed views

 @param topFixedHeaderContentsDisplayed whether fixed header views are displayed
 @param animated Whether animated or not
 */
-(void)setTopFixedHeaderContentsDisplayed:(BOOL)topFixedHeaderContentsDisplayed
                                 animated:(BOOL)animated;

/**
 Set display of bottom fixed views

 @param bottomFixedHeaderContentsDisplayed whether fixed header views are displayed
 @param animated Whether animated or not
 */
-(void)setBottomFixedHeaderContentsDisplayed:(BOOL)bottomFixedHeaderContentsDisplayed
                                    animated:(BOOL)animated;

/**
 *  Set the header contents of the table view. Each view within the list
 *  will be stacked ontop of one another using AutoLayout
 *
 *  @param headerContents The list of views to be displayed above the table
 */
-(void)setCollapsableHeaderContents:(NSArray<UIView*>* _Nonnull)headerContents;

-(void)setCollapsableHeaderContentsDisplayed:(BOOL)collapsableHeaderContentsDisplayed
                                    animated:(BOOL)animated
                                  completion:(void(^ _Nullable)(void))completion;

-(void)setBottomFixedHeaderContents:(NSArray<UIView*>* _Nonnull)headerContents;

-(void)showCollapsableHeaderView;

-(CGFloat)collapsableHeaderViewOffset;

-(CGFloat)collapsableHeaderViewHeight;

-(BOOL)isCollapsableHeaderViewFullyVisible;

-(BOOL)isCollapsableHeaderViewFullyHidden;

-(void)setCollapsableHeaderViewOffset:(CGFloat)collapsableHeaderViewOffsetChange;

-(void)changeCollapsableHeaderViewOffset:(CGFloat)collapsableHeaderViewOffsetChange;

-(void)hideCollapsableHeaderView;

-(void)setFooterViewContent:(UIView* _Nullable)footerContent;

-(void)setFooterViewContentDisplayed:(BOOL)footerViewContentDisplayed animated:(BOOL)animated;

-(BOOL)isNavigationBarHidden;

-(void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;

-(void)setStatusBarHidden:(BOOL)statusBarHidden animated:(BOOL)animated;

/**
 *  Whether the table descriptor is the top most view controller
 *  within the parent navigation controller
 *
 *  @return @YES if the table descriptor is the top most view controller
 */
-(BOOL)isVisible;


/**
 *  Whether the table descriptor is in the process of being displayed
 *  within the parent navigation controller. Value is @NO once visible
 *
 *  @return @YES if the table descriptor is in the process of being displayed
 */
-(BOOL)willBeVisible;

/**
 *  Set whether the table should display a refresh control.
 *
 *  @see onPullToRefreshFinished
 *
 *  @param refreshControlEnabled Whether the refresh control is enabled
 */
-(void)setRefreshControlEnabled:(BOOL)refreshControlEnabled;

/**
 *  Called to trigger the finish of the refresh operation
 */
-(void)onPullToRefreshFinished;

/**
 *  Retrieve the trait collection of the underlying controller
 *
 *  @return A trait collection of the underlying controller
 */
-(UITraitCollection* _Nonnull)traitCollection;

/**
 *  Retrieve the underlying view controller
 *
 *  @return The underlying view controller
 */
-(UIViewController* _Nonnull)viewController;

-(void)setTableAccessibilityIdentifier:(NSString* _Nullable)accessibilityIndentifier;

-(void)setTableAccessibilityValue:(NSString* _Nullable)accessibilityValue;

-(void)setCustomContentView:(UIView* _Nullable)customContentView;

-(void)setInteractivePopGestureRecognizerEnabled:(BOOL)enabled;

/**
 Provide the ratio between the content height and the frame height of the table

 @param ignoreFooterHeight Whether the ignore the height of the footer view, if defined.
 @return A double of the ration between the content height and frame size. A value greater than 1.0 denotes that the content height exceeds frame height.
 */
-(CGFloat)cellsViewOverrunCoefficientWithIgnoreFooterHeight:(BOOL)ignoreFooterHeight;

-(UITableViewCell* _Nullable)tableViewCellForCellDescriptor:(NUOCellDescriptor* _Nonnull)cellDescriptor;

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView* _Nonnull)scrollView;

-(void)addRightView:(UIView* _Nonnull)rightView;

-(void)removeRightView:(UIView* _Nonnull)rightView;

-(NSArray<UIView*>* _Nonnull)rightViews;

-(void)addRightViewController:(UIViewController* _Nonnull)rightViewController;

-(void)removeRightViewController:(UIViewController* _Nonnull)rightViewController;

-(UIView* _Nullable)viewForCellAtIndexPath:(NSIndexPath* _Nonnull)indexPath;

@end
