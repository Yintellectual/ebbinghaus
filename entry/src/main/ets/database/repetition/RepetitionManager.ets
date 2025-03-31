import { relationalStore} from '@kit.ArkData'; // 导入模块
import { Context } from '@ohos.arkui.UIContext';
import {Memory} from '../../entities/Memory'
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {Logger} from '../../utils/Logger'
import rdbStoreProvider from '../../database/RdbStoreProvider'
import {DB_NAME, MEMORY_TABLE, IMAGE_TABLE} from '../../database/RdbStoreProvider'

const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)

function log(message:string, err?:BusinessError){
  logger.log(message, err)
}


class RepetitionManager{
  private static instance: RepetitionManager |null = null
  public static getInstance(): RepetitionManager{
    if (!RepetitionManager.instance){
      RepetitionManager.instance = new RepetitionManager()
    }
    return RepetitionManager.instance
  }
  private constructor() {
  }
  private rdbStore: relationalStore.RdbStore | null = null

}