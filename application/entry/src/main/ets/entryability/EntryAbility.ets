import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { TUICallKit } from '@tencentcloud/tuicallkit';
import { UserStore } from '../common/UserStore';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    hilog.info(DOMAIN, 'testTag', 'Ability onWindowStageCreate');

    const store = UserStore.instance;
    await store.init(this.context);

    let startPage = 'pages/Index';

    windowStage.loadContent(startPage, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load content: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading content: %{public}s', startPage);
      try {
        TUICallKit.createInstance(this.context).attach(windowStage);
        hilog.info(DOMAIN, 'testTag', 'TUICallKit.attach done');
      } catch (e) {
        hilog.error(DOMAIN, 'testTag', 'TUICallKit.attach failed: %{public}s', JSON.stringify(e));
      }
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', 'Ability onWindowStageDestroy');
    try {
      TUICallKit.createInstance(this.context).detach();
    } catch (e) {
      hilog.warn(DOMAIN, 'testTag', 'TUICallKit.detach failed: %{public}s', JSON.stringify(e));
    }
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', 'Ability onBackground');
  }
}
