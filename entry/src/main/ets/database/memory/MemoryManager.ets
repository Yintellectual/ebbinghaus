import { relationalStore} from '@kit.ArkData'; // 导入模块
import { Context } from '@ohos.arkui.UIContext';
import {Memory} from '../../entities/Memory'
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import {Logger} from '../../utils/Logger'
import rdbStoreProvider from '../../database/RdbStoreProvider'
import {DB_NAME} from '../../database/RdbStoreProvider'

const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)

function log(message:string, err?:BusinessError){
  logger.log(message, err)
}

export const MEMORY_TABLE = 'MEMORY';
export const IMAGE_TABLE = 'MEMORY_IMAGE';

class MemoryManager{
  private static instance: MemoryManager |null = null
  public static getInstance(): MemoryManager{
    if (!MemoryManager.instance){
      MemoryManager.instance = new MemoryManager()
    }
    return MemoryManager.instance
  }
  private constructor() {
  }
  private rdbStore: relationalStore.RdbStore | null = null
  public async init(){
    this.rdbStore= rdbStoreProvider.getRdbStore()
    log(`Succeeded in getting RdbStore::${DB_NAME}`)
    try {
      await this.rdbStore.executeSql(
        `CREATE TABLE IF NOT EXISTS ${MEMORY_TABLE} (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          NAME TEXT NOT NULL,
          DATE INTEGER,
          DESCRIPTION TEXT,
          IS_ENABLED INTEGER
          )`
      );
      log(`Succeeded in initializing table::${MEMORY_TABLE}`)
      await this.rdbStore.executeSql(
        `CREATE TABLE IF NOT EXISTS ${IMAGE_TABLE} (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          MEMORY_ID INTEGER,
          IMAGE_URI TEXT)`
      );
      log(`Succeeded in initializing table::${IMAGE_TABLE}`)
      await this.rdbStore.executeSql(
        'CREATE INDEX IF NOT EXISTS IDX_MEMORY_DATE ON MEMORY(DATE)'
      );
      log(`Succeeded in initializing MemoryManager`)
    } catch (err) {
      log("Database init failed:", err)
    }
  }

  public async addMemory(memory: Memory){
    if (!this.rdbStore){
      log('rdbStore not found')
      return -1
    }
    const valueBucket: relationalStore.ValuesBucket = {
      'NAME': memory.NAME,
      'DATE': memory.DATE,
      'DESCRIPTION': memory.DESCRIPTION,
      'IS_ENABLED': memory.IS_ENABLED ? 1 : 0
    };
    try {
      await this.rdbStore.beginTransaction()
      const insertId = await this.rdbStore.insert(MEMORY_TABLE, valueBucket);

      for (const imageUri of memory.IMAGES) {
        const imageBucket: relationalStore.ValuesBucket = {
          'MEMORY_ID': insertId,
          'IMAGE_URI': imageUri
        };
        await this.rdbStore.insert(IMAGE_TABLE, imageBucket);
      }

      await this.rdbStore.commit();
      log(`Successfully inserted memory with id: ${insertId}}`)
      return insertId;
    } catch (err) {
      log(`Add memory failed`, err);
      return -1;
    }
  }

  public async getMemories(predicates: relationalStore.RdbPredicates): Promise<Memory[]> {
    if (!this.rdbStore) return [];

    try {
      const memories: Memory[] = [];
      const resultSet = await this.rdbStore.query(predicates,
        ['ID', 'NAME', 'DATE', 'DESCRIPTION', 'IS_ENABLED']);

      while (resultSet.goToNextRow()) {
        const memory = new Memory()
        memory.ID = resultSet.getDouble(resultSet.getColumnIndex('ID'));
        memory.NAME = resultSet.getString(resultSet.getColumnIndex('NAME'));
        memory.DATE = resultSet.getDouble(resultSet.getColumnIndex('DATE'));
        memory.DESCRIPTION = resultSet.getString(resultSet.getColumnIndex('DESCRIPTION'));
        memory.IS_ENABLED = resultSet.getDouble(resultSet.getColumnIndex('IS_ENABLED')) === 1;


        const imagePredicates = new relationalStore.RdbPredicates(IMAGE_TABLE)
          .equalTo('MEMORY_ID', memory.ID);
        const imageResult = await this.rdbStore.query(imagePredicates, ['IMAGE_URI']);

        while (imageResult.goToNextRow()) {
          memory.IMAGES.push(imageResult.getString(imageResult.getColumnIndex('IMAGE_URI')));
          log(imageResult.getString(imageResult.getColumnIndex('IMAGE_URI')))
        }
        imageResult.close();
        memories.push(memory);
        log(`${memory}`)
      }
      resultSet.close();
      log(`Found ${memories.length} memories`)
      return memories;
    } catch (err) {
      log(`Query failed: ${(err as BusinessError).message}`, err);
      return [];
    }
  }

  public async getMemoriesByDate(start_timestamp: number, end_timestamp: number){
    return this.getMemories(rdbStoreProvider.createDateRangePredicates(MEMORY_TABLE, 'DATE', start_timestamp, end_timestamp))
  }
}



export default MemoryManager.getInstance()
