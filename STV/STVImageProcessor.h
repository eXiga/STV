//
//  STVImageProcessor.h
//  STV
//
//  Created by Anton Kostenich on 10/27/15.
//  Copyright © 2015 Anton Kostenich. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SaturatedBorders;

@interface STVImageProcessor : NSObject

- (instancetype)initWithImage:(UIImage *)image;
- (UIImage *)saturateWithBorders:(SaturatedBorders *)borders;

@end
