//
//  DCMicroTime.h
//  
//
//  Created by Emil Palm on 24/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DCMicroTime : NSObject {
  @private
  clock_t *started;
  clock_t *ended;
  int *tags;
  int currentIndex;
  int allocationCount;
}
+ (DCMicroTime *) microtime;
- (void) startMicroTimeWithTag: (int) tag;
- (void) stopMicroTimeWithTag: (int) tag;
- (NSString *) elapsedWithTag: (int) tag;

@end
