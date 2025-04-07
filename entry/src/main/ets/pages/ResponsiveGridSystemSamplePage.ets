import {image} from '@kit.ImageKit'
import GridColColumnOption from '@kit.UIDesignKit'
import { LARGE_GRID } from './utils/Constants'

const URI = "file://media/Photo/4933/IMG_1743007174_4389/screenshot_20250327_003754.png"


@Entry
@Component
struct ExamplePage {
  @State message :string = "Message"
  @State isOn : boolean = false
  @State progress: number = 0
  private items:string[] = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K']
  build() {
    //experience Text, Button, TextInput, Image, Toggle, Progress
    Scroll(){
      GridRow(){
        GridCol(){
          Text("sample code")
        }
        .span(LARGE_GRID)
        .backgroundColor(Color.Gray)
        .height('80%')
        GridCol(){
          Text("sample code")
        }
        .span(LARGE_GRID)
        .backgroundColor(Color.Yellow)
        .height('80%')
        GridCol(){
          Text("sample code")
        }
        .height('80%')
        .span(LARGE_GRID)
        .backgroundColor(Color.Green)
      }
      .borderWidth('5 vp')
      .borderColor(Color.Red)
    }
  }
}
