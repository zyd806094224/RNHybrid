import { HMRouter, HMRouterMgr } from "@hadss/hmrouter";
import { CommonConstants, RouterUrl } from "component";

/**
 * 主页 - 匹配 Android HomeFragment 布局
 */
@HMRouter({ pageUrl: RouterUrl.ONE_TAB_INDEX_PAGE })
@Entry
@ComponentV2
export struct OnePage {

  build() {
    Scroll() {
      Column() {
        // 标题区域
        Text('主页')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ left: 16, top: 16 })
          .alignSelf(ItemAlign.Start)

        Text('欢迎来到 RN Hybrid Demo')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 16, top: 8 })
          .alignSelf(ItemAlign.Start)

        // React Native 混合开发卡片
        this.RNCard()

        // 功能特性卡片
        this.FeaturesCard()
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .scrollBar(BarState.Off)
  }

  /**
   * React Native 混合开发卡片
   */
  @Builder
  RNCard() {
    Column() {
      Text('React Native 混合开发')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)

      Text('体验 React Native 与原生的混合开发能力')
        .fontSize(13)
        .fontColor('#999999')
        .margin({ top: 8 })
        .alignSelf(ItemAlign.Start)

      Button('点击去 RN 页面')
        .width('100%')
        .height(44)
        .fontSize(15)
        .fontColor(Color.White)
        .backgroundColor('#6200EE')
        .borderRadius(8)
        .margin({ top: 12 })
        .onClick(() => {
          HMRouterMgr.push({
            navigationId: CommonConstants.LAUNCHER_NAVIGATION_ID,
            pageUrl: RouterUrl.RN_PAGE_URL,
          })
        })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 24 })
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
  }

  /**
   * 功能特性卡片
   */
  @Builder
  FeaturesCard() {
    Column() {
      Text('功能特性')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)

      Text('- 原生 Android + React Native 混合架构\n- 支持热更新 (Pushy)\n- 单 ReactInstanceManager 实例管理\n- 沉浸式状态栏适配\n- 组件化模块设计')
        .fontSize(13)
        .fontColor('#666666')
        .lineHeight(20)
        .margin({ top: 8 })
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 12, bottom: 16 })
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
  }
}
