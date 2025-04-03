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
          is_activated INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (memory_id) REFERENCES ${MEMORY_TABLE}(ID) ON DELETE CASCADE
        )`);
      logger.log(`Succeeded in initializing ${REPETITION_TABLE}`)
      await this.rdbStore.executeSql(
        `CREATE INDEX IF NOT EXISTS IDX_REPETITION_NEXT_REVIEW
          ON ${REPETITION_TABLE}(next_review_timestamp)`
      )
      logger.log(`Succeeded in initializing RepetitionManager`)
    } catch (err) {
      logger.log("Database init failed:", err)
    }
  }

  public async add_repetition(repetition: Repetition): Promise<number>{
    if (!this.rdbStore){
      logger.log('rdbStore not found')
      return -1
    }
    const valueBucket: relationalStore.ValuesBucket = {
      'memory_id': repetition.MEMORY_ID,
      'last_viewed_timestamp': repetition.LAST_VIEWED_TIMESTAMP,
      'times_reviewed': repetition.TIMES_REVIEWED,
      'next_review_timestamp': repetition.NEXT_REVIEWED_TIMESTAMP,
      'is_activated': repetition.IS_ACTIVATED ? 1 : 0
    };
    try{
      await this.rdbStore.beginTransaction()
      const memory_id = await this.rdbStore.insert(REPETITION_TABLE, valueBucket);
      await this.rdbStore.commit();
      logger.log(`Successfully inserted repetition with id: ${memory_id}}`)
      return memory_id
    }catch (err) {
      logger.log(`add_repetition failed`, err);
      return -1;
    }
  }
  public async add_repetition_by_memory_id(memory_id: number){
    let repetition: Repetition = new Repetition(memory_id)
    return this.add_repetition(repetition)
  }
  public async getRepetitions(predicates:relationalStore.RdbPredicates): Promise<Repetition[]>{
    if (!this.rdbStore) return [];

    try{
      const repetitions: Repetition[] = [];
      const resultSet = await this.rdbStore.query(predicates,
        ['memory_id', 'last_viewed_timestamp', 'times_reviewed', 'next_review_timestamp', 'is_activated']);

      while (resultSet.goToNextRow()) {


        let memory_id = resultSet.getDouble(resultSet.getColumnIndex('memory_id'));
        let repetition = new Repetition(memory_id)
        repetition.LAST_VIEWED_TIMESTAMP = resultSet.getDouble(resultSet.getColumnIndex('last_viewed_timestamp'));
        repetition.TIMES_REVIEWED = resultSet.getDouble(resultSet.getColumnIndex('times_reviewed'));
        repetition.NEXT_REVIEWED_TIMESTAMP = resultSet.getDouble(resultSet.getColumnIndex('next_review_timestamp'));
        repetition.IS_ACTIVATED = resultSet.getDouble(resultSet.getColumnIndex('is_activated')) === 1;

        repetitions.push(repetition);
        logger.log(`${repetition}`)
      }
      resultSet.close()
      logger.log(`Found ${repetitions.length} repetitions`)
      return repetitions
    } catch (err) {
      logger.log(`Query failed: ${(err as BusinessError).message}`, err);
      return [];
    }
  }
  public getTomorrowMidnightTimestamp(currentTimestamp: number): number {
    const today = new Date(currentTimestamp);

    // Create a Date object for tomorrow at 00:00:00 in local time
    const tomorrowMidnight = new Date(
      today.getFullYear(),
      today.getMonth(),
      today.getDate() + 1, // Add 1 day
      0,  // Hours = 0 (midnight)
      0,  // Minutes = 0
      0,  // Seconds = 0
      0   // Milliseconds = 0
    );

    return tomorrowMidnight.getTime();
  }

  public async getRepetitionsToReview(currentTimestamp: number, size: number){
    let tomorrowMidnight : number = this.getTomorrowMidnightTimestamp(currentTimestamp)
    let predicate : relationalStore.RdbPredicates = rdbStoreProvider.createDateRangePredicates(REPETITION_TABLE, 'next_review_timestamp', 0, tomorrowMidnight)
    predicate.orderByAsc('times_reviewed').orderByDesc('next_review_timestamp')
    predicate = rdbStoreProvider.applyPaginationClauses(predicate, size, 0)

    return this.getRepetitions(predicate)
  }
}

export default RepetitionManager.getInstance()