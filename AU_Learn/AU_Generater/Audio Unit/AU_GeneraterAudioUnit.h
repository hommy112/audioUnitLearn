//
//  AU_GeneraterAudioUnit.h
//  AU_Generater
//
//  Created by hanyang on 2020/12/20.
//

#import <AudioToolbox/AudioToolbox.h>
#import "AU_GeneraterDSPKernelAdapter.h"

// Define parameter addresses.
extern const AudioUnitParameterID myParam1;

@interface AU_GeneraterAudioUnit : AUAudioUnit

@property (nonatomic, readonly) AU_GeneraterDSPKernelAdapter *kernelAdapter;
- (void)setupAudioBuses;
- (void)setupParameterTree;
- (void)setupParameterCallbacks;
@end
