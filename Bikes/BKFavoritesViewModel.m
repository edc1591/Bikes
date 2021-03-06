//
//  BKFavoritesViewModel.m
//  Bikes
//
//  Created by Evan Coleman on 7/16/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "BKFavoritesViewModel.h"

#import "BKStationsViewModel.h"
#import "BKStationViewModel.h"
#import "BKErrorViewModel.h"

#import "BKStation.h"

@interface BKFavoritesViewModel ()

@property (nonatomic, readonly) BKStationsViewModel *stationsViewModel;

@end

@implementation BKFavoritesViewModel

- (instancetype)initWithStationsViewModel:(BKStationsViewModel *)stationsViewModel {
    self = [super init];
    if (self != nil) {
        _stationsViewModel = stationsViewModel;
        
        @weakify(self);
        _refreshCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id _) {
            @strongify(self);
            return [self.stationsViewModel.refreshStationsCommand execute:nil];
        }];
        
        _favoriteStationCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(RACTuple *t) {
            @strongify(self);
            return [self.stationsViewModel.favoriteStationCommand execute:t];
        }];
                
        [[[self didBecomeActiveSignal]
            flattenMap:^RACSignal *(id _) {
                @strongify(self);
                return [self.stationsViewModel.loadStationsCommand execute:nil];
            }]
            subscribeNext:^(id _) {
                
            }];
        
        RAC(self, nearbyStationViewModels) =
            [[[RACObserve(self.stationsViewModel, viewModels)
                filter:^BOOL(NSArray *viewModels) {
                    return ![[viewModels firstObject] isKindOfClass:[BKErrorViewModel class]];
                }]
                map:^NSArray *(NSArray *viewModels) {
                    return [[viewModels.rac_sequence
                                filter:^BOOL(BKStationViewModel *viewModel) {
                                    return viewModel.station.distance < 800 && !viewModel.favorite;
                                }]
                                array];
                }]
                deliverOn:[RACScheduler mainThreadScheduler]];
        
        RAC(self, favoriteStationViewModels) =
            [[[RACObserve(self.stationsViewModel, viewModels)
                filter:^BOOL(NSArray *viewModels) {
                    return ![[viewModels firstObject] isKindOfClass:[BKErrorViewModel class]];
                }]
                map:^NSArray *(NSArray *viewModels) {
                    return [[viewModels.rac_sequence
                                filter:^BOOL(BKStationViewModel *viewModel) {
                                    return viewModel.station.favorite;
                                }]
                                array];
                }]
                deliverOn:[RACScheduler mainThreadScheduler]];
        
        [[[_stationsViewModel.loadStationsCommand errors]
            map:^BKErrorViewModel *(NSError *error) {
                @strongify(self);
                return [[BKErrorViewModel alloc] initWithError:error retryCommand:self.stationsViewModel.loadStationsCommand];
            }]
            subscribe:self.errorViewModels];
    }
    return self;
}

@end
