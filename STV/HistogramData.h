//
//  HistogramData.h
//  STV
//
//  Created by Anton Kostenich on 15.11.15.
//  Copyright © 2015 Anton Kostenich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HistogramData : NSObject

@property (nonatomic, strong) NSDictionary *redChannel;
@property (nonatomic, strong) NSDictionary *greenChannel;
@property (nonatomic, strong) NSDictionary *blueChannel;

@end
