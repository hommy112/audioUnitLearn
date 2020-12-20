//
//  AU_EffectAudioUnit.h
//  AU_Effect
//
//  Created by hanyang on 2020/12/20.
//

#import <AudioToolbox/AudioToolbox.h>
#import "AU_EffectDSPKernelAdapter.h"

// Define parameter addresses.
extern const AudioUnitParameterID myParam1;

@interface AU_EffectAudioUnit : AUAudioUnit

@property (nonatomic, readonly) AU_EffectDSPKernelAdapter *kernelAdapter;
- (void)setupAudioBuses;
- (void)setupParameterTree;
- (void)setupParameterCallbacks;
@end
