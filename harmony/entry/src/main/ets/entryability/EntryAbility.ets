import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Logger } from 'component';
import { RNInstancesCoordinator, StandardRNOHLogger } from '@rnoh/react-native-openharmony';

const DOMAIN = 0x0000;

const TAG = 'EntryAbility'

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');

    // 初始化 RNOH 上下文（与 RNAbility.onCreate 相同逻辑）
    const rnohLogger = new StandardRNOHLogger();
    const rnCoordinator = RNInstancesCoordinator.create({
      logger: rnohLogger,
      uiAbilityContext: this.context,
      defaultBackPressHandler: () => {},
      rnohWorkerScriptUrl: undefined,
    }, {
      disableCleaningRNInstances: false,
      launchURI: want.uri,
      onGetPackagerClientConfig: (buildMode: string) => buildMode === "DEBUG" ? {
        host: "localhost",
        port: 8081
      } : undefined,
    });
    AppStorage.setOrCreate('RNOHCoreContext', rnCoordinator.getRNOHCoreContext());

    this.context.eventHub.on('initCompleted', () => {
      Logger.i(TAG, 'application init completed')
    })
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 加载原生 Launcher 页面（不是 RN 页面）
    windowStage.loadContent('pages/Launcher', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
