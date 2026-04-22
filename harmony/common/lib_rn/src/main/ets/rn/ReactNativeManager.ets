/**
 * ReactNative 配置管理器（单例）
 * 对应 Android 端的 ReactNativeManager
 *
 * 管理 RN 应用名称和初始参数等配置
 * RNOH 使用 MetroJSBundleProvider / PushyFileJSBundleProvider 管理 Bundle 加载
 */
export class ReactNativeManager {
  private static instance: ReactNativeManager | null = null

  /**
   * RN 应用名称（对应 AppRegistry.registerComponent 的 appName）
   */
  private appName: string = 'RNHybrid'

  /**
   * 传递给 RN 端的初始参数
   */
  private initialProps: Record<string, string> = { 'param1': 'harmony' }

  private constructor() {}

  static getInstance(): ReactNativeManager {
    if (!ReactNativeManager.instance) {
      ReactNativeManager.instance = new ReactNativeManager()
    }
    return ReactNativeManager.instance
  }

  /**
   * 获取 RN 应用名称
   */
  getAppName(): string {
    return this.appName
  }

  /**
   * 获取传递给 RN 的初始参数
   */
  getInitialProps(): Record<string, string> {
    return this.initialProps
  }
}
