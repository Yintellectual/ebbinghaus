import { Memory } from '../entities/Memory'
import {Logger} from '../utils/Logger'
import memoryManager from '../database/memory/MemoryManager'
import { router } from '@kit.ArkUI';
import { LARGE_GRID } from './utils/Constants';
import { CommonButton } from '../components/CommonButton';
import preferencesService from '../database/PreferencesService'
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


const sample2= new Memory()
sample2.ID = 5
sample2.NAME = 'happy'
sample2.DATE = 1743686501
sample2.DESCRIPTION = "a tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smell"
sample2.IS_ENABLED = true
sample2.IMAGES = ["file://media/Photo/4895/IMG_1742799186_4364/IMG_20250324_145126.jpg", "file://media/Photo/4894/IMG_1742799051_4363/IMG_20250324_144911.jpg"]


const sample3= new Memory()
sample3.ID = 6
sample3.NAME = 'happier'
sample3.DATE = 1743686502
sample3.DESCRIPTION = "a tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smella tree full of flowers with good smell"
sample3.IS_ENABLED = true
sample3.IMAGES = ["file://media/Photo/4895/IMG_1742799186_4364/IMG_20250324_145126.jpg", "file://media/Photo/4894/IMG_1742799051_4363/IMG_20250324_144911.jpg"]

const samples = [sample1, sample2, sample3]

@Entry
@Component
struct ManagementPage{
  @State memories: Memory[] = []
  @State @Watch('onCount') count:number = 0
  async aboutToAppear(): Promise<void> {
    this.memories = await memoryManager.getMemoriesByDate(0, Date.now())
    this.count = preferencesService.getDailyReviewLimit()
  }
  onCount (){
    preferencesService.updateDailyReviewLimit(this.count)
  }
  build(){
    Scroll(){
      Stack(){
        GridRow(){
          GridCol(){
            Text("Manage Memories")
              .fontSize('24fp')
              .fontColor(Color.White)

          }.span(LARGE_GRID)
          .backgroundColor($r('app.color.static'))
          .border({width:{top:'2vp'}, color:$r('app.color.static')})

          GridCol(){
            Flex({direction: FlexDirection.Column}){
              Text("Daily Review Limit")
                .fontSize('20fp')
                .fontWeight(FontWeight.Bold)
                .alignSelf(ItemAlign.Center)
              Counter(){
                Text(`${this.count}`)
              }
              .onInc(()=>{
                this.count += 1
              })
              .onDec(()=>{
                this.count -= 1
              }).alignSelf(ItemAlign.Center)
              .margin('5vp')
            }
          }.span(LARGE_GRID)
          .backgroundColor($r('app.color.background'))
          .padding({top:'10vp'})
          .border({width:{top:'2vp'}, color:$r('app.color.static')})

          GridCol(){
            Text("Memory List")
              .fontSize('20fp')
              .fontWeight(FontWeight.Bold)
              .alignSelf(ItemAlign.Center)
          }.span(LARGE_GRID)
          .backgroundColor($r('app.color.background'))
          .padding({top:'10vp', bottom:'5vp'})
          .border({width:{top:'2vp'}, color:$r('app.color.static')})

          ForEach(this.memories, (memory:Memory)=>{
            GridCol(){
              Column(){
                Text(memory.NAME)
                  .fontSize('15vp')
                  .fontWeight(FontWeight.Bold)
                Flex({direction: FlexDirection.RowReverse,
                alignItems: ItemAlign.Center}){
                  CommonButton({label:$r('app.string.common_button_details')})
                    .onClick(async ()=>{
                    router.pushUrl({
                      url: 'pages/MemoryDetails',
                      params: {
                        memory: JSON.stringify(memory)
                      }
                    })
                  })
                  Text(new Date(memory.DATE).toLocaleDateString())
                    .textAlign(TextAlign.Center)
                }
              }
            }.span(LARGE_GRID)
            .backgroundColor($r('app.color.dynamic'))
            .border({width:{top:'2vp'}, color:$r('app.color.static')})
          }, (memory:Memory)=> `${memory.ID}`)
        }
      }
    }
  }
}
