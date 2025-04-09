import { Memory } from '../entities/Memory'
import {Logger} from '../utils/Logger'
import memoryManager from '../database/memory/MemoryManager'
import repetitionManager from '../database/repetition/RepetitionManager'
import { router } from '@kit.ArkUI';
import { LARGE_GRID, RED_BORDER } from './utils/Constants';
import { Repetition } from '../entities/Repetition';
import { CommonButton } from '../components/CommonButton';

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
  @State delete_lock: boolean = false
  @State @Watch('routeToManagement') isDeleted: boolean = false
  routeToManagement(){
    if(this.isDeleted) {
      router.pushUrl({
        url: 'pages/Management'
      })
    }
  }
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

      CommonButton({
        label: $r('app.string.common_button_delete')
      }).position({left:'15vp', bottom:'15vp'})
        .onClick(()=>{
          this.delete_lock = !this.delete_lock
        })
        .zIndex(999)
      if(this.memory && this.delete_lock) {
        Button($r('app.string.common_button_delete'))
          .buttonStyle(ButtonStyleMode.EMPHASIZED)
          .fontColor(Color.Red)
          .position({ right: '15vp', bottom: '15vp' })
          .onClick(async () => {
            if (this.memory) {
              await memoryManager.delete(this.memory.ID)
              await repetitionManager.delete(this.memory.ID)
              this.isDeleted = true
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
          }.span(LARGE_GRID)
          .border({width:{top:'2vp'}, color: $r('app.color.static')})
          .backgroundColor($r('app.color.background'))
          if(this.memory?.DESCRIPTION) {
            GridCol() {
              Text(this.memory?.DESCRIPTION)
                .fontSize('18fp')
                .lineHeight('24fp')
                .textAlign(TextAlign.Start)
                .padding({ top: '5vp', bottom: '10vp' })
            }.span(LARGE_GRID)
            .border({width:{top:'2vp'}, color: $r('app.color.static')})
            .backgroundColor($r('app.color.background'))
          }



          GridCol(){
            GridRow(){
              GridCol(){
                Text('Reviewed Times')
                  .fontSize('15fp')
                  .lineHeight('24fp')
                  .textAlign(TextAlign.End)
                  .padding({ top: '5vp', bottom: '10vp' })
              }.span(6)
              GridCol(){
                Text(`${this.repetition?.TIMES_REVIEWED}`)
                  .fontSize('15fp')
                  .lineHeight('24fp')
                  .padding({ top: '5vp', bottom: '10vp' })
              }.span(6)
              GridCol(){
                Text(`last reviewed at`)
                  .fontSize('15fp')
                  .lineHeight('24fp')
                  .padding({ top: '5vp', bottom: '10vp' })
              }.span(6)
              GridCol(){
                Text(`${new Date(this.repetition?.LAST_VIEWED_TIMESTAMP).toLocaleString()}`)
                  .fontSize('15fp')
                  .lineHeight('24fp')
                  .textAlign(TextAlign.Start)
                  .padding({ top: '5vp', bottom: '10vp' })
              }.span(6)
              GridCol(){
                Text(`next review is at`)
                  .fontSize('15fp')
                  .lineHeight('24fp')
                  .padding({ top: '5vp', bottom: '10vp' })
              }.span(6)
              GridCol(){
                Text(`${new Date(this.repetition?.NEXT_REVIEWED_TIMESTAMP).toLocaleString()}`)
                  .fontSize('15fp')
                  .lineHeight('24fp')
                  .textAlign(TextAlign.Start)
                  .padding({ top: '5vp', bottom: '10vp' })
              }.span(6)
            }.width('100%')
          }.span(LARGE_GRID)
          .border({width:{top:'2vp'}, color: $r('app.color.static')})
          .backgroundColor($r('app.color.background'))



          ForEach(this.memory?.IMAGES, (image:string)=>{
            GridCol(){
              Image(image)
            }.span(LARGE_GRID)
            .border({width:{top:'2vp'}, color: $r('app.color.static')})
            .backgroundColor($r('app.color.background'))

          }, (image:string)=>image)
        }
      }
    }.height("100%")
    .alignContent(Alignment.TopStart)
  }
}