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
import {LOCALE, TIMEZONE, TIMEZONE_OFFSET} from '../../pages/utils/Constants'
import { timezone_to_utc, utc_to_timezone } from '../../utils/TimezoneConversion';

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
    //logger.log(`Succeeded in getting RdbStore::${DB_NAME}`)
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
      //logger.log(`Succeeded in initializing ${REPETITION_TABLE}`)
      await this.rdbStore.executeSql(
        `CREATE INDEX IF NOT EXISTS IDX_REPETITION_NEXT_REVIEW
          ON ${REPETITION_TABLE}(next_review_timestamp)`
      )
      //logger.log(`Succeeded in initializing RepetitionManager`)
    } catch (err) {
      //logger.log("Database init failed:", err)
    }
  }

  public async add_repetition(repetition: Repetition): Promise<number>{
    if (!this.rdbStore){
      //logger.log('rdbStore not found')
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
      //logger.log(`Successfully inserted repetition with id: ${memory_id}}`)
      return memory_id
    }catch (err) {
      //logger.log(`add_repetition failed`, err);
      return -1;
    }
  }
  public async add_repetition_by_memory_id(memory_id: number){
    let repetition: Repetition = new Repetition(memory_id)
    return this.add_repetition(repetition)
  }
  public async getRepetitions(predicates:relationalStore.RdbPredicates | string ): Promise<Repetition[]>{
    if (!this.rdbStore) return [];

    try{
      const repetitions: Repetition[] = [];
      let resultSet: relationalStore.ResultSet | null = null
      if(predicates instanceof relationalStore.RdbPredicates){
        resultSet = await this.rdbStore.query(predicates,
          ['memory_id', 'last_viewed_timestamp', 'times_reviewed', 'next_review_timestamp', 'is_activated']);
      }else{
        resultSet = this.rdbStore.querySqlSync(predicates)
      }

      while (resultSet.goToNextRow()) {
        let memory_id = resultSet.getDouble(resultSet.getColumnIndex('memory_id'));
        let repetition = new Repetition(memory_id)
        repetition.LAST_VIEWED_TIMESTAMP = resultSet.getDouble(resultSet.getColumnIndex('last_viewed_timestamp'));
        repetition.TIMES_REVIEWED = resultSet.getDouble(resultSet.getColumnIndex('times_reviewed'));
        repetition.NEXT_REVIEWED_TIMESTAMP = resultSet.getDouble(resultSet.getColumnIndex('next_review_timestamp'));
        repetition.IS_ACTIVATED = resultSet.getDouble(resultSet.getColumnIndex('is_activated')) === 1;

        repetitions.push(repetition);
        //logger.log(`${repetition}`)
      }
      resultSet.close()
      //logger.log(`Found ${repetitions.length} repetitions`)
      return repetitions
    } catch (err) {
      //logger.log(`Query failed: ${(err as BusinessError).message}`, err);
      return [];
    }
  }
  public getTomorrowMidnightTimestamp(current_utc: number): number {
    const current_local = new Date(utc_to_timezone(TIMEZONE_OFFSET, current_utc))
    current_local.setUTCMilliseconds(0)
    current_local.setUTCSeconds(0)
    current_local.setUTCMinutes(0)
    current_local.setUTCHours(0)
    const midnight_local = current_local
    const tomorrow_midnight_local = midnight_local.getTime() + 24*60*60*1000
    //logger.log(`tomorrow_midnight_local = ${new Date(tomorrow_midnight_local).toISOString()}`)
    let tomorrow_midnight_local_utc = timezone_to_utc(TIMEZONE_OFFSET, tomorrow_midnight_local);
    return tomorrow_midnight_local_utc
  }

  public async getRepetitionsToReview(currentTimestamp: number, size: number){
    let tomorrowMidnight : number
      = this.getTomorrowMidnightTimestamp(currentTimestamp)
    //logger.log(`currentTimestamp = ${new Date(currentTimestamp).toISOString()}`)
    //logger.log(`tomorrowMidNight = ${new Date(tomorrowMidnight).toISOString()}, ${tomorrowMidnight}`)

    //let predicate : relationalStore.RdbPredicates = rdbStoreProvider.createDateRangePredicates(REPETITION_TABLE, 'next_review_timestamp', 0, tomorrowMidnight)
    //This line of code equals to predicate.orderByDesc('next_review_timestamp')
    //predicate.orderByAsc('times_reviewed').orderByDesc('next_review_timestamp')
    //predicate = rdbStoreProvider.applyPaginationClauses(predicate, size, 0)
    //return this.getRepetitions(predicate)
    let query = `SELECT * from ${REPETITION_TABLE} ORDER BY ${'times_reviewed'} Asc, ${'next_review_timestamp'} Desc LIMIT ${size} OFFSET ${0};`
    return this.getRepetitions(query)
  }
  public async review(memory_id: number){
    if (!this.rdbStore){
      //logger.log('rdbStore not found')
      return
    }
    let repetitions = await this.getRepetitions(new relationalStore.RdbPredicates(REPETITION_TABLE).in('memory_id', [memory_id]))
    let repetition = repetitions[0]
    repetition.review()
    const valueBucket: relationalStore.ValuesBucket = {
      'memory_id': repetition.MEMORY_ID,
      'last_viewed_timestamp': repetition.LAST_VIEWED_TIMESTAMP,
      'times_reviewed': repetition.TIMES_REVIEWED,
      'next_review_timestamp': repetition.NEXT_REVIEWED_TIMESTAMP,
      'is_activated': repetition.IS_ACTIVATED ? 1 : 0
    };
    await this.rdbStore.beginTransaction()
    await this.rdbStore.update(valueBucket, new relationalStore.RdbPredicates(REPETITION_TABLE).in('memory_id', [memory_id]));
    await this.rdbStore.commit();
  }
  public async getRepetitionByMemoryId(memory_id:number){
    return this.getRepetitions(new relationalStore.RdbPredicates(REPETITION_TABLE).in('memory_id', [memory_id]))
  }
  public async delete(memory_id:number){
    let predicate: relationalStore.RdbPredicates = new relationalStore.RdbPredicates(REPETITION_TABLE)
    predicate.in('memory_id', [memory_id])
    await this.rdbStore?.delete(predicate)
  }
}

export default RepetitionManager.getInstance()