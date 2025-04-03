import router from '@ohos.router';
import { Memory } from '../entities/Memory';
import {Logger} from '../utils/Logger'
const DOMAIN = 0x0000;
const TAG = "crud"
const FORMAT = '%{public}s'
const logger = new Logger(DOMAIN, TAG, FORMAT)
@Entry
@Component
struct MemoryDisplayPage {
  private memory: Memory | null = null;
  aboutToAppear() {
    // Get parameters from the navigation
    const params = router.getParams() as Record<string, string | number | object>;

    if (params) {
      this.memory = JSON.parse(params['memory'] as string); // Deserialize if needed
      logger.log(`${this.memory}`)
      logger.log(`${this.memory?.NAME}`)
    }
  }
  build() {

  }
}