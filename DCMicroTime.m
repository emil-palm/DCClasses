//
//  DCMicroTime.m
//  
//
//  Created by Emil Palm on 24/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DCMicroTime.h"


@implementation DCMicroTime

/** Private **/
- (BOOL) startWithTag:(int) tag {
  if(currentIndex == allocationCount) {
    if (allocationCount == 0)
      allocationCount = 3;
    else
      allocationCount *= 2; 

    void *_tmpTags = realloc(tags, (allocationCount * sizeof(int)));
    void *_tmpStarted = realloc(started, (allocationCount * sizeof(clock_t)));
    void *_tmpEnded = realloc(ended, (allocationCount * sizeof(clock_t)));
    
    // If the reallocation didn't go so well,
    // inform the user and bail out
    if (!_tmpTags || !_tmpStarted || !_tmpEnded)
    {
      NSLog(@"ERROR: Couldn't realloc memory!");
      return FALSE;
    }
    
    // Things are looking good so far
    tags = (int*)_tmpTags;
    started = (clock_t*)_tmpStarted;
    ended = (clock_t*)_tmpEnded;
  }
  
  tags[currentIndex] = tag;
  started[currentIndex] = clock();
  currentIndex++;
  return TRUE;
}

- (void) endWithIndex: (int) index {
  ended[index] = clock();
}

- (int) indexForTag:(int) tag {
  for (int i=0; i < currentIndex; i++) {
    if(tags[i] == tag) return i;
  }
  return -1;
}

/** Singleton **/

+ (DCMicroTime *) microtime {
  static DCMicroTime * microtime = nil;
  if (!microtime) {
    microtime = [[DCMicroTime alloc] init];
  }
  return microtime;
}

- (void) startMicroTimeWithTag:(int)tag {
  [self startMicroTimeWithTag:tag];
}

- (void) stopMicroTimeWithTag:(int)tag {
  [self endWithIndex:[self indexForTag:tag]];
}

- (NSString *) elapsedWithTag:(int)tag {
  int index = [self indexForTag:tag];
  return [NSString stringWithFormat:@"Took %f ms",  ((double) (ended[index] - started[index]))];
}

- (void) dealloc {
  free(tags);
  free(started);
  [super dealloc];
}

@end
