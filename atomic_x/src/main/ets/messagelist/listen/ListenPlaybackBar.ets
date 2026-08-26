import { ThemeState } from '../../basecomponent/Index';

@Component
export struct ListenPlaybackBar {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @Prop isLoading: boolean = false;
  @Prop currentText: string = '';
  @State private expanded: boolean = true;
  onClose?: () => void;

  build() {
    Row() {
      Stack() {
        if (this.isLoading) {
          LoadingProgress()
            .width(20)
            .height(20)
            .color(this.themeState.colors.textColorLink)
        } else {
          Image($rawfile('messagelist/icon_extion_listen_from_here.svg'))
            .width(20)
            .height(20)
            .objectFit(ImageFit.Contain)
            .fillColor(this.themeState.colors.textColorLink)
        }
      }
      .width(20)
      .height(20)

      if (this.expanded) {
        Text(this.currentText)
          .layoutWeight(1)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontSize(13)
          .fontColor(this.themeState.colors.textColorSecondary)
          .margin({ left: 8 })

        Image($rawfile('messageinput/close_icon.svg'))
          .width(16)
          .height(16)
          .objectFit(ImageFit.Contain)
          .fillColor(this.themeState.colors.textColorPrimary)
          .margin({ left: 8 })
          .onClick(() => {
            this.onClose?.();
          })
      }
    }
    .constraintSize({ maxWidth: 320 })
    .height(36)
    .padding({ left: 10, right: 10 })
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .borderRadius(100)
    .border({ width: 0.5, color: this.themeState.colors.strokeColorPrimary })
    .shadow({
      radius: 8,
      color: this.themeState.colors.shadowColor,
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      this.expanded = !this.expanded;
    })
  }
}
