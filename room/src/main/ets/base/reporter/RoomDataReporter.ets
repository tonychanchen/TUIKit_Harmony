import { RoomStore } from '@tencentcloud/atomicxcore';
import { RoomConstants } from '../constants/RoomConstants';

export class RoomDataReporter {
  static reportComponent(): void {
    const params: Record<string, number> = {
      'framework': RoomConstants.dataReportFramework,
      'component': RoomConstants.dataReportRoomComponent,
      'language': RoomConstants.dataReportLanguage,
    };

    const jsonObject: Record<string, Object> = {
      'api': 'setFramework',
      'params': params,
    };

    const jsonString: string = JSON.stringify(jsonObject);
    RoomStore.shared().callExperimentalAPI(jsonString);
  }
}
