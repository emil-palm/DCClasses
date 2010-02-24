//
//  DCMicroTime.m
//  
//
//  Created by Emil Palm on 24/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DCMicroTime.h"


@implementation DCMicroTime

- (id) init {
  if(self = [super init]) {
    currentIndex = 0;
    currentFreeIndex = -1;
  }
  return self;
}

/** Private **/
- (BOOL) startWithTag:(int) tag {
  if(currentIndex == allocationCount && currentFreeIndex == -1) {
    if (allocationCount == 0)
      allocationCount = 3;
    else
      allocationCount *= 2; 

    void *_tmpTags = realloc(tags, (allocationCount * sizeof(int)));
    void *_tmpStarted = realloc(started, (allocationCount * sizeof(clock_t)));
    void *_tmpEnded = realloc(ended, (allocationCount * sizeof(clock_t)));
    void *_tmpFreeIndexes = realloc(freeIndexes, (allocationCount * sizeof(int)));
    
    // If the reallocation didn't go so well,
    // inform the user and bail out
    if (!_tmpTags || !_tmpStarted || !_tmpEnded || !_tmpFreeIndexes)
    {
      NSLog(@"ERROR: Couldn't realloc memory!");
      return FALSE;
    }
    
    // Things are looking good so far
    tags = (int*)_tmpTags;
    started = (clock_t*)_tmpStarted;
    ended = (clock_t*)_tmpEnded;
    freeIndexes = (int*)_tmpFreeIndexes;
  }
  
  int newIndex = currentIndex;
  if(currentFreeIndex > -1) {
    newIndex = freeIndexes[currentFreeIndex];
    currentFreeIndex--;
  } else {
    currentIndex++;
  }

  tags[newIndex] = tag;
  started[newIndex] = clock();

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
  [self startWithTag:tag];
}

- (void) stopMicroTimeWithTag:(int)tag {
  [self endWithIndex:[self indexForTag:tag]];
}

- (void) removeTag: (int) tag {
  int index = [self indexForTag:tag];
  started[index] = 0;
  ended[index] = 0;
  tags[index] = -1;
  
  currentFreeIndex++;
  freeIndexes[currentFreeIndex] = index;  
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
