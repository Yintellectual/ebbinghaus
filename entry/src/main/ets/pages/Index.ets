import {KVManagerSingletonWrapper} from '../database/KVManagerSingletonWrapper'
import {SampleKVService} from '../database/SampleKVService'
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
          hilog.info(DOMAIN, TAG, FORMAT, typeof KVManagerSingletonWrapper.getKVManager())
          hilog.info(DOMAIN, TAG, FORMAT, typeof SampleKVService.getInstance())
          SampleKVService.getInstance().put("testkey", this.message)
          SampleKVService.getInstance().get("testkey")
        })
        .backgroundColor(Color.Gray)
    }
    .height('100%')
    .width('100%')

  }
}