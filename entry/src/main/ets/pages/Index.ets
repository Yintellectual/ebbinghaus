import {image} from '@kit.ImageKit'
import GridColColumnOption from '@kit.UIDesignKit'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {getTimeInterval} from '../utils/get_time_interval'
import { router } from '@kit.ArkUI';
import { Memory } from '../entities/Memory';
import {LARGE_GRID} from './utils/Constants'
import memoryManager from '../database/memory/MemoryManager';
import { MemoryDataSource } from '../database/memory/datasource/MemoryDataSource';
import repetitionManager from '../database/repetition/RepetitionManager'
import { Repetition } from '../entities/Repetition';
import { HashMap } from '@kit.ArkTS';
import {Logger} from '../utils/Logger'
const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)

const URI = "file://media/Photo/4933/IMG_1743007174_4389/screenshot_20250327_003754.png"





@Entry
@Component
struct ExamplePage {
  @State message :string = "Message"
  @State isOn : boolean = false
  @State progress: number = 0
  private items:string[] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K']
  private memoryDataSource : MemoryDataSource = new MemoryDataSource([])
  @State @Watch('onRepetitionUpdated') repetitions : Repetition[] = []
  @State isDailyReviewSuccessful: boolean = false
  onRepetitionUpdated(){
    logger.log(`watch callback function is triggered, boolean = ${this.repetitions.length === 0}`)
    this.isDailyReviewSuccessful =  this.repetitions.length === 0
  }
  @State test_timestamp : number = Date.now()
  private memories: HashMap<number, Memory> = new HashMap()
  @State isDataLoaded: boolean = false
  async onPageShow(): Promise<void> {
    //let timeInterval = getTimeInterval(0)
    //let memories = await memoryManager.getMemoriesByDate(timeInterval.start, timeInterval.end)

    //logger.log(`Fetch memories from database, count to ${memories.length}`)
    //for (let m of memories){
    //  this.memoryDataSource.addItem(m)
    //}
    this.repetitions = await repetitionManager.getRepetitionsToReview(this.test_timestamp, 5)
    logger.log(`get repetitions count to ${this.repetitions.length}`)
    let ms: Memory[] = await memoryManager.getMemoriesByID(this.repetitions.map(r => r.MEMORY_ID))
    this.memories = new HashMap()
    ms.forEach((m, i,a)=>{
      this.memories.set(m.ID, m)
    })
    this.isDataLoaded = true;
  }

  build() {
    //experience Text, Button, TextInput, Image, Toggle, Progress
    Stack() {
      Button("Test Date +1")
        .backgroundColor($r('app.color.static'))
        .margin({ top: '5vp', bottom: '5vp' })
        .onClick(() => {
          logger.log('test date +1')
          this.test_timestamp += 1000 * 60 * 60 * 24
          this.onPageShow()
        }).zIndex(999)
        .position({ bottom: '15vp', left: '15vp' })
      Text(`${new Date(this.test_timestamp).toLocaleDateString()}`)
        .position({ bottom: '40vp', right: '15vp' })
        .onClick(() => {
          this.onPageShow()
        }).zIndex(999)
      Scroll() {
        GridRow() {
          GridCol() {
            Flex({ direction: FlexDirection.RowReverse}){
              Button($r('app.string.index_button_management'))
                .backgroundColor($r('app.color.static'))
                .margin({ top: '5 vp', bottom: '5 vp' })
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/Management'
                  })
                })
              Button($r('app.string.index_button_new_memory'))
                .backgroundColor($r('app.color.static'))
                .margin({ top: '5 vp', bottom: '5 vp' })
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/NewMemory'
                  })
                })
            }
          }
          .span(LARGE_GRID)
          .backgroundColor($r('app.color.background'))

          //new memory button
          GridCol() {

          }
          .span(LARGE_GRID)
          .backgroundColor($r('app.color.background'))

          if(this.isDataLoaded){
            if(!this.isDailyReviewSuccessful){
              ForEach(this.repetitions, (repetition: Repetition) => {
                GridCol() {
                  Text(`${this.memories?.get(repetition.MEMORY_ID)?.NAME}`)
                    .fontSize('20vp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                    .padding({ top: '20vp', bottom: '10vp'})
                    .onClick(() => {
                      router.pushUrl({
                        url: 'pages/Memory',
                        params: {
                          memory: JSON.stringify(this.memories.get(repetition.MEMORY_ID))
                        }
                      })
                    })

                }.span(LARGE_GRID)
                .border({width: {top: '2vp'}, color: $r('app.color.static') })
                .padding({left: '20vp', right:'20vp'})
                .backgroundColor($r('app.color.dynamic'))
              }, (repetition: Repetition) => `${repetition.MEMORY_ID}`)
            }else{
              GridCol() {
                Text($r('app.string.index_celebration_for_daily_review_success'))
                  .fontSize('20vp')
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
                  .padding({ top: '20vp', bottom: '10vp'})
                  .onClick(() => {
                    //maybe some animation for celebration
                    logger.log(`${this.repetitions.length}`)
                  })

              }.span(LARGE_GRID)
              .border({width: {top: '2vp'}, color: $r('app.color.static') })
              .padding({left: '20vp', right:'20vp'})
              .backgroundColor($r('app.color.dynamic'))
            }
          }
        }
        .position({x:0, y:0})
        .width('100%')
        .height('100%')
      }
    }
  }
}
