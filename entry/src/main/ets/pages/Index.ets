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
  @State repetitions : Repetition[] = []
  @State test_timestamp : number = Date.now()
  private memories: HashMap<number, Memory> = new HashMap()

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

  }

  build() {
    //experience Text, Button, TextInput, Image, Toggle, Progress
    Stack() {
      Button("Test Date +1")
        .margin({ top: '5vp', bottom: '5vp' })
        .onClick(() => {
          logger.log('test date +1')
          this.test_timestamp += 1000 * 60 * 60 * 24
          this.onPageShow()
        })
        .position({bottom:'15vp', left : '15vp'})
        .zIndex(999)
      Text(`${new Date(this.test_timestamp).toLocaleDateString()}`)
        .position({bottom:'40vp', right:'15vp'})
        .onClick(()=>{
          this.onPageShow()
        }).zIndex(999)
      Scroll() {
        GridRow() {
          GridCol() {
            Button("Management")
              .margin({ top: '5 vp', bottom: '5 vp' })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/Management'
                })
              })
          }
          .span(LARGE_GRID)
          .backgroundColor(Color.Gray)

          //new memory button
          GridCol() {
            Button("New Memory")
              .margin({ top: '5 vp', bottom: '5 vp' })
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/NewMemory'
                })
              })
          }
          .span(LARGE_GRID)
          .backgroundColor(Color.Gray)


          ForEach(this.repetitions, (repetition: Repetition) => {
            GridCol() {
              Text(`memory.NAME: ${this.memories?.get(repetition.MEMORY_ID)?.NAME}`)
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/Memory',
                    params: {
                      memory: JSON.stringify(this.memories.get(repetition.MEMORY_ID))
                    }
                  })
                })
            }.span(LARGE_GRID)
            .border({ width: '5vp', color: Color.Red })
          }, (repetition: Repetition) => `${repetition.MEMORY_ID}`)
        }
        .borderWidth('5 vp')
        .borderColor(Color.Red)
        .position({x:0, y:0})
        .width('100%')
        .height('100%')
      }
    }
  }
}
