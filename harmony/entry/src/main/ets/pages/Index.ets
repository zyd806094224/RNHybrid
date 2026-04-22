import { HMRouterMgr } from '@hadss/hmrouter';
import { RouterUrl } from 'component';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
          HMRouterMgr.push({
            navigationId: '',
            pageUrl: RouterUrl.WEB_PAGE_URL,
            param: {
              url: '',
              title: '测试标题'
            }
          })
        })
    }
    .height('100%')
    .width('100%')
  }
}