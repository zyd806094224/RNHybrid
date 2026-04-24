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
import { PushyFileJSBundleProvider } from 'pushy/src/main/ets/PushyFileJSBundleProvider';
import { RouterUrl } from 'component';
import { createRNPackages } from '../RNPackagesFactory';

@Builder
export function buildCustomRNComponent(ctx: ComponentBuilderContext) {}

const wrappedCustomRNComponentBuilder = wrapBuilder(buildCustomRNComponent)

/**
 * RN 载体页面 - 使用 RNOH 原生渲染 React Native
 * 支持 Metro 开发热加载、Pushy 热更新、内置 Bundle 三种模式
 */
@HMRouter({ pageUrl: RouterUrl.RN_PAGE_URL })
@Component
export struct RNPage {
  @StorageLink('RNOHCoreContext') private rnohCoreContext: RNOHCoreContext | undefined = undefined
  private logger!: RNOHLogger

  aboutToAppear(): void {
    this.logger = this.rnohCoreContext!.logger.clone("RNPage")
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
          wrappedCustomRNComponentBuilder: wrappedCustomRNComponentBuilder,
          jsBundleProvider: new TraceJSBundleProviderDecorator(
            new AnyJSBundleProvider([
              new MetroJSBundleProvider(),
              new ResourceJSBundleProvider(
                this.rnohCoreContext!.uiAbilityContext.resourceManager,
                'bundle.harmony.js'
              ),
              new PushyFileJSBundleProvider(this.rnohCoreContext!.uiAbilityContext),
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
