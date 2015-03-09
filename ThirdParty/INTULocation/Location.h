#import <CoreLocation/CLLocation.h>
#import <AMapSearchKit/AMapCommonObj.h>
#import <AMapSearchKit/AMapSearchObj.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface Location : NSObject


typedef NS_ENUM(NSInteger, LocationType) {

    LocationCreate      // 创建地点地位
};

typedef NS_ENUM(NSInteger, LocationStatus) {
    /* These statuses will accompany a valid location. */
    LocationSuccess,                // got a location and desired accuracy level was achieved successfully
    LocationTimeout,                // got a location, but desired accuracy level was not reached before timeout
    
    /* These statuses indicate some sort of error, and will accompany a nil location. */
    LocationServicesNotDetermined,  // user has not responded to the permissions dialog
    LocationServicesDenied,         // user has explicitly denied this app permission to access location services
    LocationServicesRestricted,     // user does not have ability to enable location services (e.g. parental controls, corporate policy, etc)
    LocationServicesDisabled,       // user has turned off device-wide location services from system settings
    LocationError,                   // an error occurred while using the system location services
    LocationRegeocodeSuccess,       //经纬度以及逆地理编码解析都成功
    LocationRegeocodeFailed,        //经纬度解析成功,但逆地理编码解析失败
};

typedef void (^ReGeocodeBlock)(CLLocation *currentLocation,AMapReGeocodeSearchResponse *response, LocationStatus status);
+ (BOOL)locationServicesAvailable;
+ (instancetype)sharedInstance;

- (void)requetWithReGoecodeOnly:(LocationType)type
                        timeout:(NSUInteger)timeout
                          block:(ReGeocodeBlock)block;
- (void)requetWithReGoecode:(LocationType)type
                    timeout:(NSUInteger)timeout
                      block:(void (^)(CLLocation *currentLocation,AMapReGeocodeSearchResponse *response, LocationStatus status))block;

- (NSInteger)request:(LocationType)type
          block:(void (^)(CLLocation *currentLocation, LocationStatus status))block;

- (void)cancel:(NSInteger)requestID;

- (CLLocation *)lastWellLocation;

@end
