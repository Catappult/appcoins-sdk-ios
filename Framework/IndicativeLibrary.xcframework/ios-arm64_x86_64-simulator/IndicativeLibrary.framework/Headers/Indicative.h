//
//  Indicative.h
//  Indicative
//
//  Created by Indicative on 08-01-13.
//  Copyright (c) 2013 Indicative. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IndicativeLibrary/IndicativeEvent.h>

@interface Indicative : NSObject

+(Indicative*)launch:(NSString*)apiKey;
+(Indicative*)identifyUser:(NSString*)uniqueKey;
+(Indicative*)identifyUserWithAlias:(NSString*)uniqueKey;
+(void)clearUniqueKey;
+(void)reset;
+(void)flushEvents;

+(NSString*)uniqueKey;
+(NSString*)anonymousId;

+(Indicative*)addCommonProperties:(NSDictionary*)properties;
+(Indicative*)addCommonProperty:(id)propertyValue forName:(NSString*)propertyName;
+(Indicative*)removeCommonPropertyWithName:(NSString*)propertyName;
+(Indicative*)clearCommonProperties;

+(void)record:(NSString*)eventName;
+(void)record:(NSString*)eventName withProperties:(NSDictionary*)properties;
+(void)record:(NSString*)eventName withUniqueKey:(NSString*)uniqueKey;
+(void)record:(NSString*)eventName withProperties:(NSDictionary*)properties withUniqueKey:(NSString*)uniqueKey;
+(void)recordEvent:(IndicativeEvent*)event;

@end
