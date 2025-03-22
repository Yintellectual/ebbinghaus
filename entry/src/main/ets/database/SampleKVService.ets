import { KVManagerSingletonWrapper } from "./KVManagerSingletonWrapper";
import { distributedKVStore } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";

import { hilog } from '@kit.PerformanceAnalysisKit';
const DOMAIN = 0x0000;
const TAG = "KVManager"
const FORMAT = '%{public}s'

const options: distributedKVStore.Options ={
  createIfMissing: true,
  encrypt: false,
  backup: false,
  autoSync: false,
  // kvStoreType不填时，默认创建多设备协同数据库
  kvStoreType: distributedKVStore.KVStoreType.SINGLE_VERSION,
  // 多设备协同数据库：kvStoreType: distributedKVStore.KVStoreType.DEVICE_COLLABORATION,
  securityLevel: distributedKVStore.SecurityLevel.S1
};
const STORE_ID = 'sample_kv_store'

export class SampleKVService {
  private static instance: SampleKVService | null = null;
  private constructor() {}
  private kvStore: distributedKVStore.SingleKVStore | undefined = undefined

  public static getInstance(): SampleKVService{
    if (!SampleKVService.instance) {
      // Initialize the singleton instance
      SampleKVService.instance = new SampleKVService();
    }
    return SampleKVService.instance;
  }

  public async init(){
    try{
      KVManagerSingletonWrapper.getKVManager().getKVStore<distributedKVStore.SingleKVStore>(STORE_ID, options, (err, store: distributedKVStore.SingleKVStore) => {
        if (err) {
          hilog.error(DOMAIN, TAG, FORMAT, `Failed to get KVStore: Code:${err.code},message:${err.message}`);
          return;
        }
        hilog.info(DOMAIN, TAG, FORMAT, 'Succeeded in getting KVStore.');
        this.kvStore = store;
        // 请确保获取到键值数据库实例后，再进行相关数据操作
      });
    }catch (e) {
      let error = e as BusinessError;
      hilog.error(DOMAIN, TAG, FORMAT, `An unexpected error occurred. Code:${error.code},message:${error.message}`);
    }
  }
}