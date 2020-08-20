#import "FlutterScanditPlugin.h"
#import <flutter_scandit_plugin/flutter_scandit_plugin-Swift.h>

@implementation FlutterScanditPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterScanditPlugin registerWithRegistrar:registrar];
}
@end
