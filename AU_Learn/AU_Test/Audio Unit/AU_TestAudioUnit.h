//
//  AU_TestAudioUnit.h
//  AU_Test
//
//  Created by hanyang on 2020/12/20.
//

#import <AudioToolbox/AudioToolbox.h>
#import "AU_TestDSPKernelAdapter.h"

// Define parameter addresses.
extern const AudioUnitParameterID myParam1;

@interface AU_TestAudioUnit : AUAudioUnit

@property (nonatomic, readonly) AU_TestDSPKernelAdapter *kernelAdapter;
- (void)setupAudioBuses;
- (void)setupParameterTree;
- (void)setupParameterCallbacks;
@end
