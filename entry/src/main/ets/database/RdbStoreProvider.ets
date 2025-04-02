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

  public destroy(context: Context){
    relationalStore.deleteRdbStore(context, DB_NAME, (err: BusinessError) => {
      if (err) {
        log(`Failed to delete RdbStore:${DB_NAME}`, err);
        return;
      }
      log(`Succeeded in deleting RdbStore:${DB_NAME}`);
    });
  }

  /**
   * Creates query predicates for records within a specified date range, sorted chronologically
   * @param startTimestamp - Inclusive start of date range (UTC timestamp in milliseconds)
   * @param endTimestamp - Inclusive end of date range (UTC timestamp in milliseconds)
   * @returns Configured RdbPredicates with date filtering and ascending sort order
   */
  public createDateRangePredicates(table: string, field: string, startTimestamp: number, endTimestamp: number): relationalStore.RdbPredicates {
    return new relationalStore.RdbPredicates(table)
      .between(field, startTimestamp, endTimestamp)
      .orderByAsc(field);
  }

  /**
   * Creates a paginated query predicate for the memory table
   * @param limit - Maximum number of items per page
   * @param page - Zero-based page index (0 = first page)
   * @returns Configured RdbPredicates with pagination clauses
   */
  public createPaginationPredicates(table:string, limit: number, page: number): relationalStore.RdbPredicates {
    const basePredicates = new relationalStore.RdbPredicates(table);
    return this.applyPaginationClauses(basePredicates, limit, page);
  }

  /**
   * Applies pagination parameters to an existing RdbPredicates query
   * @param predicates - Existing predicate to enhance with pagination
   * @param limit - Maximum number of items to return
   * @param page - Zero-based page index (page 0 = first results)
   * @returns Modified RdbPredicates with limit/offset clauses
   */
  public applyPaginationClauses(
    predicates: relationalStore.RdbPredicates,
    limit: number,
    page: number
  ): relationalStore.RdbPredicates {
    const offset = page * limit;
    return predicates.limitAs(limit).offsetAs(offset);
  }
}

export default RdbStoreProvider.getInstance()