//
//  TableDescriptor.h
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

@import Foundation;
#import "NUOCellDescriptor.h"
#import "NUOTableDescriptorViewControllerDelegate.h"

typedef NSMutableDictionary<NSNumber*,NSArray<NUOCellDescriptor*>*>* MutableCellDescriptions;

typedef NSDictionary<NSNumber*,NSArray<NUOCellDescriptor*>*>* CellDescriptions;

@interface NUOTableDescriptor : NSObject <UITableViewDataSource, UITableViewDelegate>

/**
 *  Response delegate
 */
@property (nonatomic, weak, nullable) id<NUOTableDescriptorViewControllerDelegate> delegate;

/**
 *  Data object associated with descriptor
 */
@property (nonatomic, strong, nullable) NSObject* object;

//View Configuration Settings

@property (nonatomic, strong, nullable) UIView* titleView;

@property (nonatomic, strong, nullable) NSString* title;


@property (nonatomic, strong, nullable) NSString* backTitle;
/**
 *  The table style of the UITableView. This tableStyle is only effective if the
 *  table descriptor is launched from code rather than a storyboard
 */
@property (nonatomic) UITableViewStyle tableStyle;

/**
 *  Designate a right bar button item to be displayed within the UITableViewController
 *  navigation bar
 */
@property (nonatomic, nullable) UIBarButtonItem* rightBarButtonItem;

/**
 *  Designate right bar button items to be displayed within the UITableViewController
 *  navigation bar. If this is nil, fall back to `rightBarButtonItem`
 */
@property (nonatomic, nullable) NSArray<UIBarButtonItem*>* rightBarButtonItems;


/**
 *  Designate a left bar button item to be displayed within the UITableViewController
 *  navigation bar
 */
@property (nonatomic, nullable) UIBarButtonItem* leftBarButtonItem;

@property (nonatomic, nullable) UIView* headerView;

@property (nonatomic) BOOL animateTableReload;

@property (nonatomic) BOOL validationState;

/**
 *  Whether the table should end editing when reloading the table
 *
 *  Defaults to @p YES
 */
@property BOOL endEditingOnReload;

@property BOOL shouldScrollToActiveTextField;

/**
 Whether the table needs to reload trigger on view first appear.
 Defaults to NO for performance, or delated drawing
 */
@property BOOL shouldReloadTableOnFirstAppearance;

-(instancetype _Nonnull)initWithObject:(id _Nullable)object;


/**
 *  Respond when the pull down to refresh control is triggered
 */
-(void)pullDownToRefreshTriggered;

-(BOOL)validate;

/**
 *  Retrieve a list of cell descriptor keypaths that match the given validation state
 *
 *  @param validationState the validation state requested
 *
 *  @return An array of cell descriptor keypaths of cell descriptors that have the state
 *  requested
 */
-(NSArray* _Nonnull)keyPathsWithValidationState:(BOOL)validationState;

/**
 * Whether the description is empty or not
 *
 * @return @p YES if the description has at least one cell descriptor, otherwise @p NO
 */
-(BOOL)hasEmptyDescription;

/**
 *  Retrieve the number of cell descriptor sections
 *
 *  @return The list of cell descriptors for section
 */
-(NSUInteger)numberOfCellDescriptorSections;

/**
 *  Retrieve all the cell descriptors for a specific section
 *
 *  @param section The section that will contain cell descriptors
 *
 *  @return All cell descriptors within specific section
 */
-(NSArray<NUOCellDescriptor*>* _Nullable)cellDescriptorsForSection:(NSUInteger)section;

/**
 *  Retrieve all cell descriptors of the table
 *
 *  @return A list of cell descriptors of the table
 */
-(NSArray<NUOCellDescriptor*>* _Nonnull)allCellDescriptors;


-(void)pushDownAndInsertCellDescriptors:(NSArray<NUOCellDescriptor*>* _Nonnull)cellDescriptors section:(NSUInteger)section;

/**
 Delete all cell descriptors within the section. To remain consistent, all
 sections after the deleted sections are filled down, so section indicies for
 the moved cell descriptors will change

 @param section The section to remove all cell descriptors for and fill in with
                later sections
 */
-(void)deleteAndFillDownCellDescriptorsAtSection:(NSUInteger)section;

-(void)deleteCellDescriptorAtIndexPath:(NSIndexPath* _Nonnull)indexPath;

-(void)replaceCellDescriptor:(NUOCellDescriptor* _Nonnull)cellDescriptor indexPath:(NSIndexPath* _Nonnull)indexPath;

-(void)moveCellDescriptorFromIndexPath:(NSIndexPath* _Nonnull)fromIndexPath toIndexPath:(NSIndexPath* _Nonnull)toIndexPath;

-(void)insertCellDescriptor:(NUOCellDescriptor* _Nonnull)cellDescriptor indexPath:(NSIndexPath* _Nonnull)indexPath;

/**
 *  Define the cell descriptors for a specific section
 *
 *  @param cellDescriptors The cell descriptors for a specific section
 *  @param section         The section of cell descriptors
 */
-(void)setCellDescriptors:(NSArray<NUOCellDescriptor*>* _Nonnull)cellDescriptors forSection:(NSUInteger)section;

/**
 *  Retrieve the cell descriptor for a specific index path
 *
 *  @param indexPath The index path of cell descriptor
 *
 *  @return The cell descriptor if one exists and index path section or row. Nil if either
 *  section or row isn't real.
 */
-(NUOCellDescriptor* _Nullable)cellDescriptorAtIndexPath:(NSIndexPath* _Nonnull)indexPath;

/**
 *  Retrieve the appropiate index path for a cell descriptor
 *
 *  @param cellDescriptor The cell descriptor
 *
 *  @return An index path that
 */
-(NSIndexPath* _Nullable)indexPathForCellDescriptor:(NUOCellDescriptor* _Nullable)cellDescriptor;

/**
 *  Retrieve the section title for a specific section
 *
 *  @param section The section to title
 *
 *  @return A title for the section, or nil if no title is set for section
 */
-(NSString* _Nullable)sectionTitleForSection:(NSUInteger)section;

/**
 *  Define the section title for a specific section
 *
 *  @param title   The title for the specific section
 *  @param section The section to title
 */
-(void)setSectionTitle:(NSString* _Nullable)title forSection:(NSUInteger)section;

/**
 *  Define the section title view for a specific section
 *
 *  @param titleView   The title view for the specific section
 *  @param section     The section to title
 */
-(void)setSectionTitleView:(UIView* _Nullable)titleView forSection:(NSUInteger)section;

-(UIView* _Nullable)sectionTitleViewForSection:(NSUInteger)section;

-(void)removeAllSectionTitleViews;

/**
*  Define the section footer view for a specific section
*
*  @param footerView   The footer view for the specific section
*  @param section      The section for footer view
*/
-(void)setSectionFooterView:(UIView* _Nullable)footerView forSection:(NSUInteger)section;

/**
 *  Retrieve the section footer view for a specific section
 *
 *  @param section The section
 *
 *  @return The section footer view, or @p nil if no footer view is defined for section
 */
-(UIView* _Nullable)sectionFooterViewForSection:(NSUInteger)section;

/**
 *  The title to be displayed for the table
 *
 *  @return The table title, or nil if none is set
 */
-(NSString* _Nullable)title;

/**
 *  Load the Table Descriptor
 *
 *  @remarks This should not be called directly. Look into reloadDescription method, if the 
 *  table descriptor needs to be refreshed
 */
-(void)loadDescription;

/**
 *  Reload the Table Descriptor
 *
 *  @remarks This should be used when the table descriptor needs to be refreshed
 */
-(void)reloadDescription;

-(void)reloadSections:(NSIndexSet* _Nonnull)indexSet;

-(void)reloadSections:(NSIndexSet* _Nonnull)indexSet withRowAnimation:(UITableViewRowAnimation)rowAnimation;

-(void)reloadCellDescriptors:(NSArray* _Nonnull)cellDescriptors;

-(void)reloadCellDescriptors:(NSArray* _Nonnull)cellDescriptors withRowAnimation:(UITableViewRowAnimation)rowAnimation;

/**
 *  Respond when a cell descriptor has been selected
 *
 *  @param cellDescriptor The cell descriptor that has been selected
 *  @param indexPath      The index path of the selection
 *
 *  @return Whether the selection action should bubble
 */
-(BOOL)onSelectionOfCellDescriptor:(NUOCellDescriptor* _Nonnull)cellDescriptor atIndexPath:(NSIndexPath* _Nonnull)indexPath;

/**
 *  Register Table Descriptor with the UITableView.
 *
 *  @remarks This should not be called directly. 
 *
 *  Subclasses can override this method to modify the UITableView look.
 *  Subclasses should always call @p super implementation of this method.
 *
 *  @param tableView The UITableView
 */
-(void)registerWithTableView:(UITableView* _Nonnull)tableView;

/**
 *  Respond when the table view will appear within the view hierarchy
 */
-(void)willAppear;

-(void)willFirstAppear;

-(void)willReappear;

-(void)didFirstAppear;

/**
 *  Respond when the table view did appear within the view hierarchy
 */
-(void)didAppear;

-(void)willDisappear;

-(void)willBeDismissed;

-(void)tableDidReload;

-(void)willDisplayKeyboardWithFirstResponder:(UIResponder* _Nonnull)responder;

-(void)willHideKeyboard;

-(void)didHideKeyboard;

-(void)viewDidLayoutSubviews;
/**
 *  Provide the height for a table view section view
 *
 *  @param section The section
 *
 *  @return A float representing the height that the section header view should
 *  take, or @p 0 if the section view should not be displayed
 */
-(CGFloat)heightForTableViewSection:(NSInteger)section;


@end
