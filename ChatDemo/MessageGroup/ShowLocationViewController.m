//
//  ShowLocationViewController.m
//  wenyao
//
//  Created by garfield on 15/3/3.
//  Copyright (c) 2015年 xiezhenghong. All rights reserved.
//

#import "ShowLocationViewController.h"
#import "CustomAnnotationView.h"
#import "AppDelegate.h"

@interface ShowLocationViewController ()<MAMapViewDelegate>

@end

@implementation ShowLocationViewController

- (void)initMapView
{
    [app.mapView removeAnnotations:app.mapView.annotations];
    app.mapView.frame = self.view.bounds;
    app.mapView.delegate = self;
    [self.view addSubview:app.mapView];
}

- (void)unloadMapView
{
    app.mapView.delegate = nil;
    app.mapView.mapType = MAMapTypeStandard;
    [app.mapView removeAnnotations:app.mapView.annotations];
    [app.mapView removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的位置";
    [self initMapView];
}

- (void)viewWillAppear:(BOOL)animated
{
    CLLocationDegrees latitude = self.coordinate.latitude;
    CLLocationDegrees longitude = self.coordinate.longitude;
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    [app.mapView setRegion:MACoordinateRegionMake(coordinate, MACoordinateSpanMake(0.005328, 0.008454)) animated:YES];
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = coordinate;
    pointAnnotation.title = self.address;
    [app.mapView addAnnotation:pointAnnotation];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self unloadMapView];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *customReuseIndetifier = @"customReuseIndetifier";
        
        CustomAnnotationView *annotationView = (CustomAnnotationView *)[app.mapView dequeueReusableAnnotationViewWithIdentifier:customReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[CustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customReuseIndetifier];
            annotationView.canShowCallout = NO;
            annotationView.draggable = YES;
        }
        annotationView.portrait = [UIImage imageNamed:@"currentpoint.png"];
        
        return annotationView;
    }
    return nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
