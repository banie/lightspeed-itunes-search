//
//  Displayable.h
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

@import Foundation;

@protocol Displayable

//Provides a generic return string that may be displayed in UI

-(NSString*)displayString __attribute__((annotate("returns_localized_nsstring")));

@end
