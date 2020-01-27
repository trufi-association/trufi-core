#import "TrufiCorePlugin.h"
#import <trufi_core/trufi_core-Swift.h>

@implementation TrufiCorePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTrufiCorePlugin registerWithRegistrar:registrar];
}
@end
