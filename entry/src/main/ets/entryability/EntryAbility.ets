import { distributedKVStore} from '@kit.ArkData'
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
const DOMAIN = 0x0000;
const TAG = "KVManager"
const FORMAT = '%{public}s'

let kvManager: distributedKVStore.KVManager | undefined = undefined

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, TAG, FORMAT, 'Ability onCreate');
    const kvManagerConfig: distributedKVStore.KVManagerConfig = {
      context: this.context,
      bundleName: 'site.hanchen.ebbinghaus2'
    }
    try{
      kvManager = distributedKVStore.createKVManager(kvManagerConfig);
      hilog.info(DOMAIN, TAG, FORMAT, 'Succeeded in creating KVManager.');
      KVManagerSingletonHolder.kvManager = kvManager as distributedKVStore.KVManager
    }catch (e) {
      let error = e as BusinessError;
      hilog.error(DOMAIN, TAG, FORMAT, `Failed to create KVManager. Code:${error.code},message:${error.message}`);
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}

export class KVManagerSingletonHolder{
  static kvManager: distributedKVStore.KVManager
}