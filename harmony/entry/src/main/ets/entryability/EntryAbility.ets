import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { Logger } from 'component';
import { HMRouterMgr } from '@hadss/hmrouter';
import { RNInstancesCoordinator, StandardRNOHLogger } from '@rnoh/react-native-openharmony';
import { fileIo } from '@kit.CoreFileKit';
import { AuthManager } from 'component';

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
      defaultBackPressHandler: () => {
        HMRouterMgr.pop();
      },
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

    // 将自签名证书从 rawfile 拷贝到沙箱目录，供 HTTP 请求的 caPath 使用
    this.copyCertToSandbox();

    // 初始化 AuthManager（preferences 持久化存储）
    AuthManager.getInstance().init(this.context);

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

  /**
   * 将自签名证书从 rawfile 拷贝到应用沙箱目录
   * @ohos.net.http 的 caPath 只能访问沙箱路径，无法直接读取 rawfile
   */
  private copyCertToSandbox(): void {
    const certFileName = 'server_cert.pem';
    const sandboxDir = this.context.filesDir;
    const sandboxPath = sandboxDir + '/' + certFileName;

    try {
      // 沙箱中已存在则跳过
      if (fileIo.accessSync(sandboxPath)) {
        AppStorage.setOrCreate('serverCertPath', sandboxPath);
        hilog.info(DOMAIN, TAG, '证书已存在: %{public}s', sandboxPath);
        return;
      }
    } catch (e) {
      // 文件不存在，继续拷贝
    }

    try {
      const rawFd = this.context.resourceManager.getRawFileContentSync(certFileName);
      const file = fileIo.openSync(sandboxPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.WRITE_ONLY);
      fileIo.writeSync(file.fd, rawFd.buffer);
      fileIo.closeSync(file);
      AppStorage.setOrCreate('serverCertPath', sandboxPath);
      hilog.info(DOMAIN, TAG, '证书拷贝成功: %{public}s', sandboxPath);
    } catch (err) {
      hilog.error(DOMAIN, TAG, '证书拷贝失败: %{public}s', JSON.stringify(err));
    }
  }
}
