#import "FlutterScanditPlugin.h"
#import <flutter_scandit/flutter_scandit-Swift.h>

@implementation FlutterScanditPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterScanditPlugin registerWithRegistrar:registrar];
}
@end
