import {KVManagerSingletonWrapper} from '../database/KVManagerSingletonWrapper'
import {SampleKVService} from '../database/SampleKVService'
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';


const DOMAIN = 0x0000;
const TAG = "KVManager"
const FORMAT = '%{public}s'

const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
photoSelectOptions.maxSelectNumber = 5; // 选择媒体文件的最大数目

function pick_pictures(): Array<string>{
  let uris: Array<string> = [];
  const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
  photoViewPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
    uris = photoSelectResult.photoUris;
    hilog.info(DOMAIN, TAG, FORMAT, 'photoViewPicker.select to file succeed and uris are:' + uris);
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, FORMAT, `Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
  })
  return uris
}


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
          pick_pictures()
        })
        .backgroundColor(Color.Gray)
    }
    .height('100%')
    .width('100%')

  }
}