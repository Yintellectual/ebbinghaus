import {KVManagerSingletonWrapper} from '../database/KVManagerSingletonWrapper'
import {SampleKVService} from '../database/SampleKVService'


import { photoAccessHelper } from '@kit.MediaLibraryKit';
import {fetchMediaExample} from '../media/MediaDataHandler'
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
const DOMAIN = 0x0000;
const TAG = "KVManager"
const FORMAT = '%{public}s'

const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
photoSelectOptions.maxSelectNumber = 5; // 选择媒体文件的最大数目

function pick_pictures(): Promise<Array<string>> {
  const photoViewPicker = new photoAccessHelper.PhotoViewPicker();

  // Return the Promise chain
  return photoViewPicker.select(photoSelectOptions)
    .then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      const uris = photoSelectResult.photoUris;
      hilog.info(DOMAIN, TAG, FORMAT, 'URIs: ' + uris);
      return uris; // Resolve the Promise with URIs
    })
    .catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, FORMAT, `Error: ${err.code}, ${err.message}`);
      throw err as Error
    });
}


@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State uri: string = "";
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
        .onClick(async  () => {
          this.message += "!";
          hilog.info(DOMAIN, TAG, FORMAT, typeof KVManagerSingletonWrapper.getKVManager())
          hilog.info(DOMAIN, TAG, FORMAT, typeof SampleKVService.getInstance())
          SampleKVService.getInstance().put("testkey", this.message)
          SampleKVService.getInstance().get("testkey")
          let uris:Array<string> = await pick_pictures()
          hilog.info(DOMAIN, TAG, FORMAT, "what then?")
          this.uri = uris[0]

        })
        .backgroundColor(Color.Gray)
      Button("Display")
        .onClick(async () =>{
          this.message += "?"
          fetchMediaExample(this.uri)
        })

    }
    .height('100%')
    .width('100%')

  }
}