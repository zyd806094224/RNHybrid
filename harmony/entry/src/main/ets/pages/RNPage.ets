import { HMLifecycleState, HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import {
  RNApp,
  RNOHCoreContext,
  AnyJSBundleProvider,
  MetroJSBundleProvider,
  ResourceJSBundleProvider,
  TraceJSBundleProviderDecorator,
} from '@rnoh/react-native-openharmony';
import { PushyFileJSBundleProvider } from 'pushy';
import { RouterUrl } from 'component';
import { createRNPackages } from '../RNPackagesFactory';

/**
 * RN 载体页面 - 使用 RNOH 原生渲染 React Native
 * 支持 Metro 开发热加载、Pushy 热更新、内置 Bundle 三种模式
 */
@HMRouter({ pageUrl: RouterUrl.RN_PAGE_URL })
@Component
export struct RNPage {
  @StorageLink('RNOHCoreContext') private rnohCoreContext: RNOHCoreContext | undefined = undefined

  aboutToAppear(): void {
    const owner = HMRouterMgr.getCurrentLifecycleOwner();
    owner?.addObserver(HMLifecycleState.onBackPressed, () => {
      return false;
    });
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
          },
          appKey: "RNHybrid",
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
}
