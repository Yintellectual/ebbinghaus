import router from '@ohos.router';
import { Memory } from '../entities/Memory';
import {Logger} from '../utils/Logger'
import repetitionManager from '../database/repetition/RepetitionManager'
const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)
const MIDDLE_GRID: GridColColumnOption = {xs:12, sm:6, md:4, lg:3, xl:2, xxl:1}
const LARGE_GRID: GridColColumnOption = {xs:12, sm:12, md:6, lg:4, xl:3, xxl:2}



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
  aboutToAppear() {
    // Get parameters from the navigation
    const params = router.getParams() as Record<string, string | number | object>;

    if (params) {
      this.memory = JSON.parse(params['memory'] as string); // Deserialize if needed
      logger.log(`${this.memory}`)
      logger.log(`${this.memory?.NAME}`)
    }
    // for development
    //this.memory = sample
  }

  build() {
    Scroll() {
      GridRow() {
        GridCol() {
          Button("Reviewed")
            .onClick(async ()=>{
              if(this.memory){
                await repetitionManager.review(this.memory.ID)
                router.pushUrl({
                  url:'pages/Index'
                })
              }
            })
        }.span(LARGE_GRID)
        .border({width:{top:'1vp'}, color:{top:Color.Gray}})

        //name, make it bigger as title
        GridCol() {
          Text(this.memory?.NAME)
            .fontSize('32fp')
            .fontWeight('bold')
            .textAlign(TextAlign.Center)
            .padding({ top: '10vp', bottom: '10vp' })
        }.span(LARGE_GRID)
        .border({width:{top:'1vp'}, color:{top:Color.Gray}})

        //description
        GridCol() {
          Text(this.memory?.DESCRIPTION)
            .fontSize('18fp')
            .lineHeight('24fp')
            .textAlign(TextAlign.Start)
            .padding({ top: '5vp', bottom: '10vp' })
        }.span(LARGE_GRID)
        .border({width:{top:'1vp'}, color:{top:Color.Gray}})

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
          .backgroundColor(Color.Gray)
          .border({width:{top:'5vp'}, color:{top:Color.Red}})
        }, (image: string)=>image)
      }
    }
  }


}