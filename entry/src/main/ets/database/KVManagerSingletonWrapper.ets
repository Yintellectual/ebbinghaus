import { distributedKVStore} from '@kit.ArkData'
import { BusinessError } from '@kit.BasicServicesKit';

import { hilog } from '@kit.PerformanceAnalysisKit';
const DOMAIN = 0x0000;
const TAG = "KVManager"
const FORMAT = '%{public}s'

export class KVManagerSingletonWrapper{
  private static instance: distributedKVStore.KVManager | null = null;

  // Private constructor to prevent direct instantiation
  private constructor() {}

  // Initialize the KVManager instance (call this ONCE in EntryAbility)
  public static init(context: Context): void {
    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context: context,
      bundleName: 'site.hanchen.ebbinghaus2'
    }
    if (!KVManagerSingletonWrapper.instance) {
      try{
        KVManagerSingletonWrapper.instance = distributedKVStore.createKVManager(kvManagerConfig);
        hilog.info(DOMAIN, TAG, FORMAT, 'Succeeded in creating KVManager.');
      }catch (e) {
        let error = e as BusinessError;
        hilog.error(DOMAIN, TAG, FORMAT, `Failed to create KVManager. Code:${error.code},message:${error.message}`);
      }
    }
  }

  // Get the singleton instance (use this everywhere else)
  public static getKVManager(): distributedKVStore.KVManager {
    if (!KVManagerSingletonWrapper.instance) {
      throw new Error('KVManager not initialized! Call init() first in EntryAbility.');
    }
    return KVManagerSingletonWrapper.instance;
  }
}