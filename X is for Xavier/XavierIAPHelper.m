//
//  XavierIAPHelper.m
//  X is for Xavier
//
//
//

#import "XavierIAPHelper.h"

@implementation XavierIAPHelper

static XavierIAPHelper * _sharedHelper;

+ (XavierIAPHelper *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[XavierIAPHelper alloc] init];
    return _sharedHelper;
    
}

- (id)init {
    
    NSSet *productIdentifiers = [NSSet setWithObjects:
        kXavierProductIdentifier,
        nil];
    
    if ((self = [super initWithProductIdentifiers:productIdentifiers])) {                
        
    }
    return self;
    
}

@end
