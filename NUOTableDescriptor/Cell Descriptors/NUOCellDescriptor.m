//
//  CellDescriptor.m
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

#import "NUOCellDescriptor.h"

@interface NUOCellDescriptor ()
@property (nonatomic) NSUUID* uuid;
@end

@implementation NUOCellDescriptor

-(id)init
{
    self = [super init];
    if(self) {
        self.cellAccessoryType = UITableViewCellAccessoryNone;
        self.cellSelectionStyle = UITableViewCellSelectionStyleDefault;
        self.delayCellConfigurationUntilDisplay = YES;
        self.displayed = YES;
        self.uuid = [[NSUUID alloc] init];
    }
    return self;
}

-(CGFloat)rowHeight
{
    if(_rowHeight) {
        return _rowHeight;
    }
    return 44.0f;
}

-(void)onSelection
{
    
}

-(void)prepareForReload
{

}

+(Class)cellClass
{
    return [UITableViewCell class];
}

+(NSString*)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

-(NSString*)reuseIdentifier
{
    return [[self class] reuseIdentifier];
}

-(void)registerWithTableView:(UITableView*)tableView
{
    [tableView registerClass:[[self class] cellClass] forCellReuseIdentifier:[self reuseIdentifier]];
}

-(void)configureTableViewCell:(UITableViewCell*)tableViewCell withTableDescriptorObject:(id)object;
{
    tableViewCell.accessoryType = self.cellAccessoryType;
    tableViewCell.accessoryView = self.cellAccessoryView;
    tableViewCell.selectionStyle = self.cellSelectionStyle;
    if(self.cellBackgroundColor) {
        tableViewCell.backgroundColor = self.cellBackgroundColor;
    }
}

-(void)tableViewCellWillBeginDisplay:(UITableViewCell*)tableViewCell
{

}

-(void)tableViewCellWillEndDisplay:(UITableViewCell*)tableViewCell
{

}

-(void)configureCellContentView:(UIView *)contentView
{
    
}

-(BOOL)isValidWithObject:(id)object displayedError:(NSError**)displayedError
{
    id value;
    if(self.keyPath) {
        value = [object valueForKeyPath:self.keyPath];
    }
    
    if(self.validationBlock) {
        return self.validationBlock(value, displayedError);
    } else if(self.validator) {
        return [self.validator cellDescriptor:self isValueValid:value displayedError:displayedError];
    }
    return YES;
}

-(NSString*)displayStringFromObject:(id)object
{
    NSString* displayString;
    id value;
    if(self.keyPath) {
        value = [object valueForKeyPath:self.keyPath];
    }
    if(value) {
        displayString = [self displayStringFromValue:value];
    }
    return displayString;

}

-(NSString*)displayStringFromValue:(id)value
{
    if([value conformsToProtocol:@protocol(Displayable)]) {
        value = [value displayString];
    }

    NSString* displayString;
    if(self.displayStringFormatterBlock) {
        displayString = self.displayStringFormatterBlock(value);
    } else {
        displayString = [NSString stringWithFormat:@"%@", value];
    }
    return displayString;
}

-(id<NSObject> _Nonnull)uniqueIdentifier
{
    return self;
}

-(BOOL)isCellDescriptorEqualToCellDescriptor:(NUOCellDescriptor* _Nonnull)cellDescriptor
{
    return self == cellDescriptor;
}

-(NSUInteger)hash
{
    return self.uuid.hash;
}

@end
