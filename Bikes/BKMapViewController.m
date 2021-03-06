//
//  BKMapViewController.m
//  Bikes
//
//  Created by Evan Coleman on 7/14/14.
//  Copyright (c) 2014 Evan Coleman. All rights reserved.
//

#import "BKMapViewController.h"
#import "BKStationViewModel.h"
#import "BKAnnotationView.h"
#import "BKClusterAnnotationView.h"
#import "BKMapViewModel.h"
#import "BKStationsViewModel.h"

#import <MapKit/MapKit.h>
#import <FBAnnotationClustering/FBAnnotationClustering.h>
#import <PureLayout/PureLayout.h>

@interface BKMapViewController () <MKMapViewDelegate>

@property (nonatomic) MKMapView *mapView;
@property (nonatomic) FBClusteringManager *clusteringManager;

@property (nonatomic, readonly) BKMapViewModel *viewModel;

@property (nonatomic) BOOL didUpdateToLocation;

@end

@implementation BKMapViewController

- (id)initWithViewModel:(BKMapViewModel *)viewModel {
    self = [super initWithViewModel:viewModel];
    if (self != nil) {
        self.tabBarItem.image = [UIImage imageNamed:@"map"];
        [self.tabBarItem setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
        
        _clusteringManager = [[FBClusteringManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
	
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    
    @weakify(self);
    [[[RACObserve(self.viewModel.stationsViewModel, viewModels)
        ignore:nil]
        deliverOn:[RACScheduler mainThreadScheduler]]
        subscribeNext:^(NSArray *viewModels) {
            @strongify(self);
            [self.mapView addAnnotations:viewModels];
            [self.clusteringManager addAnnotations:viewModels];
            
            [self mapView:self.mapView regionDidChangeAnimated:NO];
        }];
}

- (void)viewWillLayoutSubviews {
    [self.mapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {    
    if ([annotation isKindOfClass:[BKStationViewModel class]]) {
        BKAnnotationView *annotationView = (BKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([BKAnnotationView class])];
        if (annotationView == nil) {
            annotationView = [[BKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([BKAnnotationView class])];
            annotationView.frame = CGRectMake(0, 0, 25, 50);
            
            annotationView.canShowCallout = YES;
        }
        
        annotationView.annotation = annotation;
        
        return annotationView;
    } else if ([annotation isKindOfClass:[FBAnnotationCluster class]]) {
        BKClusterAnnotationView *annotationView = (BKClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:NSStringFromClass([BKClusterAnnotationView class])];
        if (annotationView == nil) {
            annotationView = [[BKClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:NSStringFromClass([BKClusterAnnotationView class])];
            annotationView.frame = CGRectMake(0, 0, 36, 36);
        }
        
        annotationView.annotation = annotation;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [[NSOperationQueue new] addOperationWithBlock:^{
        double scale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
        NSArray *annotations = nil;
        if (scale < 0.025) {
            annotations = [self.clusteringManager clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:scale];
        } else {
            annotations = [self.clusteringManager allAnnotations];
        }
        
        [self.clusteringManager displayAnnotations:annotations onMapView:mapView];
    }];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!self.didUpdateToLocation) {
        mapView.region = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.01, 0.01));
        self.didUpdateToLocation = YES;
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    BKAnnotationView *aView = (BKAnnotationView *)view;
    [[aView.viewModel.favoriteStationCommand execute:@(!control.selected)]
        subscribeCompleted:^{
            control.selected = !control.selected;
        }];
}

@end
