//
//  TableDescriptor.m
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

#import "NUOTableDescriptor.h"
#import "NUOTableDescriptorViewController.h"
@import PureLayout;

@interface NUOTableDescriptor ()
@property (nonatomic, strong) NSMutableDictionary* sectionTitles;
@property (nonatomic, strong) NSMutableDictionary* sectionTitleViews;
@property (nonatomic, strong) NSMutableDictionary* sectionFooterViews;

@property (nonatomic, strong) MutableCellDescriptions cellDescriptions;
@property (nonatomic, strong) dispatch_queue_t cellDescriptionsQueue;

@property (nonatomic, strong) CellDescriptions  __cellDescriptions;
@property (nonatomic, strong) dispatch_queue_t __cellDescriptionsQueue;

@property (nonatomic, strong) NSMutableSet<NSString*>* registeredCellDescriptorIdentifiers;
@end

@implementation NUOTableDescriptor

@synthesize cellDescriptions = _cellDescriptions;
@synthesize __cellDescriptions = ___cellDescriptions;

-(instancetype _Nonnull)initWithObject:(id _Nullable)object
{
    self = [self init];
    if(self) {
        _object = object;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tableStyle = UITableViewStylePlain;
        self.endEditingOnReload = YES;
        self.cellDescriptionsQueue = dispatch_queue_create("com.nuorder.nuotabledescriptor.cells",
                                                           DISPATCH_QUEUE_SERIAL);
        self.__cellDescriptionsQueue = dispatch_queue_create("com.nuorder.nuotabledescriptor.__cells",
                                                             DISPATCH_QUEUE_SERIAL);
        self.__cellDescriptions = @{};
        [self load];
    }
    return self;
}

-(void)setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems
{
    _rightBarButtonItems = rightBarButtonItems;
    [self.delegate setRightBarButtonItemsWithBarButtonItems:rightBarButtonItems];
}

-(void)deleteAndFillDownCellDescriptorsAtSection:(NSUInteger)section
{
    [self removeAllCellDescriptorsForSection:section];

    NSUInteger currentFillSection = section;
    
    for (NSNumber* sectionNumber in [[self.cellDescriptions allKeys] sortedArrayUsingSelector:@selector(compare:)]) {
        NSUInteger currentSection = [sectionNumber unsignedIntegerValue];
        if(currentSection > currentFillSection) {
            NSArray<NUOCellDescriptor*>* cellDescriptors = [self.cellDescriptions objectForKey:sectionNumber];
            [self removeAllCellDescriptorsForSection:currentSection];
            [self setCellDescriptors:cellDescriptors forSection:currentFillSection];
            currentFillSection = currentSection;
        }
    }
}

-(void)pushDownAndInsertCellDescriptors:(NSArray<NUOCellDescriptor*>*)cellDescriptors section:(NSUInteger)section
{
    //Sort section Numbers, and start at last section, and increment
    for (NSNumber* sectionNumber in [[[self.cellDescriptions allKeys] sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator]) {
        NSUInteger currentSection = [sectionNumber unsignedIntegerValue];
        if(currentSection >= section) {
            NSArray<NUOCellDescriptor*>* cellDescriptors = [self.cellDescriptions objectForKey:sectionNumber];
            [self removeAllCellDescriptorsForSection:currentSection];
            [self setCellDescriptors:cellDescriptors forSection:currentSection+1];
        }
    }
    [self setCellDescriptors:cellDescriptors forSection:section];
}

-(void)deleteCellDescriptorAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray<NUOCellDescriptor*>* cellDescriptors = [self cellDescriptorsForSection:indexPath.section];

    if(indexPath.item < [cellDescriptors count]) {
        NSMutableArray* mutableCellDescriptors = [cellDescriptors mutableCopy];
        [mutableCellDescriptors removeObjectAtIndex:indexPath.item];
        [self setCellDescriptors:[mutableCellDescriptors copy] forSection:indexPath.section];
    }
}

-(void)replaceCellDescriptor:(NUOCellDescriptor*)cellDescriptor indexPath:(NSIndexPath*)indexPath
{
    NSArray<NUOCellDescriptor*>* cellDescriptors = [self cellDescriptorsForSection:indexPath.section];

    NSMutableArray* mutableCellDescriptors = [cellDescriptors mutableCopy];

    if(indexPath.item <= [cellDescriptors count] ) {
        [mutableCellDescriptors replaceObjectAtIndex:indexPath.item withObject:cellDescriptor];
        [self setCellDescriptors:[mutableCellDescriptors copy] forSection:indexPath.section];
    }
}

-(void)moveCellDescriptorFromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath
{
    NUOCellDescriptor* cellDescriptor = [self cellDescriptorAtIndexPath:fromIndexPath];

    [self deleteCellDescriptorAtIndexPath:fromIndexPath];

    [self insertCellDescriptor:cellDescriptor indexPath:toIndexPath];
}

-(void)insertCellDescriptor:(NUOCellDescriptor*)cellDescriptor indexPath:(NSIndexPath*)indexPath
{
    NSArray<NUOCellDescriptor*>* cellDescriptors = [self cellDescriptorsForSection:indexPath.section] ?: @[];

    NSMutableArray* mutableCellDescriptors = [cellDescriptors mutableCopy];

    if(indexPath.item <= [cellDescriptors count] ) {
        [mutableCellDescriptors insertObject:cellDescriptor atIndex:indexPath.item];
        [self setCellDescriptors:[mutableCellDescriptors copy] forSection:indexPath.section];
    }
}
-(void)removeAllCellDescriptorsForSection:(NSUInteger)section
{
    dispatch_sync(self.cellDescriptionsQueue, ^{
        [_cellDescriptions removeObjectForKey:@(section)];
    });
}

-(void)setCellDescriptors:(NSArray*)cellDescriptors forSection:(NSUInteger)section
{
    dispatch_sync(self.cellDescriptionsQueue, ^{
        [_cellDescriptions setObject:cellDescriptors forKey:@(section)];
    });
}

-(NSUInteger)numberOfCellDescriptorSections
{
    return [[[self.cellDescriptions allKeys] valueForKeyPath:@"@max.self"] unsignedIntegerValue]+1;
}

-(NSArray*)cellDescriptorsForSection:(NSUInteger)section
{
    return [self.cellDescriptions objectForKey:@(section)];
}

-(NSDictionary<NSNumber*, NSArray<NUOCellDescriptor*>*>*)drawnCellDescriptors
{
    return [self.__cellDescriptions copy];
}

-(NSDictionary<NSNumber*, NSArray<NUOCellDescriptor*>*>*)pendingCellDescriptors
{
    return [self.cellDescriptions copy];
}

-(NSArray*)drawnCellDescriptorsForSection:(NSUInteger)section
{
    return [self.__cellDescriptions objectForKey:@(section)];
}

-(NSArray*)allCellDescriptors
{
    NSMutableArray* allCellDescriptors = [[NSMutableArray alloc] init];

    for (NSArray* cellDescriptors in [self.cellDescriptions allValues]) {
        [allCellDescriptors addObjectsFromArray:cellDescriptors];
    }
    return [allCellDescriptors copy];
}

-(NUOCellDescriptor*)stagedCellDescriptorAtIndexPath:(NSIndexPath*)indexPath;
{
    NSArray* section = [self.cellDescriptions objectForKey:@(indexPath.section)];
    if(indexPath.row < [section count]) {
        return [section objectAtIndex:indexPath.row];
    }
    return nil;
}

-(NUOCellDescriptor*)cellDescriptorAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray* section = [self.__cellDescriptions objectForKey:@(indexPath.section)];
    if(indexPath.row < [section count]) {
        return [section objectAtIndex:indexPath.row];
    }
    return nil;
}

-(NSIndexPath*)indexPathForCellDescriptor:(NUOCellDescriptor *)cellDescriptor
{
    for (NSNumber* section in [self.__cellDescriptions allKeys]) {
        NSArray* sectionCellDescriptors = [self.__cellDescriptions objectForKey:section];
        NSUInteger row = 0;
        for (NUOCellDescriptor* sectionCellDescriptor in sectionCellDescriptors) {
            if(sectionCellDescriptor == cellDescriptor) {
                return [NSIndexPath indexPathForRow:row inSection:[section unsignedIntegerValue]];
            }
            row++;
        }
    }
    return nil;
}

-(void)setSectionTitle:(NSString*)title forSection:(NSUInteger)section
{
    id value = title;
    if(!value) {
        value = [NSNull null];
    }
    [self.sectionTitles setObject:value forKey:@(section)];
}

-(NSString*)sectionTitleForSection:(NSUInteger)section
{
    id value = [self.sectionTitles objectForKey:@(section)];
    if([value isEqual:[NSNull null]]) {
        return nil;
    }
    return value;
}


-(void)setSectionTitleView:(UIView*)titleView forSection:(NSUInteger)section
{
    id value = titleView;
    if(!value) {
        value = [NSNull null];
    }
    [self.sectionTitleViews setObject:value forKey:@(section)];
}

-(void)removeAllSectionTitleViews
{
    [self.sectionTitleViews removeAllObjects];
}

/**
 *  Define the section footer view for a specific section
 *
 *  @param footerView   The footer view for the specific section
 *  @param section      The section to title
 */
-(void)setSectionFooterView:(UIView*)footerView forSection:(NSUInteger)section
{
    id value = footerView;
    if(!value) {
        value = [NSNull null];
    }
    [self.sectionFooterViews setObject:value forKey:@(section)];
}

-(UIView*)sectionTitleViewForSection:(NSUInteger)section
{
    id value = [self.sectionTitleViews objectForKey:@(section)];
    if([value isEqual:[NSNull null]]) {
        return nil;
    }
    return value;
}

-(UIView*)sectionFooterViewForSection:(NSUInteger)section
{
    id value = [self.sectionFooterViews objectForKey:@(section)];
    if([value isEqual:[NSNull null]]) {
        return nil;
    }
    return value;
}

-(BOOL)hasEmptyDescription
{
    NSArray<NSArray<NUOCellDescriptor*>*>* allCellDescriptors = [self.__cellDescriptions allValues];

    for (NSArray<NUOCellDescriptor*>* cellDescriptors in allCellDescriptors) {
        if([cellDescriptors count] > 0) {
            return NO;
        }
    }
    return YES;
}

-(NSUInteger)numberOfSections
{
    if(!self.__cellDescriptions) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"__cellDescriptions is nil" userInfo:nil];
    }

    NSArray<NSNumber*>* sectionKeys = [self.__cellDescriptions allKeys];

    NSUInteger numberOfSections = 0;
    for (NSNumber* sectionKey in sectionKeys) {
        NSUInteger unsignedIntegerValue = [sectionKey unsignedIntegerValue];
        if(unsignedIntegerValue > numberOfSections) {
            numberOfSections = unsignedIntegerValue;
        }
    }
    return sectionKeys.count ? numberOfSections+1 : 0;
}

-(NSUInteger)numberOfRowsForSection:(NSUInteger)section
{
    if(!self.__cellDescriptions) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"__cellDescriptions is nil" userInfo:nil];
    }
    return [[self.__cellDescriptions objectForKey:@(section)] count];
}

-(void)loadDescription
{

}

-(void)load
{
    self.sectionTitles = [[NSMutableDictionary alloc] init];
    self.sectionTitleViews = [[NSMutableDictionary alloc] init];
    self.sectionFooterViews = [[NSMutableDictionary alloc] init];
    self.cellDescriptions = [[NSMutableDictionary alloc] init];
    self.registeredCellDescriptorIdentifiers = [[NSMutableSet alloc] init];
}

-(void)cacheCellDescriptorsForRedraw
{
    self.__cellDescriptions = [self.cellDescriptions copy];
}

-(void)setCellDescriptorsForRedraw:(NSDictionary<NSNumber*, NSArray<NUOCellDescriptor*>*>*)cellDescriptorsForRedraw
{
    self.__cellDescriptions = [cellDescriptorsForRedraw copy];
}

-(void)reloadDescription
{
    [self load];
    [self loadDescription];
}


-(void)reloadSections:(NSIndexSet*)indexSet
{
    [self reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
}

-(void)reloadCellDescriptors:(NSArray*)cellDescriptors
{
    [self reloadCellDescriptors:cellDescriptors withRowAnimation:UITableViewRowAnimationFade];
}

-(void)reloadCellDescriptors:(NSArray*)cellDescriptors withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    NSMutableArray* indexPaths = [[NSMutableArray alloc] init];

    for (NUOCellDescriptor* cellDescriptor in cellDescriptors) {
        NSIndexPath* indexPath = [self indexPathForCellDescriptor:cellDescriptor];
        if(indexPath) {
            [indexPaths addObject:indexPath];
        }
        //Inform cell descriptor of impending reload
        [cellDescriptor prepareForReload];
    }

    [self.delegate reloadRowsAtIndexPaths:indexPaths withRowAnimation:rowAnimation];
}

-(void)reloadSections:(NSIndexSet*)indexSet withRowAnimation:(UITableViewRowAnimation)rowAnimation
{
    [self.delegate reloadSections:indexSet withRowAnimation:rowAnimation];
}

-(void)registerWithTableView:(UITableView*)tableView
{
    tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRowsForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NUOCellDescriptor* cellDescriptor = [self cellDescriptorAtIndexPath:indexPath];

    [self registerCellDescriptor:cellDescriptor withTableView:tableView];

    NSString* reuseIdentifier = [cellDescriptor reuseIdentifier];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if(![cellDescriptor delayCellConfigurationUntilDisplay]) {
        [self configureTableViewCell:cell forCellDescriptor:cellDescriptor];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NUOCellDescriptor* cellDescriptor = [self cellDescriptorAtIndexPath:indexPath];

    if([cellDescriptor delayCellConfigurationUntilDisplay]) {
        [self configureTableViewCell:cell forCellDescriptor:cellDescriptor];
    }

    [cellDescriptor tableViewCellWillBeginDisplay:cell];
}

-(void)configureTableViewCell:(UITableViewCell*)cell forCellDescriptor:(NUOCellDescriptor*)cellDescriptor;
{
    [cellDescriptor configureTableViewCell:cell withTableDescriptorObject:self.object];

    if(cellDescriptor.useConfigureCellContentView) {
        [cellDescriptor configureCellContentView:cell.contentView];
    }
}
-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NUOCellDescriptor* cellDescriptor = [self cellDescriptorAtIndexPath:indexPath];

    [cellDescriptor tableViewCellWillEndDisplay:cell];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self sectionTitleForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat sectionHeaderHeight = 0;

    UIView* view = [self sectionTitleViewForSection:section];
    if(view) {
        sectionHeaderHeight = CGRectGetHeight(view.frame);
    } else {
        sectionHeaderHeight = [self heightForTableViewSection:section];
    }
    return sectionHeaderHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    UIView* view = [self sectionFooterViewForSection:section];
    if(view) {
        return CGRectGetHeight(view.frame);
    }
    return 0.f;
}

-(CGFloat)heightForTableViewSection:(NSInteger)section
{
    return 0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self sectionTitleViewForSection:section];
}

-(void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
}

-(void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section
{
}

-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [self sectionFooterViewForSection:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NUOCellDescriptor* cellDescriptor = [self cellDescriptorAtIndexPath:indexPath];

    CGFloat rowHeightFromCell = 0;

    if([cellDescriptor conformsToProtocol:@protocol(NUOCellDescriptorDynamicRowHeightCalculator) ]) {
        NUOCellDescriptor<NUOCellDescriptorDynamicRowHeightCalculator>* rowHeightCalculatorCellDescriptor = (NUOCellDescriptor<NUOCellDescriptorDynamicRowHeightCalculator>*)cellDescriptor;

        //Detect whether the cell descriptor requires dynamic row height
        if([rowHeightCalculatorCellDescriptor dynamicRowHeight]) {

            [self registerCellDescriptor:cellDescriptor withTableView:tableView];

            //Test for cached row height
            if([rowHeightCalculatorCellDescriptor respondsToSelector:@selector(cachedRowHeightWithTableView:withTableDescriptorObject:)]) {
                rowHeightFromCell = [rowHeightCalculatorCellDescriptor cachedRowHeightWithTableView:tableView withTableDescriptorObject:self.object];
            }
            
            if(rowHeightFromCell != 0) {
                return rowHeightFromCell;
            }
            
            //If the cell descriptor does not need table view cell instance to calculate height, just pass tableview
            if([rowHeightCalculatorCellDescriptor respondsToSelector:@selector(rowHeightWithTableView:withTableDescriptorObject:)]) {
                rowHeightFromCell = [rowHeightCalculatorCellDescriptor rowHeightWithTableView:tableView withTableDescriptorObject:self.object];

            } else if([rowHeightCalculatorCellDescriptor respondsToSelector:@selector(rowHeightWithTableView:tableViewCell:withTableDescriptorObject:)]) {

                Class cellDescriptorClass = [cellDescriptor class];
                UITableViewCell* cell = [[[cellDescriptorClass cellClass] alloc] initWithFrame:CGRectZero];
                rowHeightFromCell = [rowHeightCalculatorCellDescriptor rowHeightWithTableView:tableView tableViewCell:cell withTableDescriptorObject:self.object];
            }

        }
    }

    if(!rowHeightFromCell) {
        rowHeightFromCell = [cellDescriptor rowHeight];
    }

    return rowHeightFromCell;

}

/**
 *  Register the Cell Descriptor with the Table View.
 *
 *  @param cellDescriptor The cell descriptor
 *  @param tableView      The table view
 *
 *  @remarks This allows the cell descriptor opportunity to register its nib file as the tableviewcell
 *  To prevent multiple registration attempts by the same CellDescriptor type, a list is kept 
 *  with the CellDescriptor and reregistration is restricted.
 */
-(void)registerCellDescriptor:(NUOCellDescriptor*)cellDescriptor withTableView:(UITableView*)tableView
{
    if(cellDescriptor && ![self.registeredCellDescriptorIdentifiers containsObject:[cellDescriptor reuseIdentifier]]) {
        [cellDescriptor registerWithTableView:tableView];
        [self.registeredCellDescriptorIdentifiers addObject:[cellDescriptor reuseIdentifier]];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self didSelectRowAtIndexPath:indexPath];
}

-(void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Prevent row selection if selection is made while current view is not visible
    if(![self.delegate isVisible]) {
        return;
    }
    
    NUOCellDescriptor* cellDescriptor = [self cellDescriptorAtIndexPath:indexPath];

    BOOL proceed = YES;
    
    if(cellDescriptor.selectionBlock) {
        proceed = cellDescriptor.selectionBlock(cellDescriptor);
    }

    if(!proceed) {
        return;
    }

    proceed = [self onSelectionOfCellDescriptor:cellDescriptor atIndexPath:indexPath];

    if(!proceed) {
        return;
    }
}

-(void)segueToTableDescriptor:(NUOTableDescriptor*)tableDescriptor
{
    NUOTableDescriptorViewController* tableDescriptorViewController = [[NUOTableDescriptorViewController alloc] initWithStyle:tableDescriptor.tableStyle tableDescriptor:tableDescriptor];
    [self.delegate pushViewController:tableDescriptorViewController];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NUOCellDescriptor* cellDescriptor = [self cellDescriptorAtIndexPath:indexPath];

    BOOL proceed = YES;

    if(cellDescriptor.accessorySelectionBlock) {
        proceed = cellDescriptor.accessorySelectionBlock(cellDescriptor);
    }

    if(!proceed) {
        return;
    }
}

-(BOOL)onSelectionOfCellDescriptor:(NUOCellDescriptor *)cellDescriptor atIndexPath:(NSIndexPath*)indexPath;
{
    return YES;
}

-(void)willAppear
{

}

-(void)willFirstAppear
{
    if(self.shouldReloadTableOnFirstAppearance) {
        [self.delegate reloadTable];
    }
}

-(void)willReappear
{
    
}

-(void)didFirstAppear
{
    
}

-(void)didAppear
{
    
}

-(void)willDisappear
{
    
}

-(void)willBeDismissed
{
    
}

-(void)willDisplayKeyboardWithFirstResponder:(UIResponder*)responder;
{

}

-(void)willHideKeyboard
{

}

-(void)didHideKeyboard
{

}

-(void)tableDidReload
{
    
}

-(void)viewDidLayoutSubviews
{
    
}

-(void)pullDownToRefreshTriggered
{

}

-(BOOL)validate
{
    // @@ 3372 End editing before validation
    [self.delegate endEditing];
    self.validationState = YES;
    BOOL valid = YES;
    for (NSNumber* section in [self.cellDescriptions allKeys]) {
        NSArray* sectionCellDescriptors = [self.cellDescriptions objectForKey:section];
        NSError* displayedError;
        for (NUOCellDescriptor* sectionCellDescriptor in sectionCellDescriptors) {
            if(![sectionCellDescriptor isValidWithObject:self.object displayedError:&displayedError]) {
                valid = NO;
                break;
            }
        }
    }
    return valid;
}

-(NSArray*)keyPathsWithValidationState:(BOOL)validationState
{
    NSMutableArray* keyPaths = [NSMutableArray array];
    for (NSNumber* section in [self.cellDescriptions allKeys]) {
        NSArray* sectionCellDescriptors = [self.cellDescriptions objectForKey:section];
        for (NUOCellDescriptor* sectionCellDescriptor in sectionCellDescriptors) {
            NSError* displayedError;
            BOOL isValid = [sectionCellDescriptor isValidWithObject:self.object displayedError:&displayedError];
            if(isValid == validationState) {
                if(sectionCellDescriptor.keyPath) {
                    [keyPaths addObject:sectionCellDescriptor.keyPath];
                }
            }
        }
    }
    return keyPaths;
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self.delegate scrollViewDidEndScrollingAnimation:scrollView];
}

#pragma mark Cell Descriptions Dispatch Queue

-(MutableCellDescriptions)cellDescriptions
{
    __block MutableCellDescriptions cellDescriptions;
    dispatch_sync(self.cellDescriptionsQueue, ^{
        cellDescriptions = [_cellDescriptions mutableCopy];
    });
    return cellDescriptions;
}

-(void)setCellDescriptions:(MutableCellDescriptions)cellDescriptions
{
    dispatch_sync(self.cellDescriptionsQueue, ^{
        _cellDescriptions = cellDescriptions;
    });
}

-(CellDescriptions)__cellDescriptions
{
    __block CellDescriptions cellDescriptions;
    dispatch_sync(self.__cellDescriptionsQueue, ^{
        cellDescriptions = [___cellDescriptions copy];
    });
    return cellDescriptions;
}

-(void)set__cellDescriptions:(CellDescriptions)cellDescriptions
{
    dispatch_sync(self.__cellDescriptionsQueue, ^{
        ___cellDescriptions = cellDescriptions;
    });
}

@end
