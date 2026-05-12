/**
 * Auth RN Package
 * 对应 Android 端的 AuthPackage，将 AuthTurboModule 注册到 RN
 */
import { RNOHPackage, UITurboModule, UITurboModuleContext } from '@rnoh/react-native-openharmony';
import { AuthTurboModule } from './AuthTurboModule';

export class AuthPackage extends RNOHPackage {
  override getUITurboModuleFactoryByNameMap(): Map<string, (ctx: UITurboModuleContext) => UITurboModule | null> {
    return new Map<string, (ctx: UITurboModuleContext) => UITurboModule>()
      .set(AuthTurboModule.NAME, (ctx) => new AuthTurboModule(ctx));
  }
}
