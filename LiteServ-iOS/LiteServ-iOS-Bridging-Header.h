//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <CouchbaseLite/CouchbaseLite.h>
#import <CouchbaseLiteListener/CouchbaseLiteListener.h>
#import "CBLRegisterJSViewCompiler.h"
#import "GCDWebServer.h"
#import "GCDWebServerDataRequest.h"
#import "GCDWebServerDataResponse.h"

@interface CBLManager ()
@property NSUInteger defaultMaxRevTreeDepth;
@end
