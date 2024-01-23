//
//  CellDescriptor.h
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

@import Foundation;
#import <UIKit/UIKit.h>
#import "Identifiable.h"
#import "Displayable.h"
@class NUOCellDescriptor;
@class NUOTableDescriptor;

@protocol NUOCellDescriptorDynamicRowHeightCalculator <NSObject>

-(BOOL)dynamicRowHeight;

@optional

/**
 *  Dynamically calculate row height knowing the UITableView
 *
 *  @remarks This is very helpful for allowing custom height calculation of table view cell
 *
 *  @param tableView     The UITableView
 *  @param object        The data object for the table descriptor. The cell descriptor's keypath
 *  references the applicable value for cell within object.

 *  @return The row height of the cell
 */
-(CGFloat)rowHeightWithTableView:(UITableView* _Nonnull)tableView withTableDescriptorObject:(id _Nullable)object;

/**
 *  Dynamically calculate row height knowing the UITableView, and UITableViewCell representing
 *  the cell descriptor.
 *
 *  @remarks This is very helpful for allowing custom height calculation of table view cell
 *
 *  @param tableView     The UITableView
 *  @param tableViewCell The UITableViewCell
 *  @param object        The data object for the table descriptor. The cell descriptor's keypath
 *  references the applicable value for cell within object.

 *  @return The row height of the cell
 */
-(CGFloat)rowHeightWithTableView:(UITableView* _Nonnull)tableView tableViewCell:(UITableViewCell* _Nonnull)tableViewCell withTableDescriptorObject:(id _Nullable )object;

/**
 Allow support for a cached row height without the need to create a table view cell for initial row height calculation.
 Returning a value of nonzero will be intepreted as a valid hieght
 
 @param tableView The table view
 @param object The table descriptor object
 @return A value of nonzero for cached row height
 */
-(CGFloat)cachedRowHeightWithTableView:(UITableView* _Nonnull)tableView withTableDescriptorObject:(id _Nullable)object;
@end

@protocol NUOCellDescriptorValidator <NSObject>

-(BOOL)cellDescriptor:(NUOCellDescriptor* _Nonnull)cellDescriptor isValueValid:(id _Nullable)value displayedError:(NSError* _Nullable * _Nullable)displayedError;

@end

typedef NSString* _Nullable(^DisplayStringFormatterBlock)(id _Nullable);
typedef BOOL  (^ValidationBlock)(id _Nullable value, NSError* _Nullable * _Nullable displayedError);
typedef BOOL (^SelectionBlock)(NUOCellDescriptor* _Nullable cellDescriptor);

@interface NUOCellDescriptor : NSObject

+(Class _Nonnull)cellClass;

+(NSString* _Nonnull)reuseIdentifier;

-(NSString* _Nonnull)reuseIdentifier;

/**
 *  The data object associated with the cell descriptor
 */
@property (nonatomic, strong, nullable) id object;

/**
 *  The keypath relationship between the cell, and the table descriptors data object
 */
@property (nullable) NSString* keyPath;

/**
 *  Whether the cell should be styled as the user is required to provide information
 */
@property BOOL required;

/**
 *  Whether the cell should be displayed within the parent
 */
@property (nonatomic) BOOL displayed;

/**
 *  Block called on selection. If @p YES is returned from the block, then the selection will bubble
 */
@property (nonatomic, copy, nullable) SelectionBlock selectionBlock;

/**
 *  Block called on accessory selection. If @p YES is returned from the block, then the selection will bubble
 */
@property (nonatomic, copy, nullable) SelectionBlock accessorySelectionBlock;

@property (nonatomic, copy, nullable) ValidationBlock validationBlock;

@property (nonatomic, weak, nullable) id<NUOCellDescriptorValidator> validator;

-(BOOL)isValidWithObject:(id _Nullable)object displayedError:(NSError* _Nonnull* _Nonnull)displayedError;

//Cell display

/**
 *  The UITableViewCell's accessory type to display
 */
@property UITableViewCellAccessoryType cellAccessoryType;

@property (nullable) UIView* cellAccessoryView;

/**
 *  The UITableViewCell's selection style to display
 */
@property UITableViewCellSelectionStyle cellSelectionStyle;

@property (nullable) UIColor* cellBackgroundColor;

/**
 *  The UITableViewCell's rowHeight
 */
@property (nonatomic) CGFloat rowHeight;

/**
 *  Provide a formatter block to format display value as desired string
 */
@property (nonatomic, copy, nullable) DisplayStringFormatterBlock displayStringFormatterBlock;

/**
 *  Use configureCellContentView: instead of usual tableview cell configuration;
 */
@property BOOL useConfigureCellContentView;

/**
 Whether to delay cell configuration until it would be displayed. Defaults to YES
 */
@property BOOL delayCellConfigurationUntilDisplay;

@property (nullable) UIColor* borderColor;

@property UIRectEdge borderEdges;
/**
 *  Register CellDescriptors NIBs with the UITableView for cell creation
 *
 *  @param tableView The table view to register NIBs with
 */
-(void)registerWithTableView:(UITableView* _Nonnull)tableView;

@property (nullable) NSDictionary* selectionViewControllerTextAttributes;

/**
 *  Configure the UITableViewCell with access to the table descriptor object
 *
 *  @param tableViewCell The table view cell that was created to represent the cell descriptor
 *  within the UITableView
 *  @param object        The data object for the table descriptor. The cell descriptor's keypath
 *  references the applicable value for cell within object.
 */
-(void)configureTableViewCell:(UITableViewCell* _Nonnull)tableViewCell withTableDescriptorObject:(id _Nullable)object;


/**
 Triggered when the table view cell will appear

 @param tableViewCell The table view cell
 */
-(void)tableViewCellWillBeginDisplay:(UITableViewCell* _Nonnull)tableViewCell;

/**
 Triggered when the table view cell will go offscreen

 @param tableViewCell The table view cell
 */
-(void)tableViewCellWillEndDisplay:(UITableViewCell* _Nonnull)tableViewCell;

/**
 *  Configure the cell's content view
 *
 *  @param contentView The cell's content view
 */
-(void)configureCellContentView:(UIView* _Nonnull)contentView;

/**
 *  Respond when the cell has been selected
 */
-(void)onSelection;



-(NSString* _Nullable)displayStringFromObject:(id _Nullable)object;


/**
 *  Calculate the appropiate display string for object value.
 *
 *  @param value The object value to be displayed
 *
 *  @return A string that best represented the display string of value
 *
 *  @remarks The calculation will first leverage `displayStringFormatterBlock` if set
 *  If not, checks to see if the value is `Displayable`.
 *  If not, uses value's description.
 *
 */
-(NSString* _Nullable)displayStringFromValue:(id _Nullable)value;

/**
 *  Allow the Cell Descriptor to prepare for reloading
 */
-(void)prepareForReload;

-(id<NSObject> _Nonnull)uniqueIdentifier;


-(BOOL)isCellDescriptorEqualToCellDescriptor:(NUOCellDescriptor* _Nonnull)cellDescriptor;

@end
