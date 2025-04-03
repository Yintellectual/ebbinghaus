import {image} from '@kit.ImageKit'
import GridColColumnOption from '@kit.UIDesignKit'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {getTimeInterval} from '../utils/get_time_interval'
import {Logger} from '../utils/Logger'
import { router } from '@kit.ArkUI';
import { Memory } from '../entities/Memory';

import memoryManager from '../database/memory/MemoryManager';
import { MemoryDataSource } from '../database/memory/datasource/MemoryDataSource';
import repetitionManager from '../database/repetition/RepetitionManager'
import { Repetition } from '../entities/Repetition';
import { HashMap } from '@kit.ArkTS';

const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)

const URI = "file://media/Photo/4933/IMG_1743007174_4389/screenshot_20250327_003754.png"

const MIDDLE_GRID: GridColColumnOption = {xs:12, sm:6, md:4, lg:3, xl:2, xxl:1}
const LARGE_GRID: GridColColumnOption = {xs:12, sm:12, md:6, lg:4, xl:3, xxl:2}



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
  async aboutToAppear(): Promise<void> {
    //let timeInterval = getTimeInterval(0)
    //let memories = await memoryManager.getMemoriesByDate(timeInterval.start, timeInterval.end)


    //logger.log(`Fetch memories from database, count to ${memories.length}`)
    //for (let m of memories){
    //  this.memoryDataSource.addItem(m)
    //}
    this.repetitions = await repetitionManager.getRepetitionsToReview(this.test_timestamp, 5)
    let ms: Memory[] = await memoryManager.getMemoriesByID(this.repetitions.map(r => r.MEMORY_ID))
    this.memories = new HashMap()
    ms.forEach((m, i,a)=>{
      this.memories.set(m.ID, m)
    })

  }

  build() {
    //experience Text, Button, TextInput, Image, Toggle, Progress
    Scroll(){
      GridRow(){
        //new memory button
        GridCol(){
          Button("New Memory")
            .margin({top:'5 vp', bottom: '5 vp'})
            .onClick(()=>{
              router.pushUrl({
                url: 'pages/NewMemory'
              })
            })
        }
        .span(LARGE_GRID)
        .backgroundColor(Color.Gray)
        GridCol(){
          Button("Test Date +1")
            .margin({top:'5 vp', bottom: '5 vp'})
            .onClick(()=>{
              this.test_timestamp += 1000 * 60 * 60 * 24
              this.aboutToAppear()
            })
        }
        .span(LARGE_GRID)
        .backgroundColor(Color.Gray)


        ForEach(this.repetitions, (repetition: Repetition) =>{
          GridCol(){
            Text(`memory.NAME: ${this.memories.get(repetition.MEMORY_ID).NAME}`)
              .onClick(()=>{
                router.pushUrl({
                  url:'pages/Memory',
                  params:{
                    memory: JSON.stringify(this.memories.get(repetition.MEMORY_ID))
                  }
                })
              })
          }.span(LARGE_GRID)
          .border({width:'5vp', color:Color.Red})
        }, (repetition: Repetition) => `${repetition.MEMORY_ID}`)
      }
      .borderWidth('5 vp')
      .borderColor(Color.Red)
    }
  }
}
