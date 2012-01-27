/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "ccMacros.h"
#import "CCAnimation.h"
#import "CCSpriteFrame.h"
#import "CCTexture2D.h"
#import "CCTextureCache.h"

#pragma mark - CCAnimationFrame
@implementation CCAnimationFrame

@synthesize spriteFrame = spriteFrame_, delayUnits = delayUnits_, offset = offset_;

-(id) initWithSpriteFrame:(CCSpriteFrame *)spriteFrame delayUnits:(float)delayUnits offset:(CGPoint)offset
{
	if( (self=[super init]) ) {
		self.spriteFrame = spriteFrame;
		self.delayUnits = delayUnits;
		self.offset = offset;
	}
	
	return self;
}

-(void) dealloc
{    
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	[spriteFrame_ release];
    [super dealloc];
}

-(id) copyWithZone: (NSZone*) zone
{
	CCAnimationFrame *copy = [[[self class] allocWithZone: zone] initWithSpriteFrame:[[spriteFrame_ copy] autorelease] delayUnits:delayUnits_ offset:offset_];
	return copy;
}

-(NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | SpriteFrame = %@, delayUnits = %d>", [self class], self, self.spriteFrame, delayUnits_];
}
@end


#pragma mark - CCAnimation

@implementation CCAnimation
@synthesize frames = frames_, duration=duration_, totalDelayUnits=totalDelayUnits_, delayPerUnit=delayPerUnit_, restoreOriginalFrame=restoreOriginalFrame_;

+(id) animation
{
	return [[[self alloc] init] autorelease];
}

+(id) animationWithFrames:(NSArray*)frames
{
	return [[[self alloc] initWithFrames:frames] autorelease];
}

+(id) animationWithFrames:(NSArray*)frames delay:(float)delay
{
	return [[[self alloc] initWithFrames:frames delay:delay] autorelease];
}

+(id) animationWithFrames:(NSArray*)arrayOfAnimationFrames delayPerUnit:(float)delayPerUnit
{
	return [[[self alloc] initWithFrames:arrayOfAnimationFrames delayPerUnit:delayPerUnit] autorelease];
}

-(id) init
{
	return [self initWithFrames:nil delay:0];
}

-(id) initWithFrames:(NSArray*)frames
{
	return [self initWithFrames:frames delay:0];
}

-(id) initWithFrames:(NSArray*)array delay:(float)delay
{
	if( (self=[super init]) ) {

		self.frames = [NSMutableArray arrayWithCapacity:[array count]];
		duration_ = [array count] * delay;
		
		for( CCSpriteFrame *frame in array ) {
			CCAnimationFrame *animFrame = [[CCAnimationFrame alloc] initWithSpriteFrame:frame delayUnits:1 offset:CGPointZero];
			
			[self.frames addObject:animFrame];
			[animFrame release];
			totalDelayUnits_++;
		}
		
		delayPerUnit_ = delay;
	}
	return self;
}

-(id) initWithFrames:(NSArray*)arrayOfAnimationFrames delayPerUnit:(float)delayPerUnit
{
	if( ( self=[super init]) ) {
		delayPerUnit_ = delayPerUnit;
		self.frames = [NSMutableArray arrayWithArray:arrayOfAnimationFrames];
		duration_ = 0;
		for( CCAnimationFrame *animFrame in frames_ ) {
			duration_ += animFrame.delayUnits * delayPerUnit;
			totalDelayUnits_ += animFrame.delayUnits;
		}		
	}
	return self;
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X | frames=%d, totalDelayUnits=%d, delayPerUnit=%f>", [self class], self,
			[frames_ count],
			totalDelayUnits_,
			delayPerUnit_
			];
}

-(void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@",self);

	[frames_ release];
	[super dealloc];
}

-(void) addFrame:(CCSpriteFrame*)frame
{
	CCAnimationFrame *animFrame = [[CCAnimationFrame alloc] initWithSpriteFrame:frame delayUnits:1 offset:CGPointZero];
	[frames_ addObject:animFrame];
	[animFrame release];
	
	// update duration
	duration_ += delayPerUnit_;
	totalDelayUnits_++;
}

-(void) addFrameWithFilename:(NSString*)filename
{
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:filename];
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	CCSpriteFrame *spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:rect];

	[self addFrame:spriteFrame];
}

-(void) addFrameWithTexture:(CCTexture2D*)texture rect:(CGRect)rect
{
	CCSpriteFrame *frame = [CCSpriteFrame frameWithTexture:texture rect:rect];
	[self addFrame:frame];
}

@end
