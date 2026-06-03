import { HMLifecycleState, HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import {
  RNApp,
  RNOHCoreContext,
  RNOHLogger,
  AnyJSBundleProvider,
  MetroJSBundleProvider,
  ResourceJSBundleProvider,
  TraceJSBundleProviderDecorator,
  ComponentBuilderContext,
} from '@rnoh/react-native-openharmony';
import { PushyFileJSBundleProvider } from 'pushy';
import { RouterUrl, CommonConstants, AuthManager, WindowUtils } from 'component';
import { createRNPackages } from '../RNPackagesFactory';
import { AuthTurboModule } from 'lib_rn';

@Builder
export function buildCustomRNComponent(ctx: ComponentBuilderContext) {}

const wrappedCustomRNComponentBuilder = wrapBuilder(buildCustomRNComponent)

/**
 * RN 载体页面 - 使用 RNOH 原生渲染 React Native
 * 支持 Metro 开发热加载、Pushy 热更新、内置 Bundle 三种模式
 * 对应 Android 端的 RNPageActivity，传递 token 并处理 token 过期
 */
@HMRouter({ pageUrl: RouterUrl.RN_PAGE_URL })
@Component
export struct RNPage {
  @StorageLink('RNOHCoreContext') private rnohCoreContext: RNOHCoreContext | undefined = undefined
  private logger!: RNOHLogger
  private authManager: AuthManager = AuthManager.getInstance()

  aboutToAppear(): void {
    this.logger = this.rnohCoreContext!.logger.clone("RNPage")
    // RN 侧 SafeContainer 在 Harmony 分支不再额外加安全区 padding，
    // 因此 RN 容器页必须恢复非 fullscreen，让原生窗口把 RNOH surface 放在状态栏下方。
    this.applyRNStatusBar()

    const owner = HMRouterMgr.getCurrentLifecycleOwner();
    owner?.addObserver(HMLifecycleState.onBackPressed, () => {
      this.rnohCoreContext?.dispatchBackPress();
      return true;
    });

    // RN 侧 401 会通过 AuthModule 回到这里；原生侧负责清登录态并回到登录页。
    AuthTurboModule.tokenExpiredCallback = () => {
      this.authManager.logout();
      HMRouterMgr.pop();
      HMRouterMgr.push({
        navigationId: CommonConstants.LAUNCHER_NAVIGATION_ID,
        pageUrl: RouterUrl.LOGIN_PAGE_URL,
      });
    };
  }

  aboutToDisappear(): void {
    AuthTurboModule.isHandling = false;
    AuthTurboModule.tokenExpiredCallback = null;
    this.restoreMainStatusBar()
  }

  build() {
    Column() {
      if (this.rnohCoreContext) {
        RNApp({
          rnInstanceConfig: {
            createRNPackages,
            enableNDKTextMeasuring: true,
            enableBackgroundExecutor: false,
            enableCAPIArchitecture: true,
            arkTsComponentNames: [],
            caPathProvider: (url: string) => {
              if (url && url.includes('106.15.7.132')) {
                // RN fetch 也访问同一个自签名 HTTPS 服务，需要和原生登录请求共用证书。
                return AppStorage.get<string>('serverCertPath') ?? '';
              }
              return '';
            },
          },
          appKey: "RNHybrid",
          initialProps: {
            'param1': 'harmony',
            'token': this.authManager.getToken(),
            'username': this.authManager.getUsername(),
          },
          wrappedCustomRNComponentBuilder: wrappedCustomRNComponentBuilder,
          jsBundleProvider: new TraceJSBundleProviderDecorator(
            new AnyJSBundleProvider([
              new MetroJSBundleProvider(),
              new PushyFileJSBundleProvider(this.rnohCoreContext!.uiAbilityContext),
              new ResourceJSBundleProvider(
                this.rnohCoreContext!.uiAbilityContext.resourceManager,
                'bundle.harmony.js'
              ),
            ]),
            this.rnohCoreContext!.logger
          ),
        })
      }
    }
    .height('100%')
    .width('100%')
  }

  private applyRNStatusBar(): void {
    WindowUtils.setWindowLayoutFullScreen(false).catch(() => {})
    WindowUtils.setStatusBar({
      statusBarColor: '#FFFFFF',
      statusBarContentColor: '#203033',
    }).catch(() => {})
  }

  private restoreMainStatusBar(): void {
    WindowUtils.setWindowLayoutFullScreen(true).catch(() => {})
    const currentPage = AppStorage.get<string>('currentPage') ?? ''
    if (currentPage === RouterUrl.FOUR_TAB_INDEX_PAGE) {
      WindowUtils.setStatusBar({
        statusBarColor: '#18BFAE',
        statusBarContentColor: '#FFFFFF',
      }).catch(() => {})
      return
    }

    WindowUtils.setStatusBar({
      statusBarColor: '#E9FFF8',
      statusBarContentColor: '#223033',
    }).catch(() => {})
  }
}
