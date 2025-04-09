import { Memory } from '../entities/Memory'
import {Logger} from '../utils/Logger'
import memoryManager from '../database/memory/MemoryManager'
import repetitionManager from '../database/repetition/RepetitionManager'
import { router } from '@kit.ArkUI';
import { LARGE_GRID, RED_BORDER } from './utils/Constants';
import { Repetition } from '../entities/Repetition';

const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)


const sample1= new Memory()
sample1.ID = 4
sample1.NAME = 'less happy'
sample1.DATE = 1743686500
sample1.DESCRIPTION = "a tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smell"
sample1.IS_ENABLED = true
sample1.IMAGES = ["file://media/Photo/4895/IMG_1742799186_4364/IMG_20250324_145126.jpg", "file://media/Photo/4894/IMG_1742799051_4363/IMG_20250324_144911.jpg"]

@Entry
@Component
struct DeletePage{
  @State memory: Memory | undefined= undefined
  @State repetition : Repetition | undefined = undefined

  async onPageShow(): Promise<void> {
    const params = router.getParams() as Record<string, string | number | object>;

    if (params) {
      this.memory = JSON.parse(params['memory'] as string);
      if (this.memory) {
        this.repetition = (await repetitionManager.getRepetitionByMemoryId(this.memory.ID))[0] // Deserialize if needed
      }
      if(this.repetition){

      }
    }
  }
  build(){
    Stack(){
      if(!this.memory){
        Text("Fatal Error: Memory is undefined")
          .fontSize('32fp')
          .fontWeight('bold')
          .textAlign(TextAlign.Center)
          .padding({ top: '10vp', bottom: '10vp' })
      }

      if(this.memory) {
        Button($r('app.string.common_button_delete'))
          .buttonStyle(ButtonStyleMode.EMPHASIZED)
          .fontColor(Color.Red)
          .position({ left: '15vp', bottom: '15vp' })
          .onClick(async () => {
            if (this.memory) {
              await memoryManager.delete(this.memory.ID)
              router.pushUrl({
                url: 'pages/Management'
              })
            }
          })
          .zIndex(999)
      }


      Scroll(){
        GridRow(){
          GridCol(){
            Text(this.memory?.NAME)
              .fontSize('32fp')
              .fontWeight('bold')
              .textAlign(TextAlign.Center)
              .padding({ top: '10vp', bottom: '10vp' })
          }.span(LARGE_GRID).border(RED_BORDER)

          GridCol(){
            Text(this.memory?.DESCRIPTION)
              .fontSize('18fp')
              .lineHeight('24fp')
              .textAlign(TextAlign.Start)
              .padding({ top: '5vp', bottom: '10vp' })
          }.span(LARGE_GRID).border(RED_BORDER)

          GridCol(){
            Text(`Reviewed ${this.repetition?.TIMES_REVIEWED} times, `
              +`last reviewed at `
              +`${new Date(this.repetition?.LAST_VIEWED_TIMESTAMP).toString()}, `
              +`next review is at ${new Date(this.repetition?.NEXT_REVIEWED_TIMESTAMP).toString()}, `
              +`${this.repetition?.NEXT_REVIEWED_TIMESTAMP}`)
              .fontSize('18fp')
              .lineHeight('24fp')
              .textAlign(TextAlign.Start)
              .padding({ top: '5vp', bottom: '10vp' })
          }.span(LARGE_GRID).border(RED_BORDER)

          ForEach(this.memory?.IMAGES, (image:string)=>{
            GridCol(){
              Image(image)
            }.span(LARGE_GRID).border(RED_BORDER)
          }, (image:string)=>image)
        }
      }
    }.height("100%")
    .alignContent(Alignment.TopStart)
  }
}