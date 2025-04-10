import router from '@ohos.router';
import { Memory } from '../entities/Memory';
import {Logger} from '../utils/Logger'
import repetitionManager from '../database/repetition/RepetitionManager'
import { LARGE_GRID } from './utils/Constants';
import { CommonButton } from '../components/CommonButton';
import { common } from '@kit.AbilityKit';

const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)




const sample = new Memory()
sample.ID = 4
sample.NAME = 'happy'
sample.DATE = 1743686500
sample.DESCRIPTION = "a tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smell"
sample.IS_ENABLED = true
sample.IMAGES = ["file://media/Photo/4895/IMG_1742799186_4364/IMG_20250324_145126.jpg", "file://media/Photo/4894/IMG_1742799051_4363/IMG_20250324_144911.jpg"]




@Entry
@Component
struct MemoryDisplayPage {
  private memory: Memory | null = null;
  private context = getContext() as common.UIAbilityContext
  private uris: string[] = []
  aboutToAppear() {
    // Get parameters from the navigation
    const params = router.getParams() as Record<string, string | number | object>;

    if (params) {
      this.memory = JSON.parse(params['memory'] as string); // Deserialize if needed
    }
    if(this.memory){
      this.uris = this.extract_uris(this.memory?.DESCRIPTION)
    }
    // for development
    //this.memory = sample
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
    Scroll() {
      GridRow() {
        //name, make it bigger as title
        GridCol() {
          Text(this.memory?.NAME)
            .fontSize('32fp')
            .fontWeight('bold')
            .textAlign(TextAlign.Center)
            .padding({ top: '10vp', bottom: '10vp' })
        }.span(LARGE_GRID)
        .backgroundColor($r('app.color.background'))
        .border({width:{top:'1vp'}, color:{top:$r('app.color.static')}})

        //description
        if(this.memory?.DESCRIPTION){
          GridCol(){
            Column() {
              ForEach(this.uris, (uri:string)=>{
                Hyperlink(uri)
                  .size({
                    height:'24vp'
                  })
                  .onClick(()=>{
                    this.context.openLink(uri)
                  })
                  .margin({ top: '10vp', bottom: '10vp' })
              }, (uri:string)=>uri)
            }
          }.span(LARGE_GRID)
          .backgroundColor($r('app.color.background'))
          .border({width:{top:'1vp'}, color:{top:$r('app.color.static')}})

          GridCol() {
            Text(this.memory?.DESCRIPTION)
              .fontSize('18fp')
              .lineHeight('24fp')
              .textAlign(TextAlign.Start)
              .padding({ top: '5vp', bottom: '10vp' })
          }.span(LARGE_GRID)
          .backgroundColor($r('app.color.background'))
          .border({width:{top:'1vp'}, color:{top:$r('app.color.static')}})
        }

        //Images
        ForEach(this.memory?.IMAGES, (image: string)=>{
          GridCol(){
            Stack(){
              Image(image)
                .borderRadius('12vp')
                .shadow(ShadowStyle.OUTER_DEFAULT_MD)
                .margin({ bottom: 10 });
            }
          }.span(LARGE_GRID)
          .border({width:{top:'1vp'}, color:{top:$r('app.color.static')}})
        }, (image: string)=>image)

        GridCol() {
          CommonButton({
            label: $r('app.string.memory_button_reviewed')
          })
            .onClick(async ()=>{
              if(this.memory){
                await repetitionManager.review(this.memory.ID)
                router.back()
              }
            })
        }.span(LARGE_GRID)
        .backgroundColor($r('app.color.background'))
        .border({width:{top:'1vp'}, color:{top:$r('app.color.static')}})

      }
    }
  }


}