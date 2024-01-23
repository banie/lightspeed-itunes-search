//
//  LabelCellDescriptor.h
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

#import "NUOCellDescriptor.h"

typedef NSString* _Nonnull (^TitleTextBlock)(id _Nullable);
typedef UIColor* _Nonnull (^TitleColorBlock)(id _Nullable);
typedef NSDictionary* _Nonnull (^TitleAttributesBlock)(id _Nullable);


@interface NUOLabelCellDescriptor : NUOCellDescriptor

/**
 *  The text of the title label
 */
@property (nonatomic, nullable, strong) NSString* titleText;

/**
 *  The attributed text of the title label
 */

@property (nonatomic, nullable, strong) NSAttributedString *attributedTitle;

/**
 *  The block providing the title label text if the titleText is not provided
 */
@property (nonatomic, nullable, strong) TitleTextBlock titleTextBlock;

@property (nonatomic, nullable, strong) UIColor* titleColor;

/**
 *  The block providing the title label text color
 */
@property (nonatomic, nullable, strong) TitleColorBlock titleColorBlock;

@property (nonatomic, nullable, strong) NSDictionary* titleAttributes;

/**
 *  The block providing the title text attributes
 */
@property (nonatomic, nullable, strong) TitleAttributesBlock titleAttributesBlock;

@property (nonatomic) UIEdgeInsets titleEdgeInsets;

/**
 *  The left margin of the title text
 */
@property (nonatomic) CGFloat leftMargin;

-(void)configureLabel:(UILabel* _Nonnull)label withTableDescriptorObject:(id _Nullable)object;

@end
