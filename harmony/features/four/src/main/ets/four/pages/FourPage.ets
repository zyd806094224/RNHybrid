import { HMRouter, HMRouterMgr, HMLifecycleState } from "@hadss/hmrouter";
import { RouterUrl, CommonConstants, AuthManager } from "component";
import { promptAction } from "@kit.ArkUI";

/**
 * 我的页面 - 对应 Android MineFragment
 * 根据登录态动态切换：未登录显示"点击去登录"，已登录显示用户名 + 退出登录二次确认
 */
@HMRouter({ pageUrl: RouterUrl.FOUR_TAB_INDEX_PAGE })
@Entry
@ComponentV2
export struct FourPage {
  @Local userName: string = '未登录'
  @Local userSubtitle: string = '点击去登录'
  @Local logoutText: string = '登录'
  @Local isLogoutTextColor: string = '#6200EE'

  aboutToAppear(): void {
    this.refreshUI()
    // 监听页面重新显示（从 LoginPage pop 回来时触发）
    const owner = HMRouterMgr.getCurrentLifecycleOwner();
    owner?.addObserver(HMLifecycleState.onShown, () => {
      this.refreshUI()
    });
  }

  private refreshUI() {
    const authManager = AuthManager.getInstance()
    if (authManager.isLoggedIn()) {
      this.userName = authManager.getUsername()
      this.userSubtitle = '已登录'
      this.logoutText = '退出登录'
      this.isLogoutTextColor = '#F44336'
    } else {
      this.userName = '未登录'
      this.userSubtitle = '点击去登录'
      this.logoutText = '登录'
      this.isLogoutTextColor = '#6200EE'
    }
  }

  build() {
    Scroll() {
      Column() {
        // 顶部个人信息区域（紫色背景）
        this.ProfileHeader()

        // 个人信息卡片
        this.ProfileInfoCard()

        // 设置选项卡片
        this.SettingsCard()
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
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
        .width(64)
        .height(64)
        .borderRadius(32)

      Text(this.userName)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .margin({ top: 12 })

      Text(this.userSubtitle)
        .fontSize(12)
        .fontColor('#B3FFFFFF')
        .margin({ top: 4 })
    }
    .width('100%')
    .padding({ top: 40, bottom: 28 })
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
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)

      this.InfoRow('手机号', '未绑定')
      Divider().color('#F0F0F0')

      this.InfoRow('邮箱', '未绑定')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 12, right: 12, top: 16 })
    .shadow({ radius: 2, color: '#0F000000', offsetY: 1 })
  }

  /**
   * 设置选项卡片
   */
  @Builder
  SettingsCard() {
    Column() {
      Text('设置')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .alignSelf(ItemAlign.Start)

      Row() {
        Text('关于')
          .fontSize(14)
          .fontColor('#333333')
      }
      .width('100%')
      .height(46)
      .margin({ top: 8 })
      .alignItems(VerticalAlign.Center)

      Divider().color('#F0F0F0')

      // 登录 / 退出登录
      Row() {
        Text(this.logoutText)
          .fontSize(14)
          .fontColor(this.isLogoutTextColor)
      }
      .width('100%')
      .height(46)
      .alignItems(VerticalAlign.Center)
      .onClick(() => this.handleLogoutOrLogin())
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .margin({ left: 12, right: 12, top: 10, bottom: 16 })
    .shadow({ radius: 2, color: '#0F000000', offsetY: 1 })
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
        .fontColor('#999999')
    }
    .width('100%')
    .height(46)
    .margin({ top: 8 })
    .alignItems(VerticalAlign.Center)
  }

  /**
   * 处理登录/退出登录
   */
  private handleLogoutOrLogin() {
    const authManager = AuthManager.getInstance()
    if (authManager.isLoggedIn()) {
      // 已登录 → 二次确认退出
      AlertDialog.show({
        title: '提示',
        message: '确定要退出登录吗？',
        primaryButton: {
          value: '取消',
          action: () => {}
        },
        secondaryButton: {
          value: '确定',
          action: async () => {
            await authManager.logout()
            this.refreshUI()
          }
        }
      })
    } else {
      // 未登录 → 跳转登录页
      HMRouterMgr.push({
        navigationId: CommonConstants.LAUNCHER_NAVIGATION_ID,
        pageUrl: RouterUrl.LOGIN_PAGE_URL,
      })
    }
  }
}
