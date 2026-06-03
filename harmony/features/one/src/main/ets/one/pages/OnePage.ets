import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { CommonConstants, RouterUrl, AuthManager, WindowUtils } from 'component';

/**
 * 首页 - 对应 Android HomeFragment。
 */
@HMRouter({ pageUrl: RouterUrl.ONE_TAB_INDEX_PAGE })
@Entry
@ComponentV2
export struct OnePage {
  aboutToAppear(): void {
    // Android HomeFragment 是浅绿沉浸状态栏，切回主页时需要重置我的页留下的青绿色状态栏。
    WindowUtils.setWindowLayoutFullScreen(true).catch(() => {})
    WindowUtils.setStatusBar({
      statusBarColor: '#E9FFF8',
      statusBarContentColor: '#223033',
    }).catch(() => {})
  }

  build() {
    Column() {
      // Android 通过状态栏高度 + 6dp 固定浅绿顶部；鸿蒙侧保留同色顶部带。
      Row()
        .width('100%')
        .height(32)
        .backgroundColor('#E9FFF8')

      Scroll() {
        Column() {
          this.HomeIntro()

          Grid() {
            GridItem() {
              this.FeatureCard('📦', '小仓库', '密码管理', '#CCF7F3', true)
            }

            GridItem() {
              this.FeatureCard('📊', '数据看板', '敬请期待', '#EAF1FF', false)
            }

            GridItem() {
              this.FeatureCard('📝', '备忘录', '敬请期待', '#EAF8EF', false)
            }

            GridItem() {
              this.FeatureCard('🔔', '消息中心', '敬请期待', '#FFF4E5', false)
            }

            GridItem() {
              this.FeatureCard('🎬', '多媒体', '敬请期待', '#FEECEC', false)
            }

            GridItem() {
              this.FeatureCard('⚙', '系统设置', '敬请期待', '#F1ECFE', false)
            }
          }
          .columnsTemplate('1fr 1fr')
          .columnsGap(8)
          .rowsGap(8)
          .width('100%')
          .padding({ left: 12, right: 12, top: 14, bottom: 24 })
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .backgroundColor('#F7FAFC')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7FAFC')
  }

  @Builder
  HomeIntro() {
    Column() {
      Text('工作台')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#223033')
        .alignSelf(ItemAlign.Start)

      Text('常用工具与业务入口')
        .fontSize(13)
        .fontColor('#6C7A7D')
        .margin({ top: 6 })
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 8, bottom: 22 })
    .backgroundColor('#E9FFF8')
  }

  /**
   * 功能卡片尺寸、描边、圆角和文字层级按 Android fragment_home.xml 同步。
   * 只有“小仓库”启用点击，其它入口保持“敬请期待”展示。
   */
  @Builder
  FeatureCard(icon: string, title: string, subtitle: string, iconBg: string, enabled: boolean) {
    Column() {
      Text(icon)
        .fontSize(22)
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .backgroundColor(iconBg)
        .borderRadius(22)

      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor('#223033')
        .margin({ top: 8 })

      Text(subtitle)
        .fontSize(11)
        .fontColor(enabled ? '#98A2B3' : '#B8C0C8')
        .margin({ top: 2 })
    }
    .width('100%')
    .height(120)
    .padding({ top: 20, bottom: 20 })
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .border({ width: 1, color: '#0F101828' })
    .borderRadius(8)
    .onClick(() => {
      if (enabled) {
        this.goToRNPage();
      }
    })
  }

  /**
   * 跳转 RN 页面，未登录时先跳转登录页。
   */
  private goToRNPage() {
    const authManager = AuthManager.getInstance();
    if (!authManager.isLoggedIn()) {
      HMRouterMgr.push({
        navigationId: CommonConstants.LAUNCHER_NAVIGATION_ID,
        pageUrl: RouterUrl.LOGIN_PAGE_URL,
      });
      return;
    }
    HMRouterMgr.push({
      navigationId: CommonConstants.LAUNCHER_NAVIGATION_ID,
      pageUrl: RouterUrl.RN_PAGE_URL,
    });
  }
}
