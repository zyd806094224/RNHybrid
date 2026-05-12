import { HMRouter, HMRouterMgr } from "@hadss/hmrouter";
import { CommonConstants, RouterUrl, AuthManager } from "component";

/**
 * 首页 - 2列网格卡片，对应 Android HomeFragment
 */
@HMRouter({ pageUrl: RouterUrl.ONE_TAB_INDEX_PAGE })
@Entry
@ComponentV2
export struct OnePage {

  build() {
    Scroll() {
      Column() {
        // 标题
        Text('首页')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16, top: 16 })
          .alignSelf(ItemAlign.Start)

        // 2列网格
        Grid() {
          // 小仓库（已启用）
          GridItem() {
            this.FeatureCard('📦', '小仓库', '密码管理', '#6200EE', true)
          }

          // 数据看板
          GridItem() {
            this.FeatureCard('📊', '数据看板', '敬请期待', '#2196F3', false)
          }

          // 备忘录
          GridItem() {
            this.FeatureCard('📝', '备忘录', '敬请期待', '#4CAF50', false)
          }

          // 消息中心
          GridItem() {
            this.FeatureCard('🔔', '消息中心', '敬请期待', '#FF9800', false)
          }

          // 多媒体
          GridItem() {
            this.FeatureCard('🎬', '多媒体', '敬请期待', '#F44336', false)
          }

          // 系统设置
          GridItem() {
            this.FeatureCard('⚙', '系统设置', '敬请期待', '#009688', false)
          }
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
        .padding({ left: 12, right: 12, top: 16, bottom: 16 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .backgroundColor('#F5F5F5')
    .scrollBar(BarState.Off)
    .onAppear(() => {})
  }

  /**
   * 功能卡片
   */
  @Builder
  FeatureCard(icon: string, title: string, subtitle: string, color: string, enabled: boolean) {
    Column() {
      // 图标圆形背景
      Text(icon)
        .fontSize(22)
        .width(44)
        .height(44)
        .textAlign(TextAlign.Center)
        .borderRadius(22)
        .backgroundColor(color + '20')
        .fontColor(color)

      Text(title)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor(enabled ? '#333333' : '#333333')
        .margin({ top: 8 })

      Text(subtitle)
        .fontSize(11)
        .fontColor(enabled ? '#999999' : '#BBBBBB')
        .margin({ top: 2 })
    }
    .width('100%')
    .padding({ top: 20, bottom: 20 })
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 2, color: '#0F000000', offsetY: 1 })
    .enabled(enabled)
    .opacity(enabled ? 1 : 0.6)
    .onClick(() => {
      if (enabled) {
        this.goToRNPage();
      }
    })
  }

  /**
   * 跳转 RN 页面，未登录时先跳转登录页
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
