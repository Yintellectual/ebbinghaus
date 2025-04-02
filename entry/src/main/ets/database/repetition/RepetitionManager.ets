import { relationalStore} from '@kit.ArkData'; // 导入模块
import { Context } from '@ohos.arkui.UIContext';
import {Memory} from '../../entities/Memory'
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {Logger} from '../../utils/Logger'
import rdbStoreProvider from '../../database/RdbStoreProvider'
import {DB_NAME} from '../../database/RdbStoreProvider'
import {MEMORY_TABLE} from '../../database/memory/MemoryManager'
import {Repetition} from '../../entities/Repetition'
const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)

export const REPETITION_TABLE = 'REPETITION'

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
  public async init(){
    this.rdbStore = rdbStoreProvider.getRdbStore()
    logger.log(`Succeeded in getting RdbStore::${DB_NAME}`)
    try{
      await this.rdbStore.executeSql(
        `CREATE TABLE IF NOT EXISTS ${REPETITION_TABLE} (
          memory_id INTEGER PRIMARY KEY,
          last_viewed_timestamp INTEGER,
          times_reviewed INTEGER DEFAULT 0,
          next_review_timestamp INTEGER,
          is_activated INTEGER NOT NULL DEFAULT 1
          FOREIGN KEY (memory_id) REFERENCES ${MEMORY_TABLE}(ID) ON DELETE CASCADE
        )`);
      await this.rdbStore.executeSql(
        `CREATE INDEX IF NOT EXISTS IDX_REPETITION_NEXT_REVIEW
          ON ${REPETITION_TABLE}(next_review_timestamp)`
      )

      logger.log(`Succeeded in initializing RepetitionManager`)
    } catch (err) {
      logger.log("Database init failed:", err)
    }
  }

  public async add_repetition(repetition: Repetition){

  }

}

export default RepetitionManager.getInstance()