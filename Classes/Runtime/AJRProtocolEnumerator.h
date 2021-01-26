//
//  AJRProtocolEnumerator.h
//  AJRFoundation
//
//  Created by A.J. Raftis on 6/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AJRProtocolEnumerator : NSEnumerator<Protocol *>

+ (instancetype)protocolEnumeratorWithClass:(Class)enumeratedClass;

@property (nonatomic,readonly) Class enumeratedClass;

- (nullable Protocol *)nextProtocol;

@end

NS_ASSUME_NONNULL_END
