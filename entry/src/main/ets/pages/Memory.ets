import router from '@ohos.router';
import { Memory } from '../entities/Memory';
import {Logger} from '../utils/Logger'
import repetitionManager from '../database/repetition/RepetitionManager'
import memoryManager from '../database/memory/MemoryManager'
import { LARGE_GRID } from './utils/Constants';
import { CommonButton } from '../components/CommonButton';
import { common } from '@kit.AbilityKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)


const sample = new Memory()
sample.ID = 4
sample.NAME = 'a tree full of flowers with good smella tree full of flowe'
sample.DATE = 1743686500
sample.DESCRIPTION = "https://example.com, https://exam1ple.com, https://e2xample.com a tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smell"
sample.IS_ENABLED = true
sample.IMAGES = ["file://media/Photo/4895/IMG_1742799186_4364/IMG_20250324_145126.jpg", "file://media/Photo/4894/IMG_1742799051_4363/IMG_20250324_144911.jpg"]

const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
photoSelectOptions.maxSelectNumber = 999; // 选择媒体文件的最大数目

function pick_pictures(): Promise<Array<string>> {
  const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
  // Return the Promise chain
  return photoViewPicker.select(photoSelectOptions)
    .then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
      const uris = photoSelectResult.photoUris;
      return uris; // Resolve the Promise with URIs
    })
    .catch((err: BusinessError) => {
      throw err as Error
    });
}

@Entry
@Component
struct MemoryDisplayPage {
  @State memory: Memory | null = null;
  private context = getContext() as common.UIAbilityContext
  @State name: string = ""
  @State uris: string[] = []
  @State isEdit:boolean = false
  @State images: string[] = []
  @State @Watch('re_extract_uris') description: string | undefined = undefined

  async insertOrUpdateMemory(){

    const mmr = new Memory()
    if(this.memory){
      mmr.ID = this.memory.ID
      mmr.DATE = this.memory.DATE
    }else{
      mmr.DATE = Date.now()
    }
    mmr.NAME = this.name
    mmr.IS_ENABLED = true
    if(this.description){
      mmr.DESCRIPTION = this.description
    }
    mmr.IMAGES = this.images

    if(mmr.ID < 0){
      let memory_id = await memoryManager.insert(mmr)
      await repetitionManager.add_repetition_by_memory_id(memory_id)
    }else{
      memoryManager.updateSync(mmr)
    }

    this.isEdit = false
  }

  aboutToAppear() {
    // Get parameters from the navigation
    const params = router.getParams() as Record<string, string | number | object>;

    if (params) {
      this.memory = JSON.parse(params['memory'] as string); // Deserialize if needed
    }else{
      //dev
      this.memory = sample
    }
    if(this.memory?.IMAGES){
      this.images = this.memory.IMAGES.slice()
    }
    if(this.memory){
      this.name = this.memory.NAME
      if(this.memory.DESCRIPTION){
        this.description = this.memory.DESCRIPTION
      }
      this.uris = this.extract_uris(this.memory?.DESCRIPTION)
    }

    console.log(this.uris.length+"")
    // for development
    //this.memory = sample
  }

  re_extract_uris(){
    if(this.description){
      this.uris = this.extract_uris(this.description)
    }
  }
  private extract_uris(content: string){
    const regex_for_uri = /\b[a-zA-Z][a-zA-Z0-9+.-]*:\/\/[^\/\s?#]+\S*/g
    const matches = content.matchAll(regex_for_uri)
    let uris: string[] = []
    for(const match of matches){
      uris.push(match[0])
    }
    return uris
  }


  build() {
      Column(){
        //name, make it bigger as title
        Row() {
          if(this.isEdit){
            TextInput({ text: this.name})
              .onChange((value)=>{
                this.name = value
              })
              .fontSize('32fp')
              .fontWeight('bold')
              .padding({ top: '10vp', bottom: '10vp' })
          }else {
            Text(this.name)
              .fontSize('32fp')
              .fontWeight('bold')
              .padding({ top: '10vp', bottom: '10vp' })
          }
        }
        .backgroundColor($r('app.color.background'))
        .border({ width: { top: '1vp' }, color: { top: $r('app.color.static') } })
        .width('100%')
        .justifyContent(FlexAlign.Center)
        //uris in description
        if(this.uris) {
          Row() {
            Column() {
              ForEach(this.uris, (uri: string) => {
                Hyperlink(uri)
                  .size({
                    height: '24vp'
                  })
                  .onClick(() => {
                    this.context.openLink(uri)
                  })

              }, (uri: string) => uri)
            }.width('100%')
            .backgroundColor($r('app.color.background'))
            .border({ width: { top: '1vp' }, color: { top: $r('app.color.static') } })
          }
        }
        Row() {
          List() {
            //description
            if(this.description){
              ListItem() {
                if(this.isEdit){
                  TextArea({ text: this.description })
                    .fontSize('18fp')
                    .lineHeight('24fp')
                    .textAlign(TextAlign.Start)
                    .padding({ top: '5vp', bottom: '10vp' })
                    .onChange((value) => {
                      this.description = value
                    })
                }else {
                  if (this.description) {

                    Text(this.description)
                      .fontSize('18fp')
                      .lineHeight('24fp')
                      .textAlign(TextAlign.Start)
                      .padding({ top: '5vp', bottom: '10vp' })
                  }
                }
              }
              .width('100%')
              .padding({left:'5vp', right:'5vp'})
              .backgroundColor($r('app.color.background'))
              .border({ width: { top: '1vp' }, color: { top: $r('app.color.static') } })
            }


            //images
            if (this.images) {
              ForEach(this.images, (image: string) => {
                ListItem() {
                  Stack() {
                    Image(image)
                      .borderRadius('12vp')
                      .shadow(ShadowStyle.OUTER_DEFAULT_MD)
                      .margin({ bottom: 10 });
                    if (this.isEdit) {
                      // Close button (cross) at top-right corner
                      Text(' × ')// You can also use an SVG/PNG icon
                        .fontSize('24fp')
                        .fontColor(Color.White)
                        .backgroundColor(Color.Red)
                        .borderRadius('24vp')
                        .position({ x: '10vp', y: '10vp' })// Adjust position as needed
                        .onClick(() => {
                          this.images = this.images.filter(i => i !== image)
                        })
                    }
                  }
                }
                .border({ width: { top: '1vp' }, color: { top: $r('app.color.static') } })
              }, (image: string) => image)
            }
          }
        }


        //Reviewed button
        Flex({ direction: FlexDirection.RowReverse, alignItems: ItemAlign.Baseline }) {

          CommonButton({
            label: $r('app.string.memory_button_reviewed')
          })
            .onClick(async () => {
              if (this.memory) {
                await repetitionManager.review(this.memory.ID)
                router.back()
              }
            })
          CommonButton({
            label: $r('app.string.common_button_edit')
          }).onClick(() => {
            this.isEdit = !this.isEdit
          })
          if (this.isEdit) {
            CommonButton({
              label: $r('app.string.common_button_submit')
            }).onClick(async ()=>{
              await this.insertOrUpdateMemory()
            })
            CommonButton({
              label: $r('app.string.common_button_pick_images')
            })
              .onClick(async ()=>{
                this.images = this.images.concat(await pick_pictures())
                //logger.log(`this.images, ${this.images} : ${this.images.length}  `)
              })
          }
        }
        .backgroundColor($r('app.color.background'))
        .border({ width: { top: '1vp' }, color: { top: $r('app.color.static') } })
        .position({ y: '90%' })
      }


    }

}