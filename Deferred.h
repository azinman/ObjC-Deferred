//
//  Deferred.h
//  ObjC-Deferred
//
//  Created by Aaron Zinman on 1/12/12.
//  Copyright (c) 2012 Empirical Design LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  PENDING, RESOLVED, REJECTED
} DeferredState;

/**
 * A loose translation of Deferred objects from Objective-C.
 *
 * Written for ARC.
 * Not really optimized for multi-threading, or GCD.
 *
 * Look at Deferred's -stupidTest for an example of how to use it, or read jQuery's documentation.
 */
@interface Deferred : NSObject

+ (Deferred *) deferred;
- (Deferred *) done:(IdBlock)callback;
- (Deferred *) fail:(IdBlock)callback;
- (Deferred *) always:(IdBlock)callback;
- (void) resolve:(id)obj;
- (void) reject:(id)obj;
+ (void) stupidTest;

@property(nonatomic, assign) DeferredState state;
@property(nonatomic, strong) NSMutableSet *doneList;
@property(nonatomic, strong) NSMutableSet *failList;
@property(nonatomic, strong) NSMutableSet *alwaysList;
@property(nonatomic, strong) id obj;

@end
