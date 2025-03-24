import { dataSharePredicates } from '@kit.ArkData';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
const DOMAIN = 0x0000;
const TAG = "KVManager"
const FORMAT = '%{public}s'

const context = getContext(this);
let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);

class MediaDataHandler implements photoAccessHelper.MediaAssetDataHandler<ArrayBuffer> {
  onDataPrepared(data: ArrayBuffer) {
    if (data === undefined) {
      hilog.error(DOMAIN, TAG, FORMAT, 'Error occurred when preparing data');
      return;
    }
    hilog.info(DOMAIN, TAG, FORMAT, 'on image data prepared');
    // 应用自定义对资源数据的处理逻辑
  }
}

export async function fetchMediaExample(uri:string) {
  hilog.info(DOMAIN, TAG, FORMAT, "Fetching media: ", uri)
  let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
  predicates.equalTo(photoAccessHelper.PhotoKeys.URI, uri.toString());
  let fetchOptions: photoAccessHelper.FetchOptions = {
    fetchColumns: [photoAccessHelper.PhotoKeys.TITLE],
    predicates: predicates
  };

  try {
    hilog.info(DOMAIN, TAG, FORMAT, "Here I am")
    let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> = await phAccessHelper.getAssets(fetchOptions);
    let photoAsset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
    hilog.info(DOMAIN, TAG, FORMAT, 'getAssets photoAsset.uri : ' + photoAsset.uri);
    // 获取属性值，以标题为例；对于非默认查询的属性，get前需要在fetchColumns中添加对应列名
    hilog.info(DOMAIN, TAG, FORMAT, 'title : ' + photoAsset.get(photoAccessHelper.PhotoKeys.TITLE));
    // 请求图片资源数据
    let requestOptions: photoAccessHelper.RequestOptions = {
      deliveryMode: photoAccessHelper.DeliveryMode.HIGH_QUALITY_MODE,
    }
    await photoAccessHelper.MediaAssetManager.requestImageData(context, photoAsset, requestOptions, new MediaDataHandler());
    hilog.info(DOMAIN, TAG, FORMAT,'requestImageData successfully');
    fetchResult.close();
  } catch (err) {
    hilog.error(DOMAIN, TAG, FORMAT,'getAssets failed with err: ' + err);
  }
}