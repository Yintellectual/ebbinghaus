@Component
export struct CommonButton{
  @Prop
  label: string | Resource = 'Default Label'
  build(){
    Button(this.label)
      .backgroundColor($r('app.color.static'))
      .fontSize('15vp')
      .fontColor(Color.White)
      .fontWeight(FontWeight.Bold)
      .padding({top:'2vp', bottom:'2vp', left:'15vp', right:'15vp'})
      .margin({top:'2vp', bottom:'2vp', left:'5vp', right:'5vp'})
  }
}
