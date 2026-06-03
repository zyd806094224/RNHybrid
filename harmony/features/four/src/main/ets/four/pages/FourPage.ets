import { HMRouter, HMRouterMgr, HMLifecycleState } from '@hadss/hmrouter';
import { RouterUrl, CommonConstants, AuthManager, WindowUtils } from 'component';

/**
 * 我的页面 - 对应 Android MineFragment。
 * 根据登录态动态切换：未登录点击头部去登录，已登录显示用户名和退出登录入口。
 */
@HMRouter({ pageUrl: RouterUrl.FOUR_TAB_INDEX_PAGE })
@Entry
@ComponentV2
export struct FourPage {
  @Local userName: string = '未登录'
  @Local userSubtitle: string = '点击去登录'
  @Local isLoggedInState: boolean = false

  private hasLifecycleObserver: boolean = false

  aboutToAppear(): void {
    this.applyMineStatusBar()

    this.refreshUI()
    if (!this.hasLifecycleObserver) {
      this.hasLifecycleObserver = true
      // Android 在 onResume 刷新登录态和状态栏；鸿蒙侧登录页 pop 回来只触发 onShown。
      const owner = HMRouterMgr.getCurrentLifecycleOwner();
      owner?.addObserver(HMLifecycleState.onShown, () => {
        this.applyMineStatusBar()
        this.refreshUI()
      });
    }
  }

  private applyMineStatusBar(): void {
    // Android MineFragment 使用青绿色沉浸状态栏，状态栏和头像头图区要是一整块颜色。
    WindowUtils.setWindowLayoutFullScreen(true).catch(() => {})
    WindowUtils.setStatusBar({
      statusBarColor: '#18BFAE',
      statusBarContentColor: '#FFFFFF',
    }).catch(() => {})
  }

  private refreshUI() {
    const authManager = AuthManager.getInstance()
    this.isLoggedInState = authManager.isLoggedIn()
    if (this.isLoggedInState) {
      this.userName = authManager.getUsername()
      this.userSubtitle = '已登录'
    } else {
      this.userName = '未登录'
      this.userSubtitle = '点击去登录'
    }
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          this.ProfileHeader()
          this.CardGroup()
        }
        .width('100%')
        .padding({ bottom: 24 })
        .alignItems(HorizontalAlign.Start)
      }
      .layoutWeight(1)
      .backgroundColor('#F7FAFC')
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F7FAFC')
  }

  /**
   * 顶部个人信息区域按 Android bg_mine_header 同步。
   */
  @Builder
  ProfileHeader() {
    Column() {
      Row() {
        Stack() {
          Text('👤')
            .fontSize(30)
            .fontColor('#18BFAE')
        }
        .width(64)
        .height(64)
        .backgroundColor('#E9FFFB')
        .borderRadius(8)

        Column() {
          Text(this.userName)
            .fontSize(21)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(this.userSubtitle)
            .fontSize(12)
            .fontColor('#EAF2FF')
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .margin({ top: 6 })
            .backgroundColor('#26FFFFFF')
            .borderRadius(8)
        }
        .layoutWeight(1)
        .margin({ left: 14 })
        .alignItems(HorizontalAlign.Start)

        Text('›')
          .fontSize(28)
          .fontColor('#CCFFFFFF')
      }
      .width('100%')
      .margin({ top: 18 })
      .alignItems(VerticalAlign.Center)

      Row() {
        this.HeaderMetric('0', '收藏')
        this.HeaderMetric('0', '优惠券')
        this.HeaderMetric('0', '消息')
      }
      .width('100%')
      .margin({ top: 18 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 38, bottom: 20 })
    .backgroundColor('#18BFAE')
    .onClick(() => {
      if (!this.isLoggedInState) {
        this.goLogin()
      }
    })
  }

  @Builder
  HeaderMetric(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)

      Text(label)
        .fontSize(12)
        .fontColor('#CCEAF2FF')
        .margin({ top: 4 })
    }
    .layoutWeight(1)
    .height(60)
    .margin({ left: label === '收藏' ? 0 : 10 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#20FFFFFF')
    .borderRadius(8)
  }

  @Builder
  CardGroup() {
    // ArkUI 中 width('100%') 再叠加左右 margin 会向外溢出；
    // 外层统一 padding，卡片内部保持 100%，右侧边框才不会跑出屏幕。
    Column() {
      this.AccountInfoCard()
      this.ShortcutCard()
      this.SettingsCard()
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  AccountInfoCard() {
    Column() {
      Text('账户信息')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#101828')
        .alignSelf(ItemAlign.Start)

      this.InfoRow('☎', '#EAF1FF', '#155EEF', '手机号', '未绑定')
      Divider()
        .color('#F2F4F7')
        .margin({ left: 48 })
      this.InfoRow('✉', '#CCF7F3', '#008E7D', '邮箱', '未绑定')
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .border({ width: 1, color: '#0F101828' })
    .borderRadius(8)
    .margin({ top: 14 })
  }

  @Builder
  ShortcutCard() {
    Grid() {
      GridItem() {
        this.ShortcutItem('💼', '#FFF4E5', '钱包')
      }
      GridItem() {
        this.ShortcutItem('券', '#EAF8EF', '卡券')
      }
      GridItem() {
        this.ShortcutItem('☎', '#FEECEC', '客服')
      }
      GridItem() {
        this.ShortcutItem('⚙', '#F1ECFE', '设置')
      }
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .width('100%')
    .padding({ top: 18, bottom: 16 })
    .backgroundColor(Color.White)
    .border({ width: 1, color: '#0F101828' })
    .borderRadius(8)
    .margin({ top: 12 })
  }

  @Builder
  ShortcutItem(icon: string, iconBg: string, label: string) {
    Column() {
      Stack() {
        Text(icon)
          .fontSize(20)
      }
      .width(42)
      .height(42)
      .backgroundColor(iconBg)
      .borderRadius(21)

      Text(label)
        .fontSize(13)
        .fontColor('#344054')
        .margin({ top: 9 })
    }
    .width('100%')
    .height(82)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  SettingsCard() {
    Column() {
      this.ActionRow('🛡', '#EAF8EF', '账户安全', '待完善', false, '#344054')
      Divider()
        .color('#F2F4F7')
        .margin({ left: 48 })
      this.ActionRow('ⓘ', '#EAF1FF', '关于我们', '', true, '#344054')

      if (this.isLoggedInState) {
        Divider()
          .color('#F2F4F7')
          .margin({ left: 48 })
        this.LogoutRow()
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(Color.White)
    .border({ width: 1, color: '#0F101828' })
    .borderRadius(8)
    .margin({ top: 12, bottom: 16 })
  }

  @Builder
  InfoRow(icon: string, iconBg: string, iconColor: string, label: string, value: string) {
    Row() {
      this.RoundIcon(icon, iconBg, iconColor, 36)

      Text(label)
        .fontSize(14)
        .fontColor('#344054')
        .layoutWeight(1)
        .margin({ left: 12 })

      Text(value)
        .fontSize(14)
        .fontColor('#98A2B3')
    }
    .width('100%')
    .height(54)
    .margin({ top: 12 })
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  ActionRow(icon: string, iconBg: string, label: string, rightText: string, showArrow: boolean, labelColor: string) {
    Row() {
      this.RoundIcon(icon, iconBg, labelColor, 36)

      Text(label)
        .fontSize(14)
        .fontColor(labelColor)
        .layoutWeight(1)
        .margin({ left: 12 })

      if (rightText.length > 0) {
        Text(rightText)
          .fontSize(13)
          .fontColor('#98A2B3')
      }

      if (showArrow || rightText.length > 0) {
        Text('›')
          .fontSize(22)
          .fontColor('#98A2B3')
          .margin({ left: 6 })
      }
    }
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  LogoutRow() {
    Row() {
      this.RoundIcon('↩', '#FEECEC', '#DC2626', 36)

      Text('退出登录')
        .fontSize(14)
        .fontColor('#DC2626')
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .margin({ left: 12 })
    }
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.handleLogout())
  }

  @Builder
  RoundIcon(icon: string, bg: string, color: string, size: number) {
    Stack() {
      Text(icon)
        .fontSize(size === 42 ? 21 : 18)
        .fontColor(color)
    }
    .width(size)
    .height(size)
    .backgroundColor(bg)
    .borderRadius(size / 2)
  }

  /**
   * 退出登录只在已登录时展示，与 Android layout_logout_row 的 gone/visible 行为一致。
   */
  private handleLogout() {
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
          await AuthManager.getInstance().logout()
          this.refreshUI()
        }
      }
    })
  }

  private goLogin() {
    HMRouterMgr.push({
      navigationId: CommonConstants.LAUNCHER_NAVIGATION_ID,
      pageUrl: RouterUrl.LOGIN_PAGE_URL,
    })
  }
}
