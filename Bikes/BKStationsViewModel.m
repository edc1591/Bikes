//
//  BKStationsViewModel.m
//  Bikes
//
//  Created by Evan Coleman on 9/21/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "BKStationsViewModel.h"

#import "BKStationsController.h"

#import "BKStationViewModel.h"

@interface BKStationsViewModel ()

@end

@implementation BKStationsViewModel

- (instancetype)initWithStationsController:(BKStationsController *)stationsController {
    self = [super init];
    if (self != nil) {
        @weakify(self);
        _loadStationsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSNumber *dataFetchPolicy) {
            DataFetchPolicy policy = DataFetchPolicyCacheFirst;
            if (dataFetchPolicy != nil) {
                policy = [dataFetchPolicy unsignedIntegerValue];
            }
            
            return [[[stationsController readStations:policy]
                        map:^NSArray *(NSArray *stations) {
                            return [[stations.rac_sequence
                                        map:^BKStationViewModel *(BKStation *station) {
                                            return [[BKStationViewModel alloc] initWithStation:station];
                                        }]
                                        array];
                        }]
                        map:^NSArray *(NSArray *viewModels) {
                            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:YES];
                            return [viewModels sortedArrayUsingDescriptors:@[sortDescriptor]];
                        }];
        }];
        
        _refreshStationsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id _) {
            @strongify(self);
            return [self.loadStationsCommand execute:@(DataFetchPolicySourceOnly)];
        }];
        
        RAC(self, viewModels) =
            [[_loadStationsCommand executionSignals]
                 switchToLatest];
    }
    return self;
}

@end