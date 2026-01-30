#import <AVFoundation/AVFoundation.h>
#import <Cocoa/Cocoa.h>

@interface WallpaperWindow : NSWindow
@end

@implementation WallpaperWindow
- (BOOL)canBecomeKeyWindow {
  return NO;
}
- (BOOL)canBecomeMainWindow {
  return NO;
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property(strong) NSMutableArray *windows;
@property(strong) NSString *videoPath;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  self.windows = [NSMutableArray array];

  NSURL *videoURL = [NSURL fileURLWithPath:self.videoPath];

  if (![[NSFileManager defaultManager] fileExistsAtPath:self.videoPath]) {
    printf("Error: File not found: %s\n", [self.videoPath UTF8String]);
    [NSApp terminate:nil];
    return;
  }

  printf("Loading video: %s\n", [self.videoPath UTF8String]);

  for (NSScreen *screen in [NSScreen screens]) {
    NSRect frame = [screen frame];

    WallpaperWindow *window =
        [[WallpaperWindow alloc] initWithContentRect:frame
                                           styleMask:NSWindowStyleMaskBorderless
                                             backing:NSBackingStoreBuffered
                                               defer:NO];

    [window setLevel:kCGDesktopWindowLevel];
    [window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces |
                                  NSWindowCollectionBehaviorStationary |
                                  NSWindowCollectionBehaviorIgnoresCycle];

    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];

    [playerItem addObserver:self
                 forKeyPath:@"status"
                    options:NSKeyValueObservingOptionNew
                    context:NULL];

    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    NSView *contentView = [[NSView alloc] initWithFrame:frame];
    [contentView setWantsLayer:YES];
    [contentView.layer addSublayer:playerLayer];
    [window setContentView:contentView];

    [[NSNotificationCenter defaultCenter]
        addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                    object:player.currentItem
                     queue:nil
                usingBlock:^(NSNotification *note) {
                  [player seekToTime:kCMTimeZero];
                  [player play];
                }];

    [window setOpaque:NO];
    [window setBackgroundColor:[NSColor blackColor]];
    [window orderFrontRegardless];

    [player play];

    [self.windows addObject:@{@"window" : window, @"player" : player}];
  }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"status"]) {
    AVPlayerItem *item = (AVPlayerItem *)object;
    if (item.status == AVPlayerItemStatusFailed) {
      printf("Error loading video: %s\n",
             [[item.error localizedDescription] UTF8String]);
    } else if (item.status == AVPlayerItemStatusReadyToPlay) {
      printf("Video ready to play\n");
    }
  }
}

@end

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    NSString *videoPath = nil;

    for (int i = 1; i < argc; i++) {
      if (strcmp(argv[i], "--path") == 0 && i + 1 < argc) {
        videoPath = [NSString stringWithUTF8String:argv[i + 1]];
        break;
      }
    }

    if (!videoPath) {
      printf("Usage: wallpaper --path <video-file>\n");
      return 1;
    }

    NSApplication *app = [NSApplication sharedApplication];
    [app setActivationPolicy:NSApplicationActivationPolicyAccessory];

    AppDelegate *delegate = [[AppDelegate alloc] init];
    delegate.videoPath = videoPath;
    [app setDelegate:delegate];
    [app run];
  }
  return 0;
}
