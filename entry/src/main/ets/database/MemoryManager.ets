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


const DB_NAME = 'memories.db';
const MEMORY_TABLE = 'MEMORY';
const IMAGE_TABLE = 'MEMORY_IMAGE';

const STORE_CONFIG :relationalStore.StoreConfig= {
  name: DB_NAME, // 数据库文件名
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
  private rdbStore: relationalStore.RdbStore | null = null
  public async init(context: Context){
    try {
      this.rdbStore = await relationalStore.getRdbStore(context, STORE_CONFIG);

      await this.rdbStore.executeSql(
        `CREATE TABLE IF NOT EXISTS ${MEMORY_TABLE} (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          NAME TEXT NOT NULL,
          DATE INTEGER,
          DESCRIPTION TEXT,
          IS_ENABLED INTEGER)`
      );

      await this.rdbStore.executeSql(
        `CREATE TABLE IF NOT EXISTS ${IMAGE_TABLE} (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          MEMORY_ID INTEGER,
          IMAGE_URI TEXT)`
      );

      await this.rdbStore.executeSql(
        'CREATE INDEX IF NOT EXISTS IDX_MEMORY_DATE ON MEMORY(DATE)'
      );
      log(`Succeeded in getting RdbStore::${DB_NAME}`)
      log(`RdbStore version == ${this.rdbStore.version}`)
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
      log(`Add memory failed: ${(err as BusinessError).message}`, err);
      return -1;
    }
  }

  /**
   * Creates query predicates for records within a specified date range, sorted chronologically
   * @param startTimestamp - Inclusive start of date range (UTC timestamp in milliseconds)
   * @param endTimestamp - Inclusive end of date range (UTC timestamp in milliseconds)
   * @returns Configured RdbPredicates with date filtering and ascending sort order
   */
  public static createDateRangePredicates(startTimestamp: number, endTimestamp: number): relationalStore.RdbPredicates {
    return new relationalStore.RdbPredicates(MEMORY_TABLE)
      .between('DATE', startTimestamp, endTimestamp)
      .orderByAsc('DATE');
  }

  /**
   * Creates a paginated query predicate for the memory table
   * @param limit - Maximum number of items per page
   * @param page - Zero-based page index (0 = first page)
   * @returns Configured RdbPredicates with pagination clauses
   */
  public static createPaginationPredicates(limit: number, page: number): relationalStore.RdbPredicates {
    const basePredicates = new relationalStore.RdbPredicates(MEMORY_TABLE);
    return MemoryManager.applyPaginationClauses(basePredicates, limit, page);
  }

  /**
   * Applies pagination parameters to an existing RdbPredicates query
   * @param predicates - Existing predicate to enhance with pagination
   * @param limit - Maximum number of items to return
   * @param page - Zero-based page index (page 0 = first results)
   * @returns Modified RdbPredicates with limit/offset clauses
   */
  public static applyPaginationClauses(
    predicates: relationalStore.RdbPredicates,
    limit: number,
    page: number
  ): relationalStore.RdbPredicates {
    const offset = page * limit;
    return predicates.limitAs(limit).offsetAs(offset);
  }

  async getMemories(predicates: relationalStore.RdbPredicates): Promise<Memory[]> {
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

  public destroy(context: Context){
    relationalStore.deleteRdbStore(context, 'RdbTest.db', (err: BusinessError) => {
      if (err) {
        log(`Failed to delete RdbStore:${DB_NAME}`, err);
        return;
      }
      log(`Succeeded in deleting RdbStore:${DB_NAME}`);
    });
  }
}