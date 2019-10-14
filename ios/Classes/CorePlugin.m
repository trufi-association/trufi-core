#import "CorePlugin.h"
#import <core/core-Swift.h>

@implementation CorePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCorePlugin registerWithRegistrar:registrar];
}
@end
