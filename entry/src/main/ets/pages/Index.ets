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
import { CommonButton } from '../components/CommonButton';
import preferencesService from '../database/PreferencesService'

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
  @State daily_review_limit:number = 10
  onRepetitionUpdated(){
    this.isDailyReviewSuccessful =  this.repetitions.length === 0
  }
  @State test_timestamp : number = Date.now()
  @State memories: HashMap<number, Memory> = new HashMap()
  @State isDataLoaded: boolean = false

  async onPageShow(): Promise<void> {
    //let timeInterval = getTimeInterval(0)
    //let memories = await memoryManager.getMemoriesByDate(timeInterval.start, timeInterval.end)

    //logger.log(`Fetch memories from database, count to ${memories.length}`)
    //for (let m of memories){
    //  this.memoryDataSource.addItem(m)
    //}
    this.daily_review_limit = preferencesService.getDailyReviewLimit()
    this.repetitions = await repetitionManager.getRepetitionsToReview(this.test_timestamp, this.daily_review_limit)


    logger.log(`get repetitions count to ${this.repetitions.length}`)
    let ms: Memory[] = await memoryManager.getMemoriesByID(this.repetitions.map(r => r.MEMORY_ID))
    this.memories = new HashMap()
    ms.forEach((m, i,a)=>{
      this.memories.set(m.ID, m)
    })
    // //empty_trash
    // this.repetitions.forEach((r,i,a)=>{
    //   if(!this.memories.get(r.MEMORY_ID)){
    //     repetitionManager.delete(r.MEMORY_ID)
    //   }
    // })

    this.isDataLoaded = true;
  }

  build() {
    //experience Text, Button, TextInput, Image, Toggle, Progress
    Stack() {
      Column() {
        Flex({ direction: FlexDirection.RowReverse }) {
          //top button
          CommonButton({
            label: $r('app.string.index_button_management')
          })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/Management'
              })
            })
          //top button
          CommonButton({
            label: $r('app.string.index_button_new_memory')
          })
            .onClick(() => {
              router.pushUrl({
                url: 'pages/NewMemory'
              })
            })
        }
        .backgroundColor($r('app.color.background'))

        if (this.isDataLoaded) {
          if (!this.isDailyReviewSuccessful) {
            List() {
              ForEach(this.repetitions, (repetition: Repetition) => {
                ListItem() {
                  Text(`${this.memories?.get(repetition.MEMORY_ID)?.NAME}`)
                    .fontSize('20vp')
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                    .padding({ top: '20vp', bottom: '10vp' })
                }
                .width('100%')
                .border({ width: { top: '2vp' }, color: $r('app.color.static') })
                .padding({ left: '20vp', right: '20vp' })
                .backgroundColor($r('app.color.dynamic'))
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/Memory',
                    params: {
                      memory: JSON.stringify(this.memories.get(repetition.MEMORY_ID))
                    }
                  })
                })
              }, (repetition: Repetition) => `${repetition.MEMORY_ID}`)
            }
          } else {
            Column() {
              Text($r('app.string.index_celebration_for_daily_review_success'))
                .fontSize('20vp')
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .padding({ top: '20vp', bottom: '10vp' })
                .onClick(() => {
                  //maybe some animation for celebration
                  logger.log(`${this.repetitions.length}`)
                })

            }
            .border({ width: { top: '2vp' }, color: $r('app.color.static') })
            .padding({ left: '20vp', right: '20vp' })
            .backgroundColor($r('app.color.dynamic'))
          }
        }
      }
      Flex({direction:FlexDirection.RowReverse, alignItems:ItemAlign.Center}) {
        //bottom button
        CommonButton({
          label: "Test Date +1"
        })
          .onClick(() => {
            logger.log('test date +1')
            this.test_timestamp += 1000 * 60 * 60 * 24
            this.onPageShow()
          })
        //bottom date
        Text(`Test Date:[${new Date(this.test_timestamp).toLocaleDateString()}]`)
          .onClick(() => {
            this.onPageShow()
          }).textAlign(TextAlign.Center)
      }.position({y:'90%'})
    }
  }
}
