//
//  BKStationViewModel.m
//  Bikes
//
//  Created by Evan Coleman on 7/13/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "BKStationViewModel.h"

#import "BKUserPreferencesClient.h"
#import "BKStation.h"

@interface BKStationViewModel ()

@property (nonatomic) BKStation *station;

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *status;
@property (nonatomic) NSString *availableDocks;
@property (nonatomic) NSString *availableBikes;
@property (nonatomic) CGFloat fillPercentage;
@property (nonatomic) NSString *distance;
@property (nonatomic) NSString *lastUpdated;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation BKStationViewModel

- (instancetype)initWithStation:(BKStation *)station {
    self = [super init];
    if (self != nil) {
        _station = station;
        _name = station.name;
        _status = station.statusValue;
        _favorite = station.favorite;
        _availableDocks = [@(station.availableDocks) stringValue];
        _availableBikes = [@(station.availableBikes) stringValue];
        if (station.availableBikes > 0 || station.availableDocks > 0) {
            _fillPercentage = ([_availableBikes doubleValue] / ([_availableBikes doubleValue] + [_availableDocks doubleValue])) * 100;
        } else {
            _fillPercentage = 0.0;
        }
        _coordinate = CLLocationCoordinate2DMake(station.latitude, station.longitude);
        
        if (station.status == BKStationStatusOutOfService) {
            _statusColor = [UIColor bikes_darkGray];
        } else if (_fillPercentage <= 10) {
            _statusColor = [UIColor bikes_red];
        } else if (_fillPercentage > 10 && _fillPercentage <= 40) {
            _statusColor = [UIColor bikes_orange];
        } else {
            _statusColor = [UIColor bikes_green];
        }
        
        _distance = [NSString stringWithFormat:@"%0.2f miles", station.distance / 5280];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterMediumStyle;
        df.timeStyle = NSDateFormatterMediumStyle;
        _lastUpdated = [df stringFromDate:station.lastUpdated];
    }
    return self;
}

- (NSString *)title {
    return self.name;
}

- (NSString *)subtitle {
    if (self.station.status == BKStationStatusOutOfService) {
        return self.status;
    } else {
        return [NSString stringWithFormat:@"%@ Bikes, %@ Docks", self.availableBikes, self.availableDocks];
    }
}

- (void)setFavorite:(BOOL)favorite {
    _favorite = favorite;
    
    self.station.favorite = _favorite;
    NSArray *favorites = [[[BKUserPreferencesClient sharedUserPreferencesClient] objectForKey:@"BKFavoriteStations"] first];
    NSMutableSet *favoritesSet = [NSMutableSet setWithArray:favorites];
    if (_favorite) {
        [favoritesSet addObject:@(self.station.stationID)];
    } else {
        [favoritesSet removeObject:@(self.station.stationID)];
    }
    [[BKUserPreferencesClient sharedUserPreferencesClient] setObject:[favoritesSet allObjects] forKey:@"BKFavoriteStations"];
}

@end
