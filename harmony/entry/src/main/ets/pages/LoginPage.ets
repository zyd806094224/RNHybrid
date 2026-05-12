/**
 * 原生登录页面
 * 对应 Android 端的 LoginActivity
 */
import { HMRouter } from '@hadss/hmrouter';
import { RouterUrl, AuthManager } from 'component';
import { httpClient } from 'network';
import { promptAction } from '@kit.ArkUI';
import { HMRouterMgr } from '@hadss/hmrouter';

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

  build() {
    Column() {
      // 标题区域
      Text('RNHybrid')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })

      Text('账号登录')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ bottom: 40 })

      // 表单卡片
      Column() {
        // 用户名
        TextInput({ placeholder: '请输入用户名', text: this.username })
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontColor('#333333')
          .placeholderColor('#999999')
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
          .padding({ left: 14, right: 14 })
          .enabled(!this.loading)
          .onChange((value: string) => {
            this.username = value;
          })

        // 密码
        Row() {
          TextInput({ placeholder: '请输入密码', text: this.password })
            .layoutWeight(1)
            .height(48)
            .fontSize(16)
            .fontColor('#333333')
            .placeholderColor('#999999')
            .backgroundColor('#FAFAFA')
            .borderRadius(8)
            .padding({ left: 14, right: 14 })
            .type(this.passwordVisible ? InputType.Normal : InputType.Password)
            .enabled(!this.loading)
            .onChange((value: string) => {
              this.password = value;
            })

          Text(this.passwordVisible ? '隐藏' : '显示')
            .fontSize(13)
            .fontColor('#2196F3')
            .margin({ left: 12 })
            .onClick(() => {
              this.passwordVisible = !this.passwordVisible;
            })
        }
        .width('100%')
        .margin({ top: 16 })

        // 登录按钮
        if (this.loading) {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#2196F3')
            .margin({ top: 24 })
        } else {
          Button('登 录')
            .width('100%')
            .height(48)
            .fontSize(16)
            .fontColor(Color.White)
            .backgroundColor('#2196F3')
            .borderRadius(8)
            .margin({ top: 24 })
            .onClick(() => this.handleLogin())
        }
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .borderRadius(12)
      .shadow({ radius: 8, color: '#1A000000', offsetY: 2 })
    }
    .width('100%')
    .height('100%')
    .padding({ left: 30, right: 30 })
    .backgroundColor('#F5F5F5')
    .justifyContent(FlexAlign.Center)
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
