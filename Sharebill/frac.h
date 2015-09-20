//
//  frac.h
//  Sharebill
//
//  Created by Jon Packer on 20.09.15.
//  Copyright (c) 2015 BRIK. All rights reserved.
//

#ifndef Sharebill_frac_h
#define Sharebill_frac_h

#import <Foundation/Foundation.h>

@interface RCRationalNumber : NSObject
{
@private
  int numerator;
  int denominator;
  BOOL autoSimplify;
  BOOL withSign;
}
+(instancetype)valueWithNumerator:(int)num andDenominator: (int)den;
+(instancetype)valueWithDouble: (double)fnum;
+(instancetype)valueWithInteger: (int)inum;
+(instancetype)valueWithRational: (RCRationalNumber *)rnum;
-(instancetype)initWithNumerator: (int)num andDenominator: (int)den;
-(instancetype)initWithDouble: (double)fnum precision: (int)prec;
-(instancetype)initWithInteger: (int)inum;
-(instancetype)initWithRational: (RCRationalNumber *)rnum;
-(NSComparisonResult)compare: (RCRationalNumber *)rnum;
-(id)simplify: (BOOL)act;
-(void)setAutoSimplify: (BOOL)v;
-(void)setWithSign: (BOOL)v;
-(BOOL)autoSimplify;
-(BOOL)withSign;
-(NSString *)description;
// ops
-(id)multiply: (RCRationalNumber *)rnum;
-(id)divide: (RCRationalNumber *)rnum;
-(id)add: (RCRationalNumber *)rnum;
-(id)sub: (RCRationalNumber *)rnum;
-(id)abs;
-(id)neg;
-(id)mod: (RCRationalNumber *)rnum;
-(int)sign;
-(BOOL)isNegative;
-(id)reciprocal;
// getter
-(int)numerator;
-(int)denominator;
//setter
-(void)setNumerator: (int)num;
-(void)setDenominator: (int)num;
// defraction
-(double)number;
-(int)integer;
@end

#endif
