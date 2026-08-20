import { ThemeState } from '../../basecomponent/Index';

/**
 * Menu Item Configuration
 */
export interface AuxiliaryTextMenuItemConfig {
  text: Resource;
  icon: Resource;
  onClick: () => void;
  hidden?: boolean;
  useIntrinsicIconColor?: boolean;
}

/**
 * Auxiliary Text Popup Menu Component
 * A reusable floating menu component for auxiliary text (ASR, translation, etc.)
 * Designed to be used with bindPopup() for showing menu options like hide, forward, copy
 */
@Component
export struct AuxiliaryTextPopupMenu {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  private menuItems: AuxiliaryTextMenuItemConfig[] = [];

  build() {
    Row() {
      ForEach(this.menuItems.filter((item: AuxiliaryTextMenuItemConfig) => !item.hidden), (item: AuxiliaryTextMenuItemConfig, index: number) => {
        this.MenuItem(item)
      }, (item: AuxiliaryTextMenuItemConfig, index: number) => `${index}`)
    }
    .padding({ left: 7, right: 7, top: 4, bottom: 4 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .borderRadius(5)
    .shadow({
      radius: 8,
      color: this.themeState.colors.shadowColor,
      offsetX: 0,
      offsetY: 2
    })
  }

  /**
   * Menu Item Builder
   */
  @Builder
  MenuItem(config: AuxiliaryTextMenuItemConfig) {
    Column() {
      if (config.useIntrinsicIconColor) {
        Image(config.icon)
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
      } else {
        Image(config.icon)
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
          .fillColor(this.themeState.colors.textColorPrimary)
      }

      Text(config.text)
        .fontSize(10)
        .fontColor(this.themeState.colors.textColorPrimary)
        .margin({ top: 3 })
    }
    .width(42)
    .height(48)
    .padding({ left: 3, right: 3, top: 7, bottom: 6 })
    .borderRadius(6)
    .onClick(() => {
      config.onClick();
    })
  }
}


