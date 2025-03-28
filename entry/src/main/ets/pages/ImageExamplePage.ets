import {image} from '@kit.ImageKit'

const URI = "file://media/Photo/4933/IMG_1743007174_4389/screenshot_20250327_003754.png"
@Entry
@Component
struct ExamplePage {
  build() {
    Column() {
      Row() {
        Button() {
          Text('display')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20 })
            .backgroundColor('0D9FFB')
            .width('40%')
            .height('5%')
        }

        Button() {
          Text('Button 2')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 20 })
            .backgroundColor('0D9FFB')
            .width('40%')
            .height('5%')
        }
      }
      Text('Hello, HarmonyOS!')
        .fontSize(50)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 50 })
      Image(URI)
        .width('80%')
        .height('30%')
        .margin({ top: 50 })
    }
    .width('100%')
    .height('100%')
  }
}
