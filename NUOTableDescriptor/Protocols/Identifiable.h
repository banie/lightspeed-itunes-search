//
//  Identifiable.h
//  Copyright (c) 2023 Lightspeed Commerce. All rights reserved.
//

@import Foundation;

@protocol Identifiable

//Returns a UUID no matter the set in which the object is a participant of
-(NSString* _Nonnull)identifier;
@end
