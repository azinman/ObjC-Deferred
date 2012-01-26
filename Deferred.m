//
//  Deferred.m
//  ObjC-Deferred
//
//  Created by Aaron Zinman on 1/12/12.
//  Copyright (c) 2012 Empirical Design LLC. All rights reserved.
//

#import "Deferred.h"

@implementation Deferred

@synthesize state = _state;
@synthesize failList = _failList;
@synthesize doneList = _doneList;
@synthesize alwaysList = _alwaysList;
@synthesize obj = _obj;

+ (Deferred *) deferred {
  return [[Deferred alloc] init];
}

- (id) init {
  if (self = [super init]) {
    self.state = PENDING;
  }
  return self;
}

- (Deferred *) done:(IdBlock)callback {
  @synchronized(self) {
    if (self.state == PENDING) {
      if (self.doneList == nil) {
        self.doneList = [NSMutableSet set];
      }
      [self.doneList addObject:[callback copy]];
    } else if (self.state == RESOLVED) {
      callback(self.obj);
    } else {
      // Do nothing; we have already been rejected
    }
  }
  return self;
}

- (Deferred *) fail:(IdBlock)callback {
  @synchronized(self) {
    if (self.state == PENDING) {
      if (self.failList == nil) {
        self.failList = [NSMutableSet set];
      }
      [self.failList addObject:[callback copy]];
    } else if (self.state == REJECTED) {
      callback(self.obj);
    } else {
      // Do nothing; we have already been resolved
    }
  }
  return self;
}

- (Deferred *) always:(IdBlock)callback {
  @synchronized(self) {
    if (self.state == PENDING) {
      if (self.alwaysList == nil) {
        self.alwaysList = [NSMutableSet set];
      }
      [self.alwaysList addObject:[callback copy]];
    } else {
      callback(self.obj);
    }
  }
  return self;
}

- (void) resolve:(id)obj {
  @synchronized(self) {
    if (self.state != PENDING) {
      [NSException raise:(self.state == RESOLVED ? @"Deferred already resolved" : @"Deferred already rejected")
                  format:@"Ignoring resolve with obj: %@", obj];
      return;
    }
    self.obj = obj;
    self.state = RESOLVED;
    if (self.doneList) {
      for (IdBlock callback in self.doneList) {
        callback(obj);
      }
    }
    if (self.alwaysList) {
      for (IdBlock callback in self.alwaysList) {
        callback(obj);
      }
    }
  }
}

- (void) reject:(id)obj {
  @synchronized(self) {
    if (self.state != PENDING) {
      [NSException raise:(self.state == RESOLVED ? @"Deferred already resolved" : @"Deferred already rejected")
                  format:@"Ignoring resolve with obj: %@", obj];
      return;
    }
    self.obj = obj;
    self.state = REJECTED;
    if (self.failList) {
      for (IdBlock callback in self.failList) {
        callback(obj);
      }
    }
    if (self.alwaysList) {
      for (IdBlock callback in self.alwaysList) {
        callback(obj);
      }
    }
  }
}


+ (Deferred *) testDeferred {
  return [[[[Deferred deferred] done:^(id obj) {
    NSLog(@"done with obj: %@", obj);
  }] fail:^(id obj) {
    NSLog(@"fail with obj: %@", obj);
  }] always:^(id obj) {
    NSLog(@"always with obj: %@", obj);
  }];
}

+ (void) stupidTest {
  NSLog(@"-------- Doing resolved test");
  Deferred *d = [Deferred testDeferred];
  [d resolve:@"RESOLVED OBJ"];
  [d done:^(id obj) {
    NSLog(@"another done callback: %@", obj);
  }];
  [d fail:^(id obj) {
    NSLog(@"this shouldn't be seen fail callback: %@", obj);
  }];
  [d always:^(id obj) {
    NSLog(@"Another always callback: %@", obj);
  }];

  NSLog(@"-------- Doing rejected test");
  d = [Deferred testDeferred];
  [d reject:@"RJECTED OBJ"];
  [d done:^(id obj) {
    NSLog(@"This shouldnt be seen: %@", obj);
  }];
  [d fail:^(id obj) {
    NSLog(@"another fail callback: %@", obj);
  }];
  [d always:^(id obj) {
    NSLog(@"Another always callback: %@", obj);
  }];

  NSLog(@"-------- Doing nil test");
  d = [Deferred testDeferred];
  [d resolve:nil];

  NSLog(@"-------- Doing explody test");
  d = [Deferred testDeferred];
  [d reject:@"RJECTED OBJ"];
  [d resolve:@"EXPLODY OBJ"];
}

@end
