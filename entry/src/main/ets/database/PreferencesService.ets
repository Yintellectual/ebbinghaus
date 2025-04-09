import { preferences} from '@kit.ArkData'
import { Context } from '@ohos.arkui.UIContext';
import {Logger} from '../utils/Logger'

const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)
class PreferencesService{
  private static instance: PreferencesService |null = null
  public static getInstance(): PreferencesService{
    if (!PreferencesService.instance){
      PreferencesService.instance = new PreferencesService()
    }
    return PreferencesService.instance
  }
  private key_daily_review_limit: string = "daily_review_limit"
  private options: preferences.Options = { name : 'preferences'}
  private preferences_instance : preferences.Preferences | null = null
  private daily_review_limit: number = 10
  constructor() {
  }

  public init(context : Context){
    this.preferences_instance = preferences.getPreferencesSync(context, this.options)
    logger.log(`Preferences init ${this.preferences_instance? "Success":"Failure"}`)
    this.daily_review_limit = this.loadNumericValue(this.key_daily_review_limit)
    this.preferences_instance.on('change', this.observer)
  }

  public updateNumericValue(key:string, value:number){
    this.preferences_instance?.putSync(key, value)
  }
  public loadNumericValue(key:string){
    return this.preferences_instance?.getSync(key, 10) as number
  }
  public flush(){
    this.preferences_instance?.flushSync()
  }
  public updateDailyReviewLimit(daily_review_limit: number){
    this.updateNumericValue(this.key_daily_review_limit, daily_review_limit)
    this.flush()
  }
  public getDailyReviewLimit(){
    return this.daily_review_limit;
  }
  private observer = (key:string) =>{
    this.daily_review_limit = this.loadNumericValue(key)
  }
}

export default PreferencesService.getInstance()

