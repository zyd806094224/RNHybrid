import { HMRouter } from "@hadss/hmrouter";
import { RouterUrl, AuthManager } from "component";
import { promptAction } from "@kit.ArkUI";

/**
 * 我的页面 - 匹配 Android MineFragment 布局
 */
@HMRouter({ pageUrl: RouterUrl.FOUR_TAB_INDEX_PAGE })
@Entry
@ComponentV2
export struct FourPage {

  build() {
    Scroll() {
      Column() {
        // 顶部个人信息区域
        this.ProfileHeader()

        // 个人信息卡片
        this.ProfileInfoCard()

        // 其他选项卡片
        this.OptionsCard()
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .scrollBar(BarState.Off)
  }

  /**
   * 顶部个人信息区域
   */
  @Builder
  ProfileHeader() {
    Column() {
      Image($r('app.media.layered_image'))
        .width(72)
        .height(72)
        .borderRadius(36)

      Text('张三')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ top: 12 })

      Text('Android 开发工程师')
        .fontSize(13)
        .fontColor('#B3FFFFFF')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding({ top: 32, bottom: 24 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#6200EE')
  }

  /**
   * 个人信息卡片
   */
  @Builder
  ProfileInfoCard() {
    Column() {
      Text('个人信息')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)

      Divider()
        .color('#E0E0E0')
        .margin({ top: 12 })

      this.InfoRow('手机号', '138****8888')
      Divider().color('#F0F0F0')

      this.InfoRow('邮箱', 'zhangsan@example.com')
      Divider().color('#F0F0F0')

      this.InfoRow('部门', '移动开发部')
      Divider().color('#F0F0F0')

      this.InfoRow('工号', 'EMP-20240001')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 16 })
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
  }

  /**
   * 个人信息行
   */
  @Builder
  InfoRow(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .layoutWeight(1)

      Text(value)
        .fontSize(14)
        .fontColor('#333333')
    }
    .width('100%')
    .height(48)
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 其他选项卡片
   */
  @Builder
  OptionsCard() {
    Column() {
      Text('其他')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)

      Divider()
        .color('#E0E0E0')
        .margin({ top: 12 })

      this.OptionRow('设置', '#333333')
      Divider().color('#F0F0F0')

      this.OptionRow('关于', '#333333')
      Divider().color('#F0F0F0')

      Row() {
        Text('退出登录')
          .fontSize(14)
          .fontColor('#FF4444')
      }
      .width('100%')
      .height(48)
      .alignItems(VerticalAlign.Center)
      .onClick(() => this.handleLogout())
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 12, bottom: 16 })
    .shadow({ radius: 4, color: '#1A000000', offsetY: 2 })
  }

  /**
   * 选项行
   */
  @Builder
  OptionRow(title: string, colorStr: string) {
    Row() {
      Text(title)
        .fontSize(14)
        .fontColor(colorStr)
    }
    .width('100%')
    .height(48)
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 退出登录：清除 token 并提示
   */
  private async handleLogout() {
    const authManager = AuthManager.getInstance();
    await authManager.logout();
    promptAction.showToast({ message: '已退出登录' });
  }
}
