import { relationalStore} from '@kit.ArkData'; // 导入模块
import { Context } from '@ohos.arkui.UIContext';
import {Memory} from '../entities/Memory'
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {Logger} from '../utils/Logger'

const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)

function log(message:string, err?:BusinessError){
  logger.log(message, err)
}

export const DB_NAME = 'ebbinghaus.db';
export const MEMORY_TABLE = 'MEMORY';
export const IMAGE_TABLE = 'MEMORY_IMAGE';

const STORE_CONFIG :relationalStore.StoreConfig= {
  name: DB_NAME, // 数据库文件名
  securityLevel: relationalStore.SecurityLevel.S1, // 数据库安全级别
  encrypt: false, // 可选参数，指定数据库是否加密，默认不加密
  isReadOnly: false // 可选参数，指定数据库是否以只读方式打开。该参数默认为false，表示数据库可读可写。该参数为true时，只允许从数据库读取数据，不允许对数据库进行写操作，否则会返回错误码801。
};

class RdbStoreProvider{
  private static instance: RdbStoreProvider |null = null
  public static getInstance(): RdbStoreProvider{
    if (!RdbStoreProvider.instance){
      RdbStoreProvider.instance = new RdbStoreProvider()
    }
    return RdbStoreProvider.instance
  }
  private constructor() {
  }
  private rdbStore: relationalStore.RdbStore | null = null
  // Initialize with context (required)
  public async init(context: Context): Promise<void> {
    if (!this.rdbStore) {
      this.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);
    }
  }
  public getRdbStore(): relationalStore.RdbStore {
    if (!this.rdbStore) {
      throw new Error('RDB Store not initialized. Call init() first.');
    }
    return this.rdbStore;
  }
}

export default RdbStoreProvider.getInstance()