import { Memory } from '../entities/Memory'
import {Logger} from '../utils/Logger'
import memoryManager from '../database/memory/MemoryManager'
import { router } from '@kit.ArkUI';
import { LARGE_GRID } from './utils/Constants';
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

  async aboutToAppear(): Promise<void> {
    this.memories = await memoryManager.getMemoriesByDate(0, Date.now())
  }

  build(){
    Scroll(){
      Stack(){
        Flex(){
          CommonButton({
            label:$r('app.string.common_button_home')
          }).onClick(()=>{
            router.pushUrl({
              url: 'pages/Index'
            })
          }).position({right:'10%', bottom:'15%'})
        }.border({
          width: '1 vp',
          color: Color.Red
        })
        .width('100%')
        .height('100%')

        GridRow(){
          ForEach(this.memories, (memory:Memory)=>{
            GridCol(){
              Column(){
                Text(memory.NAME)
                Text(new Date(memory.DATE).toDateString())
                Row(){
                  Button($r('app.string.common_button_delete')).onClick(async ()=>{
                    router.pushUrl({
                      url: 'pages/Delete',
                      params: {
                        memory: JSON.stringify(memory)
                      }
                    })
                  }).buttonStyle(ButtonStyleMode.TEXTUAL).fontColor(Color.Red)
                }
              }
            }.span(LARGE_GRID)
            .border({width:'5vp', color:Color.Red})
          }, (memory:Memory)=> `${memory.ID}`)
        }
      }
    }
  }
}
