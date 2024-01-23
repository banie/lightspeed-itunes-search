//
//  NUOTableDescriptor_Private.h
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

#import "NUOTableDescriptor.h"

@interface NUOTableDescriptor ()

/**
 *  Alert the Table Descriptor that the table view will be redrawn.
 *  This invokes the table descriptor to snapshot the current
 *  description as data source for current table view redraw. 
 */
-(void)cacheCellDescriptorsForRedraw;

-(void)setCellDescriptorsForRedraw:(NSDictionary<NSNumber*, NSArray<NUOCellDescriptor*>*>* _Nonnull)cellDescriptorsForRedraw;

-(NUOCellDescriptor* _Nullable)stagedCellDescriptorAtIndexPath:(NSIndexPath* _Nonnull)indexPath;

/**
 *  Retrieve the number of sections
 *
 *  @return The number of sections
 */
-(NSUInteger)numberOfSections;

-(NSDictionary<NSNumber*, NSArray<NUOCellDescriptor*>*>* _Nonnull)drawnCellDescriptors;

-(NSDictionary<NSNumber*, NSArray<NUOCellDescriptor*>*>* _Nonnull)pendingCellDescriptors;

/**
 *  Provides the underlying drawn cell descriptors for specified section
 *
 *  Note: Because of how NUOTableDescriptor handles cell descriptors and
 *  table redraw events, there is a private copy of cell descriptors
 *  that back the drawn table. This private copy prevents cell descriptor 
 *  mutation during table redraw operation
 *
 *  @param section The section for which to retrieve the drawn cell descriptors
 *
 *  @return A list of cell descriptors that privately back the table redraw. 
 */
-(NSArray* _Nullable)drawnCellDescriptorsForSection:(NSUInteger)section;

/**
 *  Retrieve the number of rows in a specific section
 *
 *  @param section The specific section
 *
 *  @return The number of rows in a specific section, or 0 if no section exists
 */
-(NSUInteger)numberOfRowsForSection:(NSUInteger)section;

-(void)removeAllCellDescriptorsForSection:(NSUInteger)section;

@end
