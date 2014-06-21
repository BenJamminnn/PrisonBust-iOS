//
//  PBGuards.m
//  Prison Bust
//
//  Created by Mac Admin on 4/24/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBGuards.h"

@implementation PBGuards
- (id)init {
    if(self = [super init]) {
        self.enemyType = enemyTypeGuard;
    }
    return self;
}

- (void)executeDeathAnimation {
    
}
@end
