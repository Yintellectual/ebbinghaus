import {image} from '@kit.ImageKit'
import GridColColumnOption from '@kit.UIDesignKit'
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {sm2} from '../ebbinghaus/sm_2.py'
import {getTimeInterval} from '../utils/get_time_interval'
import {Logger} from '../utils/Logger'
import { router } from '@kit.ArkUI';
import { Memory } from '../entities/Memory';
import { MemoryManager } from '../database/memory/MemoryManager'
import { MemoryDataSource } from '../database/memory/datasource/MemoryDataSource';

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


  async aboutToAppear(): Promise<void> {
    logger.log(`${sm2()}`)
    let timeInterval = getTimeInterval(1)

    let memories = await MemoryManager.getInstance().getMemories(MemoryManager.createDateRangePredicates(timeInterval.start, timeInterval.end))
    logger.log(`Fetch memories from database, count to ${memories.length}`)
    for (let m of memories){
      this.memoryDataSource.addItem(m)
    }
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

        LazyForEach(this.memoryDataSource, (memory:Memory)=>{
          GridCol(){
            Text(`memory.NAME: ${memory.NAME}}`)
          }
          .span(LARGE_GRID)
          .border({width:'5vp', color:Color.Red})

        })
      }
      .borderWidth('5 vp')
      .borderColor(Color.Red)
    }
  }
}
