/**
 * RN → 原生 Auth 通信 TurboModule
 * 对应 Android 端的 AuthModule
 *
 * RN 侧检测到 token 过期（401）时调用 onTokenExpired()，由原生侧处理登录态清理和页面跳转
 */
import { UITurboModule, UITurboModuleContext } from '@rnoh/react-native-openharmony';

export class AuthTurboModule extends UITurboModule {
  public static readonly NAME = 'AuthModule';

  onTokenExpired(): void {
    if (AuthTurboModule.isHandling) return;
    AuthTurboModule.isHandling = true;
    AuthTurboModule.tokenExpiredCallback?.();
  }

  static tokenExpiredCallback: (() => void) | null = null;
  static isHandling: boolean = false;
}
