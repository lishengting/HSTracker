/*
 * This file is part of the HSTracker package.
 * (c) Benjamin Michotte <bmichotte@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * Created on 13/02/16.
 */
@import Foundation;

@interface Hearthstone : NSObject

+ (Hearthstone *)instance;

- (void)start;

- (NSString *)logPath;

- (BOOL)isHearthstoneRunning;

@end