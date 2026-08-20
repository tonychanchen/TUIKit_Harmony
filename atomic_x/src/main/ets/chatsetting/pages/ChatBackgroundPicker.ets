import { ThemeState } from '../../basecomponent/Index';

interface ChatBackgroundPreset {
  id: string;
  imageUri: string | null;
  thumbnailUri: string | null;
}

const BACKGROUND_URL_TEMPLATE: string =
  'https://im.sdk.qcloud.com/download/tuikit-resource/conversation-backgroundImage/backgroundImage_%s_full.png';
const THUMBNAIL_URL_TEMPLATE: string =
  'https://im.sdk.qcloud.com/download/tuikit-resource/conversation-backgroundImage/backgroundImage_%s.png';

function getChatBackgroundPresets(): ChatBackgroundPreset[] {
  const presets: ChatBackgroundPreset[] = [{ id: 'default', imageUri: null, thumbnailUri: null }];
  for (let index = 1; index <= 7; index++) {
    presets.push({
      id: `${index}`,
      imageUri: BACKGROUND_URL_TEMPLATE.replace('%s', `${index}`),
      thumbnailUri: THUMBNAIL_URL_TEMPLATE.replace('%s', `${index}`)
    });
  }
  return presets;
}

@CustomDialog
export struct ChatBackgroundPickerDialog {
  controller: CustomDialogController;
  selectedImageUri: string | null = null;
  onBackgroundSelected?: (imageUri: string | null) => void;

  build() {
    ChatBackgroundPicker({
      selectedImageUri: this.selectedImageUri,
      onBackgroundSelected: (imageUri: string | null) => {
        this.onBackgroundSelected?.(imageUri);
        this.controller.close();
      },
      onClose: () => {
        this.controller.close();
      }
    });
  }
}

@Component
export struct ChatBackgroundPicker {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  selectedImageUri: string | null = null;
  onBackgroundSelected?: (imageUri: string | null) => void;
  onClose?: () => void;
  private presets: ChatBackgroundPreset[] = getChatBackgroundPresets();

  build() {
    Column() {
      Stack() {
        Text($r('app.string.chatsetting_select_chat_background'))
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeState.colors.textColorPrimary)
          .align(Alignment.Center);

        Row() {
          Text('×')
            .fontSize(24)
            .fontColor(this.themeState.colors.textColorSecondary)
            .onClick(() => {
              this.onClose?.();
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.End)
        .padding({ right: 16 });
      }
      .width('100%')
      .height(56);

      Scroll() {
        Grid() {
          ForEach(this.presets, (item: ChatBackgroundPreset) => {
            GridItem() {
              this.BackgroundItemBuilder(item);
            }
          }, (item: ChatBackgroundPreset) => item.id);
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .padding({ left: 16, right: 16, bottom: 24 })
        .width('100%');
      }
      .layoutWeight(1);
    }
    .width('100%')
    .height('65%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .borderRadius({ topLeft: 16, topRight: 16 });
  }

  @Builder
  private BackgroundItemBuilder(item: ChatBackgroundPreset) {
    Stack() {
      if (item.imageUri) {
        Image(item.thumbnailUri || item.imageUri)
          .width('100%')
          .height(120)
          .objectFit(ImageFit.Cover)
          .borderRadius(8);
      } else {
        Column() {
          Text($r('app.string.chatsetting_default'))
            .fontSize(14)
            .fontColor(this.themeState.colors.textColorSecondary)
            .width('100%')
            .textAlign(TextAlign.Center);
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center);
      }
    }
    .width('100%')
    .height(120)
    .backgroundColor(this.themeState.colors.bgColorTopBar)
    .borderRadius(8)
    .border({
      width: this.isSelected(item) ? 2 : 0,
      color: this.themeState.colors.buttonColorPrimaryDefault
    })
    .onClick(() => {
      this.onBackgroundSelected?.(item.imageUri);
    });
  }

  private isSelected(item: ChatBackgroundPreset): boolean {
    return item.imageUri === this.selectedImageUri || (!item.imageUri && !this.selectedImageUri);
  }
}
