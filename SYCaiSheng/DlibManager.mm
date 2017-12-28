//
//  DlibManager.m
//  SYCaiSheng
//
//  Created by sunny on 2017/12/18.
//  Copyright © 2017年 hl. All rights reserved.
//

#import "DlibManager.h"

#include <dlib/image_io.h>
#include <dlib/image_processing.h>

//using namespace std;
//using namespace dlib;

@interface DlibManager ()

@end


@implementation DlibManager
{
//    shape_predictor sp;
}

+ (instancetype)manager {
    
    DlibManager *manager = [[DlibManager alloc] init];
    
    return manager;
}

- (instancetype) init {
    self = [super init];
    if (self) {
   
    }
    return self;
}


@end
