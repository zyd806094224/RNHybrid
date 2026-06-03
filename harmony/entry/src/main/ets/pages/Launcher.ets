import { HMDefaultGlobalAnimator, HMNavigation } from '@hadss/hmrouter'
import { CommonConstants, RouterUrl } from 'component'
import { AttributeUpdater } from '@kit.ArkUI'

/**
 * LauncherNavModifier 类负责修改导航属性以控制导航栏的显示状态。
 * 继承自 AttributeUpdater 类，用于更新 NavigationAttribute 类型的属性。
 */
class LauncherNavModifier extends AttributeUpdater<NavigationAttribute> {
  /**
   * 初始化导航属性修改器。
   * @param instance 要修改的 NavigationAttribute 实例。
   */
  initializeModifier(instance: NavigationAttribute): void {
    // 设置导航栏为隐藏状态。
    instance.hideNavBar(true)
  }
}

/**
 * 启动页面承载容器
 */
@Entry
@ComponentV2
struct Launcher {
  modifier: LauncherNavModifier = new LauncherNavModifier()
  /**
   * Android SplashActivity 停留 1200ms 后淡入 MainActivity。
   * 鸿蒙侧用原生 Launcher 承载同样的启动过渡，再创建主页面导航容器。
   */
  @Local showMainContent: boolean = false
  @Local showSplash: boolean = true
  @Local splashOpacity: number = 1

  private readonly splashDuration: number = 1200
  private readonly splashFadeDelay: number = 80
  private readonly splashFadeDuration: number = 240

  aboutToAppear(): void {
    setTimeout(() => {
      this.showMainContent = true
      setTimeout(() => {
        animateTo({
          duration: this.splashFadeDuration,
          curve: Curve.EaseInOut,
        }, () => {
          this.splashOpacity = 0
        })
      }, this.splashFadeDelay)
      setTimeout(() => {
        this.showSplash = false
      }, this.splashFadeDelay + this.splashFadeDuration)
    }, this.splashDuration)
  }

  /**
   * 创建页面结构
   */
  build() {
    Stack() {
      if (this.showMainContent) {
        HMNavigation({
          navigationId: CommonConstants.LAUNCHER_NAVIGATION_ID,
          homePageUrl: RouterUrl.MAIN_PAGE_URL,
          options: {
            standardAnimator: HMDefaultGlobalAnimator.STANDARD_ANIMATOR,
            modifier: this.modifier,
          }
        })
      }

      if (this.showSplash) {
        this.SplashContent()
      }
    }
    .height('100%')
    .width('100%')
  }

  /**
   * 启动页主视觉按 Android activity_splash.xml 同步：
   * 渐变背景、轻匣主视觉、应用名、副标题和底部英文标语保持一致。
   */
  @Builder
  SplashContent() {
    Column() {
      Blank()
        .layoutWeight(1)

      Stack() {
        Image($r('app.media.img_splash_qingxia'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Contain)
      }
      .width(236)
      .height(236)
      .padding(10)
      .backgroundColor(Color.White)
      .borderRadius(8)
      .shadow({ radius: 16, color: '#1A18BFAE', offsetY: 8 })

      Text('轻匣')
        .fontSize(33)
        .fontWeight(FontWeight.Bold)
        .fontColor('#12363A')
        .margin({ top: 28 })

      Text('安全收纳账号与备忘')
        .fontSize(15)
        .fontColor('#5F777A')
        .margin({ top: 8 })

      Stack({ alignContent: Alignment.Start }) {
        Row()
          .width(86)
          .height(6)
          .backgroundColor('#18BFAE')
          .borderRadius(3)
      }
      .width(132)
      .height(6)
      .margin({ top: 32 })
      .backgroundColor('#D6F4EF')
      .borderRadius(3)

      Blank()
        .layoutWeight(1)

      Text('Secure notes, lighter life')
        .fontSize(12)
        .fontColor('#8AA0A2')
        .margin({ bottom: 34 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 28, right: 28 })
    .alignItems(HorizontalAlign.Center)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#E4FFF8', 0], ['#F6FFFC', 0.45], ['#FFFFFF', 1]],
    })
    .opacity(this.splashOpacity)
  }
}
