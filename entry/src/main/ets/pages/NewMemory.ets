import {image} from '@kit.ImageKit'
import GridColColumnOption from '@kit.UIDesignKit'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {Logger} from '../utils/Logger'
import { router } from '@kit.ArkUI';
import memoryManager from '../database/memory/MemoryManager';
import repetitionManager from '../database/repetition/RepetitionManager'
import {Memory} from '../entities/Memory'
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { LARGE_GRID } from './utils/Constants';
import { CommonButton } from '../components/CommonButton';

const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)

const URI = "file://media/Photo/4933/IMG_1743007174_4389/screenshot_20250327_003754.png"


const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
photoSelectOptions.maxSelectNumber = 999; // 选择媒体文件的最大数目
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
struct ExamplePage {
  @State name :string = ""
  @State description: string = ""
  @State isEnabled : boolean = true
  @State images : Array<string> =[]

  private items:string[] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K']
  build() {
    //experience Text, Button, TextInput, Image, Toggle, Progress
    Scroll(){
      GridRow(){
        GridCol(){
          TextInput({ text: this.name, placeholder: 'Enter memory name' })
            .margin('5vp')
            .type(InputType.Normal)
            .onChange((value: string) => {
              this.name = value
            })
            .border({ width: 1, color: Color.Gray })
        }.span(LARGE_GRID)
        .border({width:{top:'1vp'}, color:{top:Color.Gray}})
        GridCol(){
          TextInput({ text: this.description, placeholder: 'Enter description' })
            .margin('5vp')
            .type(InputType.Normal)
            .onChange((value: string) => {
              this.description = value
            })
            .border({ width: 1, color: Color.Gray })
        }.span(LARGE_GRID)
        .border({width:{top:'1vp'}, color:{top:Color.Gray}})
        GridCol(){
          CommonButton({
            label: $r('app.string.common_button_pick_images')
          })
            .onClick(async ()=>{
              this.images = this.images.concat(await pick_pictures())
              //logger.log(`this.images, ${this.images} : ${this.images.length}  `)
            })
        }.span(LARGE_GRID)
        .border({width:{top:'1vp'}, color:{top:Color.Gray}})
        GridCol() {
          CommonButton({
            label: $r('app.string.common_button_submit')
          })
            .onClick(async () => {
              let memory: Memory = new Memory()
              memory.NAME = this.name
              memory.DATE = Date.now()
              memory.DESCRIPTION = this.description
              memory.IS_ENABLED = this.isEnabled
              memory.IMAGES = this.images
              logger.log(`Submit: ${memory}`)
              let memory_id = await memoryManager.addMemory(memory)
              if (memory_id != -1 ){
                await repetitionManager.add_repetition_by_memory_id(memory_id)
                router.back()
              }
              //Alert Error
            })
        }
        .span(LARGE_GRID)
        .backgroundColor(Color.Gray)
        ForEach(this.images, (image: string)=>{
          GridCol(){
            Stack(){
              Image(image)
              // Close button (cross) at top-right corner
              Text(' × ') // You can also use an SVG/PNG icon
                .fontSize('24fp')
                .fontColor(Color.White)
                .backgroundColor(Color.Red)
                .borderRadius('24vp')
                .position({ x: '10vp', y: '10vp' }) // Adjust position as needed
                .onClick(() => {
                  this.images = this.images.filter(i => i !== image)
                })
            }
          }.span(LARGE_GRID)
          .backgroundColor(Color.Gray)
          .border({width:{top:'5vp'}, color:{top:Color.Red}})
        }, (image: string)=>image)
      }
    }
  }
}
