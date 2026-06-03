/**
 * 原生登录页面
 * 对应 Android 端的 LoginActivity
 */
import { HMRouter, HMRouterMgr } from '@hadss/hmrouter';
import { RouterUrl, AuthManager, WindowUtils } from 'component';
import { httpClient } from 'network';
import { promptAction } from '@kit.ArkUI';

interface LoginResult {
  code: number;
  token: string;
  msg: string;
}

@HMRouter({ pageUrl: RouterUrl.LOGIN_PAGE_URL })
@Entry
@Component
export struct LoginPage {
  @State username: string = '';
  @State password: string = '';
  @State loading: boolean = false;
  @State passwordVisible: boolean = false;

  aboutToAppear(): void {
    // 登录页背景延伸到状态栏，和 Android LoginActivity 的浅绿状态栏保持一致。
    WindowUtils.setWindowLayoutFullScreen(true).catch(() => {})
    WindowUtils.setStatusBar({
      statusBarColor: '#E6FFF8',
      statusBarContentColor: '#203437',
    }).catch(() => {})
  }

  build() {
    Scroll() {
      Column() {
        this.LoginHeader()
        this.LoginCard()
        this.SecurityNotice()
      }
      .width('100%')
      .constraintSize({ minHeight: '100%' })
      .padding({ bottom: 28 })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#E6FFF8', 0], ['#F6FFFC', 0.45], ['#FFFFFF', 1]],
    })
  }

  /**
   * Android 登录页顶部是整块渐变头图，logo + 文案和表单卡片分离。
   * 鸿蒙侧也拆成独立头部，避免退化成居中表单页。
   */
  @Builder
  LoginHeader() {
    Column() {
      Row() {
        Stack() {
          Image($r('app.media.ic_qingxia_launcher'))
            .width('100%')
            .height('100%')
            .objectFit(ImageFit.Contain)
        }
        .width(48)
        .height(48)
        .padding(5)
        .backgroundColor(Color.White)
        .borderRadius(8)

        Column() {
          Text('轻匣')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#203437')

          Text('账号与备忘安全收纳')
            .fontSize(13)
            .fontColor('#5F7376')
            .margin({ top: 2 })
        }
        .layoutWeight(1)
        .margin({ left: 14 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Text('欢迎回到轻匣')
        .fontSize(27)
        .fontWeight(FontWeight.Bold)
        .fontColor('#172C30')
        .margin({ top: 30 })
        .alignSelf(ItemAlign.Start)

      Text('验证身份后访问你的私密空间')
        .fontSize(14)
        .fontColor('#60777B')
        .margin({ top: 7 })
        .alignSelf(ItemAlign.Start)
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 68, bottom: 26 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#DDFCF6', 0], ['#F2FFFB', 0.55], ['#FFFFFF', 1]],
    })
  }

  @Builder
  LoginCard() {
    Column() {
      Text('账号密码登录')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1F2F34')
        .alignSelf(ItemAlign.Start)

      Text('请填写用于进入轻匣的账号信息')
        .fontSize(13)
        .fontColor('#7A878B')
        .margin({ top: 5 })
        .alignSelf(ItemAlign.Start)

      Text('账号')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#344054')
        .margin({ top: 24 })
        .alignSelf(ItemAlign.Start)

      this.InputRow('👤', '请输入账号', false)

      Text('密码')
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor('#344054')
        .margin({ top: 18 })
        .alignSelf(ItemAlign.Start)

      this.InputRow('🔒', '请输入密码', true)

      if (this.loading) {
        LoadingProgress()
          .width(34)
          .height(34)
          .color('#18BFAE')
          .margin({ top: 28 })
      } else {
        Button('安全登录')
          .width('100%')
          .height(52)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .backgroundColor('#18BFAE')
          .borderRadius(8)
          .margin({ top: 26 })
          .onClick(() => this.handleLogin())
      }
    }
    .width('100%')
    .margin({ left: 20, right: 20, top: 14 })
    .padding({ left: 20, right: 20, top: 22, bottom: 22 })
    .backgroundColor(Color.White)
    .border({ width: 1, color: '#E7F0EE' })
    .borderRadius(8)
    .shadow({ radius: 8, color: '#14000000', offsetY: 2 })
  }

  @Builder
  InputRow(icon: string, placeholder: string, isPassword: boolean) {
    Row() {
      Text(icon)
        .fontSize(18)
        .fontColor('#7C9094')

      TextInput({
        placeholder,
        text: isPassword ? this.password : this.username,
      })
        .layoutWeight(1)
        .height(52)
        .fontSize(15)
        .fontColor('#203033')
        .placeholderColor('#A3ADB3')
        .backgroundColor('#00000000')
        .padding({ left: 10, right: 0 })
        .type(isPassword && !this.passwordVisible ? InputType.Password : InputType.Normal)
        .enabled(!this.loading)
        .onChange((value: string) => {
          if (isPassword) {
            this.password = value;
          } else {
            this.username = value;
          }
        })

      if (isPassword) {
        Text(this.passwordVisible ? '隐藏' : '显示')
          .fontSize(13)
          .fontColor('#7C9094')
          .width(44)
          .height(44)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (!this.loading) {
              this.passwordVisible = !this.passwordVisible;
            }
          })
      }
    }
    .width('100%')
    .height(52)
    .margin({ top: 8 })
    .padding({ left: 14, right: isPassword ? 0 : 14 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#F8FBFA')
    .border({ width: 1, color: '#E4ECEB' })
    .borderRadius(8)
  }

  @Builder
  SecurityNotice() {
    Row() {
      Text('🛡')
        .fontSize(18)
        .fontColor('#18BFAE')

      Text('账号信息仅用于身份校验，请妥善保管')
        .fontSize(12)
        .fontColor('#63787C')
        .layoutWeight(1)
        .margin({ left: 9 })
    }
    .width('100%')
    .margin({ left: 24, right: 24, top: 20 })
    .padding({ left: 14, right: 14, top: 12, bottom: 12 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#F0FBF8')
    .border({ width: 1, color: '#D6F4EF' })
    .borderRadius(8)
  }

  private async handleLogin() {
    if (!this.username.trim()) {
      promptAction.showToast({ message: '请输入用户名' });
      return;
    }
    if (!this.password.trim()) {
      promptAction.showToast({ message: '请输入密码' });
      return;
    }

    this.loading = true;
    try {
      const response = await httpClient.post<LoginResult>('https://106.15.7.132:8443/login', {
        username: this.username.trim(),
        password: this.password,
      });
      // 后端直接返回 { code, token, msg }
      const obj: Object = response as Object;
      const result: LoginResult = JSON.parse(JSON.stringify(obj)) as LoginResult;
      if (result.code === 200 && result.token) {
        const authManager = AuthManager.getInstance();
        await authManager.saveLogin(result.token, this.username.trim());
        promptAction.showToast({ message: '登录成功' });
        HMRouterMgr.pop();
      } else {
        promptAction.showToast({ message: result.msg || '登录失败' });
      }
    } catch {
      promptAction.showToast({ message: '网络异常，请检查网络连接' });
    } finally {
      this.loading = false;
    }
  }
}
