import { ThemeState, Toast, LanguageState } from '../../basecomponent/Index';
@Component
export struct AvatarSelector {
  
  private static readonly IMAGE_SIZE: number = 66;
  private static readonly IMAGE_SPACING: number = 8;
  private static readonly BORDER_RADIUS: number = 8;
  private static readonly SELECTED_BORDER_WIDTH: number = 2;
  private static readonly HEADER_HEIGHT: number = 56;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @StorageLink('LanguageState') languageState: LanguageState = LanguageState.getInstance();
  
  title?: string | Resource = $r('app.string.chatsetting_select_avatar');
  urlList: string[] = [];
  onBack?: () => void;
  onConfirm?: (selectedUrl: string, selectedIndex: number) => void;

  @State selectedIndex: number = -1;

  build() {
    Column() {
      this.HeaderBuilder()

      if (this.urlList.length === 0) {
        this.EmptyStateBuilder()
      } else {
        this.ImageGridBuilder()
      }
    }
    .width('100%')
    .height('60%')
    .backgroundColor(this.themeState.colors.bgColorOperate)
    .borderRadius({ topLeft: 16, topRight: 16 })
    .clip(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  @Builder
  HeaderBuilder() {
    Stack() {
      Text(this.title)
        .fontSize(16)
        .fontWeight(600)
        .fontColor(this.themeState.colors.textColorPrimary)
        .textAlign(TextAlign.Center)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .align(Alignment.Center)

      Row() {
        Text('✕')
          .fontSize(18)
          .fontColor(this.themeState.colors.textColorSecondary)
          .width(44)
          .height(44)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            if (this.onBack) {
              this.onBack();
            }
          })
      }
      .width('100%')
      .height(AvatarSelector.HEADER_HEIGHT)
      .padding({ right: 16 })
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height(AvatarSelector.HEADER_HEIGHT)
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  EmptyStateBuilder() {
    Column() {
      Text($r('app.string.chatsetting_no_avatar_available'))
        .fontSize(16)
        .fontColor(this.themeState.colors.textColorSecondary)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  ImageGridBuilder() {
    Scroll() {
      Grid() {
        ForEach(this.urlList, (url: string, index: number) => {
          GridItem() {
            this.ImageItemBuilder(url, index)
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr 1fr') 
      .rowsGap(12)
      .columnsGap(12)
      .margin({ top: 8 })
      .padding({
        left: 12,
        right: 12,
        top: 8,
        bottom: 16
      })
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(this.themeState.colors.bgColorOperate)
  }

  @Builder
  ImageItemBuilder(url: string, index: number) {
    Stack() {
      
      Image(url)
        .width(AvatarSelector.IMAGE_SIZE)
        .height(AvatarSelector.IMAGE_SIZE)
        .borderRadius(AvatarSelector.BORDER_RADIUS)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#FFFFFF')
        .border({
          width: this.selectedIndex === index ? AvatarSelector.SELECTED_BORDER_WIDTH : 0,
          color: this.themeState.colors.textColorLink,
          radius: AvatarSelector.BORDER_RADIUS
        })

      
      if (this.selectedIndex === index) {
        Stack() {
          Circle()
            .width(20)
            .height(20)
            .fill(this.themeState.colors.textColorLink)

          Text('✓')
            .fontSize(12)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
        }
        .position({
          x: AvatarSelector.IMAGE_SIZE - 10,
          y: -10
        })
      }
    }
    .width(AvatarSelector.IMAGE_SIZE)
    .height(AvatarSelector.IMAGE_SIZE)
    .onClick(() => {
      this.selectedIndex = index;
      this.handleConfirm();
    })
  }


  private closeDialog(): void {
    if (this.onBack) {
      this.onBack();
    }
  }

  private handleConfirm(): void {
    if (this.selectedIndex >= 0 && this.selectedIndex < this.urlList.length) {
      const selectedUrl = this.urlList[this.selectedIndex];
      if (this.onConfirm) {
        this.onConfirm(selectedUrl, this.selectedIndex);
      }
      this.closeDialog();
    } else {
      Toast.info($r('app.string.chatsetting_please_select_image_first'), this.getUIContext());
    }
  }
} 