//
//  etj_macros.h
//
//  Created by Evan Jones on 10/3/14.
//

#ifndef etj_macros_h
#define etj_macros_h

#pragma mark M A C R O S
// general mapping from one range to another
#define SCALE( x, domainMin, domainMax, rangeMin, rangeMax) ((rangeMin) + ((float)(x)-(domainMin)) / ((domainMax)-(domainMin)) * ((rangeMax)-(rangeMin)))

// These NSNumber/NSValue macros let us use non-objects as keys or values in a NSDictionary
#define NSV(val) [NSValue valueWithNonretainedObject:(val)]
#define VSN(val) [(val) nonretainedObjectValue]

#define NSNI(val) [NSNumber numberWithInt:(val)]
#define INSN(val) [(val) intValue]

#define NSNF(val) [NSNumber numberWithFloat:(val)]
#define FNSN(val) [(val) floatValue]

#define CLIP_TO_RANGE( x, min, max) ((x) < (min) ? (min) : (x) > (max) ? (max) : (x))

#define TAU (2*M_PI)

#define DEGREES_TO_RADIANS(degrees) ((degrees) / 360.0 * TAU)
#define RADIANS_TO_DEGREES(radians) ((radians) * (360.0 / TAU))


#endif
