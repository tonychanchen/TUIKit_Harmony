import { ThemeState } from '../../basecomponent/Index';

@Component
export struct MultiSelectBottomBar {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @Prop selectedCount: number = 0;
  onSeparateForward?: () => void;
  onMergedForward?: () => void;
  onDelete?: () => void;

  private readonly ICON_SIZE: number = 40;
  private readonly ITEM_TEXT_SIZE: number = 12;

  build() {
    Row() {
      this.ActionItemBuilder(
        $r('app.string.forward_separately'),
        'messagelist/icon_multiselect_forward_separate.svg',
        this.onSeparateForward,
        true
      )
      this.ActionItemBuilder(
        $r('app.string.forward_merged'),
        'messagelist/icon_multiselect_forward_merged.svg',
        this.onMergedForward,
        true
      )
      this.ActionItemBuilder(
        $r('app.string.multiselect_delete'),
        'messagelist/icon_multiselect_delete.svg',
        this.onDelete
      )
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.themeState.colors.bgColorBottomBar)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private ActionItemBuilder(title: string | Resource, icon: string, action?: () => void,
    useIntrinsicIconColor: boolean = false) {
    Column({ space: 6 }) {
      if (useIntrinsicIconColor) {
        Image($rawfile(icon))
          .width(this.ICON_SIZE)
          .height(this.ICON_SIZE)
      } else {
        Image($rawfile(icon))
          .width(this.ICON_SIZE)
          .height(this.ICON_SIZE)
          .fillColor(this.themeState.colors.textColorSecondary)
      }

      Text(title)
        .fontSize(this.ITEM_TEXT_SIZE)
        .fontColor(this.themeState.colors.textColorSecondary)
        .maxLines(1)
        .textAlign(TextAlign.Center)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .opacity(this.selectedCount > 0 ? 1 : 0.4)
    .enabled(this.selectedCount > 0)
    .onClick(() => {
      if (this.selectedCount > 0) {
        action?.();
      }
    })
  }
}
