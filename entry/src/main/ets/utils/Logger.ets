import { BusinessError } from "@kit.BasicServicesKit"
import { hilog } from '@kit.PerformanceAnalysisKit';
export class Logger{
  domain: number;
  tag: string;
  format: string;

  constructor(domain:number, tag:string, format:string) {
    this.domain = domain
    this.tag = tag
    this.format = format
  }
  public log(message:string, err?:BusinessError){
    if(err){
      hilog.error(this.domain, this.tag, this.format, `${message}\n ${err.code}, ${err.message}`)
    }else{
      hilog.info(this.domain, this.tag, this.format, `${message}`)
    }
  }
}