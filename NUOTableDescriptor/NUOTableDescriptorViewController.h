//
//  TableDescriptorViewController.h
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NUOTableDescriptor.h"
#import "NUOTableDescriptorViewControllerDelegate.h"


@interface NUOTableDescriptorViewController : UIViewController <NUOTableDescriptorViewControllerDelegate>
@property (nonatomic, strong, nonnull) NUOTableDescriptor* tableDescriptor;
@property (nonnull, strong) UITableView* tableView;
-(instancetype _Nonnull)initWithStyle:(UITableViewStyle)style tableDescriptor:(NUOTableDescriptor* _Nonnull)tableDescriptor;
@end
