//
//  PBInAppPurchaseHelper.h
//  Prison Bust
//
//  Created by Mac Admin on 4/30/14.
//  Copyright (c) 2014 Ben Gabay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray *products);

@interface PBInAppPurchaseHelper : NSObject

- (instancetype)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void) requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
@end
