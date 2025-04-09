import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import {KVManagerSingletonWrapper} from '../database/KVManagerSingletonWrapper'
import {SampleKVService} from '../database/SampleKVService'
import memoryManager from '../database/memory/MemoryManager'
import rdbStoreProvider from '../database/RdbStoreProvider'
import preferencesService from '../database/PreferencesService'
import repetitionManager from '../database/repetition/RepetitionManager'
import { hilog } from '@kit.PerformanceAnalysisKit';
import {Logger} from '../utils/Logger'
const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    logger.log('Ability onCreate');


  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage){
    // Main window is created, set main page for this ability

    logger.log('Ability onWindowStageCreate');
    preferencesService.init(this.context)
    await rdbStoreProvider.init(this.context)
    await memoryManager.init()
    await repetitionManager.init()
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
    //rdbStoreProvider.destroy(this.context)
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
