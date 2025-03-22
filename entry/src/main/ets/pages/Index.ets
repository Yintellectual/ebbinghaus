import {KVManagerSingletonHolder} from '../entryability/EntryAbility'
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
const DOMAIN = 0x0000;
const TAG = "KVManager"
const FORMAT = '%{public}s'

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  build() {
    RelativeContainer() {
      Text(this.message )
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message += "!";
          hilog.info(DOMAIN, TAG, FORMAT, typeof KVManagerSingletonHolder.kvManager)
        })
        .backgroundColor(Color.Gray)
    }
    .height('100%')
    .width('100%')

  }
}