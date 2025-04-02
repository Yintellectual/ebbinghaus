import {KVManagerSingletonWrapper} from '../database/KVManagerSingletonWrapper'
import {SampleKVService} from '../database/SampleKVService'
import {router} from '@kit.ArkUI'

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import {fetchMediaExample} from '../media/MediaDataHandler'
import { BusinessError } from '@kit.BasicServicesKit';
import memoryManager from '../database/memory/MemoryManager';
import {Memory} from '../entities/Memory'
import { hilog } from '@kit.PerformanceAnalysisKit';
const DOMAIN = 0x0000;
const TAG = "rdb"
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
  @State memory: Memory|null = null
  @State memories: Memory[] = []
  build() {
    RelativeContainer() {
      Button("Display")
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
        })
        .onClick(async () =>{
          this.message += "?"
          fetchMediaExample(this.uri)
          if(this.memory){
            memoryManager.addMemory(this.memory)
          }
          router.pushUrl({
            url: "pages/ResponsiveGridSystemSamplePage"
          })
        })
      Button("Find All")
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(async ()=>{
          if(this.memory){
            this.memories = await memoryManager.getMemoriesByDate(0, Date.now())
            this.message = this.memories.length + ""
          }
        })
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
          hilog.info(DOMAIN, TAG, FORMAT, "what then1?")
          this.memory = new Memory()
          this.memory.NAME = "temp"
          this.memory.DATE = Date.now()
          this.memory.DESCRIPTION = "description"
          hilog.info(DOMAIN, TAG, FORMAT, "what then2?")
          this.memory.IMAGES = uris
          hilog.info(DOMAIN, TAG, FORMAT, "what then?3")
          let id = await memoryManager.addMemory(this.memory)
          hilog.info(DOMAIN, TAG, FORMAT, "id: "+ id)
        })
        .backgroundColor(Color.Gray)
        
    }
    .height('100%')
    .width('100%')

  }
}