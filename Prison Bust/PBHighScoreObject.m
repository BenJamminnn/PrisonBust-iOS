//
//  PBHighScoreObject.m
//  Prison Bust
//
//  Created by Mac Admin on 5/20/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import "PBHighScoreObject.h"

@implementation PBHighScoreObject

- (instancetype)scoreWithDate:(NSString *)date andScore:(int)score {
    PBHighScoreObject *obj = [PBHighScoreObject new];
    obj.score = score;
    obj.scoreDate = date;
    return obj;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [self scoreWithDate:self.scoreDate andScore:self.score];
    if(self ) {
        _score = [aDecoder decodeIntForKey:@"score"];
        _scoreDate = [aDecoder decodeObjectForKey:@"scoreDate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.score forKey:@"score"];
    [aCoder encodeObject:self.scoreDate forKey:@"scoreDate"];
}

- (NSString *)scoreDate {
    if(!_scoreDate) {
        _scoreDate = [self dateToString:[NSDate date]];
    }
    return _scoreDate;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@" %1.0f               %@" , _score , _scoreDate];
}

- (NSString *)dateToString:(NSDate *)date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeStyle = NSDateFormatterShortStyle;
    dateFormat.dateStyle = NSDateFormatterShortStyle;
    NSString *dateString = [dateFormat stringFromDate:date];
    return dateString;
}

+ (NSMutableArray *)compareHighScores:(NSArray *)unorderedArray {
    if(unorderedArray.count < 2) {
        return [NSMutableArray arrayWithArray:unorderedArray];
    }
    NSMutableArray *orderedArray = [NSMutableArray array];
    NSSortDescriptor *scoreSortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"score" ascending:NO];
    NSArray *sortDescriptor = [NSArray arrayWithObject:scoreSortDescriptor];
    orderedArray = [NSMutableArray arrayWithArray:[unorderedArray sortedArrayUsingDescriptors:sortDescriptor]];
    if(orderedArray.count > 5) {
        [orderedArray removeObjectAtIndex:orderedArray.count - 1];
    }
    return orderedArray;
}
@end