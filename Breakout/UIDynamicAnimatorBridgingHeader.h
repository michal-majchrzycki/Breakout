#ifndef UIDynamicAnimatorBridgingHeader_h
#define UIDynamicAnimatorBridgingHeader_h

@import UIKit;

@interface UIDynamicAnimator (AAPLDebugInterfaceOnly)

// Used in BreakoutViewController.swift file:
// lazilyCreatedDynamicAnimator.debugEnabled = true
@property (nonatomic, getter=isDebugEnabled) BOOL debugEnabled;
@end

#endif /* UIDynamicAnimatorBridgingHeader_h */



