import { relationalStore} from '@kit.ArkData'; // 导入模块
import { Context } from '@ohos.arkui.UIContext';

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
const DOMAIN = 0x0000;
const TAG = "rdb"
const FORMAT = '%{public}s'
function log(message:string, err?:BusinessError){
  if(err){
    hilog.error(DOMAIN, TAG, FORMAT, `Code: ${err.code}, Message:${message},\n${err.message}`)
  }else{
    hilog.info(DOMAIN, TAG, FORMAT, `Message:${message}`)
  }
}

const STORE_CONFIG :relationalStore.StoreConfig= {
  name: 'Memory.db', // 数据库文件名
  securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
  encrypt: false, // 可选参数，指定数据库是否加密，默认不加密
  isReadOnly: false // 可选参数，指定数据库是否以只读方式打开。该参数默认为false，表示数据库可读可写。该参数为true时，只允许从数据库读取数据，不允许对数据库进行写操作，否则会返回错误码801。
};

export class MemoryManager{
  private static instance: MemoryManager |null = null
  public static getInstance(): MemoryManager{
    if (!MemoryManager.instance){
      MemoryManager.instance = new MemoryManager()
    }
    return MemoryManager.instance
  }
  private constructor() {
  }
  public init(context: Context){
     relationalStore.getRdbStore(context, STORE_CONFIG, (err, store)=>{
       if(err){
         log("", err)
         return
       }
       log("Succeeded in getting RdbStore")

     })
  }

}