#import "Location.h"
#import "INTULocationManager.h"
#import "CLLocation+YCLocation.h"
#import "AppDelegate.h"
#import "Constant.h"

#define LOCATION_EXPIRE_IN 60

@interface Location()<AMapSearchDelegate>

@property (strong, atomic) INTULocationManager * locMgr;
@property (strong, atomic) CLLocation * lastLocation;
@property (strong, nonatomic) AMapReGeocodeSearchResponse *lastRegeocode;
@property (nonatomic, strong) AMapSearchAPI               *searchAPI;
@property (nonatomic, copy)   ReGeocodeBlock              reGeocodeBlock;


@property long lastLocationTime;
@end

@implementation Location

+ (instancetype)sharedInstance
{
    static Location *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [Location new];
        _sharedInstance.locMgr = [INTULocationManager sharedInstance];
        _sharedInstance.lastLocation = nil;
        _sharedInstance.searchAPI = [[AMapSearchAPI alloc] initWithSearchKey:AMAP_KEY Delegate:_sharedInstance];
        _sharedInstance.searchAPI.timeOut = 8;
    });
    
    return _sharedInstance;
}

- (INTULocationAccuracy)getAccuracyFromLocationType:(LocationType)type
{
    switch (type) {
 
 
//        case LocationCheckin:
//            return INTULocationAccuracyNeighborhood;
        case LocationCreate:
            return INTULocationAccuracyRoom;
    }
}

- (NSTimeInterval) getAccuracyFromLocationTimeout:(LocationType)type
{
    switch (type) {
 
//        case LocationCheckin:
//            return 2.5;
        case LocationCreate:
            return 7.0;
    }
}

+ (BOOL)locationServicesAvailable
{
    if ([CLLocationManager locationServicesEnabled] == NO) {
        return NO;
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return NO;
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return NO;
    } else if (app.currentNetWork == kNotReachable) {
        return NO;
    }
    return YES;
}

//add by Cat
- (void)requetWithReGoecodeOnly:(LocationType)type
                        timeout:(NSUInteger)timeout
                          block:(ReGeocodeBlock)block
{
    if(_lastLocation) {
        AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
        request.searchType = AMapSearchType_ReGeocode;
        request.requireExtension = YES;
        request.radius = 50;
        request.location = [AMapGeoPoint locationWithLatitude:_lastLocation.coordinate.latitude longitude:_lastLocation.coordinate.longitude];;
        request.requireExtension = YES;
        self.reGeocodeBlock = block;
        _searchAPI.timeOut = timeout;
        [_searchAPI AMapReGoecodeSearch:request];
    }else{
        [self requetWithReGoecode:type timeout:timeout block:block];
    }
}

//add by Cat
- (void)requetWithReGoecode:(LocationType)type
                    timeout:(NSUInteger)timeout
                      block:(ReGeocodeBlock)block
{
   
   
    INTULocationAccuracy accuracy = [self getAccuracyFromLocationType:type];
    [_locMgr requestLocationWithDesiredAccuracy:accuracy
                                           timeout:2.5
                              delayUntilAuthorized:YES
                                             block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                                 if(status != INTULocationStatusSuccess) {
                                                     if(_lastLocation && _lastRegeocode) {
                                                         block(_lastLocation,_lastRegeocode,LocationError);
                                                     }else{
                                                         block(nil,nil,LocationError);
                                                     }
                                                 }else{
                                                     //add by xie transform to Mars
                                                     currentLocation = [currentLocation locationMarsFromEarth];
                                                     if (status == INTULocationStatusSuccess || status == INTULocationStatusTimedOut) {
                                                         _lastLocationTime = (long)([[NSDate date] timeIntervalSince1970] * 1000.0f);
                                                         _lastLocation = currentLocation;
                                                         
                                            
                                                         AMapReGeocodeSearchRequest *request = [[AMapReGeocodeSearchRequest alloc] init];
                                                         request.searchType = AMapSearchType_ReGeocode;
                                                         request.requireExtension = YES;
                                                         request.radius = 50;
                                                         request.location = [AMapGeoPoint locationWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];;
                                                         request.requireExtension = YES;
                                                         self.reGeocodeBlock = block;
                                                         [_searchAPI AMapReGoecodeSearch:request];

                                                     }
                                                 }
                                             }];
}

#pragma mark -
#pragma mark AMapSearchDelegate
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(self.reGeocodeBlock)
        self.reGeocodeBlock(self.lastLocation,response,LocationRegeocodeSuccess);
}

- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
    if(self.reGeocodeBlock)
        self.reGeocodeBlock(self.lastLocation,nil,LocationRegeocodeFailed);
}

- (NSInteger)request:(LocationType)type
          block:(void (^)(CLLocation *currentLocation, LocationStatus status))block
{
    INTULocationAccuracy accuracy = [self getAccuracyFromLocationType:type];
    NSTimeInterval timeout = [self getAccuracyFromLocationTimeout:type];
    
    return [_locMgr requestLocationWithDesiredAccuracy:accuracy
                                        timeout:timeout
                           delayUntilAuthorized:YES
                                          block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                              if(status != INTULocationStatusSuccess) {
                                        
                                                  block(_lastLocation, (LocationStatus)status);
                                              }else{
                                                  //add by Cat transform to Mars
                                                  currentLocation = [currentLocation locationMarsFromEarth];
                                                  if (status == INTULocationStatusSuccess || status == INTULocationStatusTimedOut) {
                                                      _lastLocationTime = (long)([[NSDate date] timeIntervalSince1970] * 1000.0f);
                                                      _lastLocation = currentLocation;
                                                  }
                                                  block(currentLocation, (LocationStatus)status);
                                              }
                                          }];
}

- (void)cancel:(NSInteger)requestID
{
    [_locMgr cancelLocationRequest:requestID];
}

- (CLLocation *)lastWellLocation
{
    long now = (long)([[NSDate date] timeIntervalSince1970] * 1000.0f);
    if (now - _lastLocationTime > LOCATION_EXPIRE_IN * 1000) {
        return nil;
    }
    
    return _lastLocation;
}

@end