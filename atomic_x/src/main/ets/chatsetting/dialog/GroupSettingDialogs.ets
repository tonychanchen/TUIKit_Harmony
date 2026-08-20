import { ActionItem, ActionSheet, ThemeState } from '../../basecomponent/Index';
import { GroupJoinOption } from '@tencentcloud/atomicxcore';

export interface ActionButtonConfig {
  text: string | Resource;
  action: string;
  color?: string;
  showDivider?: boolean;
}

@CustomDialog
export struct JoinGroupMethodDialog {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  currentOpt?: GroupJoinOption = undefined;
  onSelect?: (opt: GroupJoinOption) => void;
  onCancel?: () => void;
  controller: CustomDialogController;

  build() {
    ActionSheet({
      options: [
        {
          text: $r('app.string.chatsetting_forbid_add_group'),
          value: GroupJoinOption.FORBID,
          isSelected: this.currentOpt === GroupJoinOption.FORBID
        },
        {
          text: $r('app.string.chatsetting_require_admin_approval'),
          value: GroupJoinOption.AUTH,
          isSelected: this.currentOpt === GroupJoinOption.AUTH
        },
        {
          text: $r('app.string.chatsetting_auto_approve'),
          value: GroupJoinOption.ANY,
          isSelected: this.currentOpt === GroupJoinOption.ANY
        }
      ],
      onActionSelected: (item: ActionItem) => {
        if (this.onSelect) {
          this.onSelect(item.value as GroupJoinOption);
        }
      },
      onDismiss: this.onCancel,
      controller: this.controller
    })
  }
}

@CustomDialog
export struct InviteGroupMethodDialog {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  currentOpt?: GroupJoinOption = undefined;
  onSelect?: (opt: GroupJoinOption) => void;
  onCancel?: () => void;
  controller: CustomDialogController;

  build() {
    ActionSheet({
      options: [
        {
          text: $r('app.string.chatsetting_forbid_invite'),
          value: GroupJoinOption.FORBID,
          isSelected: this.currentOpt === GroupJoinOption.FORBID
        },
        {
          text: $r('app.string.chatsetting_require_admin_approval'),
          value: GroupJoinOption.AUTH,
          isSelected: this.currentOpt === GroupJoinOption.AUTH
        },
        {
          text: $r('app.string.chatsetting_auto_approve'),
          value: GroupJoinOption.ANY,
          isSelected: this.currentOpt === GroupJoinOption.ANY
        }
      ],
      onActionSelected: (item: ActionItem) => {
        if (this.onSelect) {
          this.onSelect(item.value as GroupJoinOption);
        }
      },
      onDismiss: this.onCancel,
      controller: this.controller
    })
  }
}

@CustomDialog
export struct GroupNameEditDialog {
  private static readonly BUTTON_HEIGHT: number = 56;
  private static readonly BOTTOM_RADIUS: number = 14;
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  title: string | Resource = $r('app.string.chatsetting_edit_group_name');
  currentName: string = '';
  placeholder: string | Resource = $r('app.string.chatsetting_input_group_name');
  helpText: string | Resource = $r('app.string.chatsetting_group_name_help_text');
  maxLength: number = 30;
  onSave?: (newName: string) => void;
  onCancel?: () => void;
  controller: CustomDialogController;
  @State inputText: string = '';

  aboutToAppear() {
    this.inputText = this.currentName;
  }

  build() {
    Column() {
      Column() {
        Row() {
          Text(this.title)
            .fontSize(17)
            .fontFamily('PingFang HK')
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeState.colors.textColorPrimary)
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .height(GroupNameEditDialog.BUTTON_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)

        Divider()
          .height(0.4)
          .color(this.themeState.colors.strokeColorPrimary)
          .width('100%')

        Column() {
          TextInput({ text: this.inputText, placeholder: this.placeholder })
            .fontSize(17)
            .fontFamily('PingFang HK')
            .fontWeight(400)
            .fontColor(this.themeState.colors.textColorPrimary)
            .backgroundColor('transparent')
            .border({ width: 0 })
            .padding({
              left: 16,
              right: 16,
              top: 12,
              bottom: 12
            })
            .width('100%')
            .onChange((value: string) => {
              this.inputText = value;
            })
            .maxLength(this.maxLength)

          if (this.helpText) {
            Text(this.helpText)
              .fontSize(14)
              .fontFamily('PingFang HK')
              .fontWeight(400)
              .fontColor(this.themeState.colors.textColorSecondary)
              .padding({ left: 16, right: 16, bottom: 12 })
              .width('100%')
          }
        }
        .width('100%')

        Divider()
          .height(0.4)
          .color(this.themeState.colors.strokeColorPrimary)
          .width('100%')

        Button() {
          Text($r('app.string.chatsetting_confirm'))
            .fontSize(17)
            .fontFamily('PingFang HK')
            .fontWeight(400)
            .fontColor(this.themeState.colors.textColorLink)
            .textAlign(TextAlign.Center)
        }
        .backgroundColor(this.themeState.colors.bgColorBubbleReciprocal)
        .height(GroupNameEditDialog.BUTTON_HEIGHT)
        .width('100%')
        .onClick(() => this.handleSave())
      }
      .width('100%')
      .borderRadius(12)
      .backgroundColor(this.themeState.colors.bgColorBubbleReciprocal)
    }
    .width('100%')
    .padding(16)
    .margin({ bottom: 38 })
  }

  private handleSave() {
    const trimmedText = this.inputText.trim();
  
    if (this.onSave) {
      this.onSave(trimmedText);
    }

    this.controller.close();
  }
}

@CustomDialog
export struct GroupTextInputDialog {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  title: string | Resource = '';
  initialText: string = '';
  placeholder: string | Resource = '';
  multiline: boolean = false;
  maxLength: number = 0;
  onConfirm?: (value: string) => void;
  controller: CustomDialogController;
  @State inputText: string = '';

  aboutToAppear(): void {
    this.inputText = this.initialText;
  }

  build() {
    Column() {
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeState.colors.textColorPrimary)
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 20 })

      if (this.multiline) {
        TextArea({ text: this.inputText, placeholder: this.placeholder })
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorPrimary)
          .placeholderColor(this.themeState.colors.textColorTertiary)
          .width('100%')
          .height(160)
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor(this.themeState.colors.bgColorDialog)
          .border({ width: 1, color: this.themeState.colors.strokeColorPrimary })
          .borderRadius(8)
          .maxLength(this.maxLength)
          .onChange((value: string): void => {
            this.inputText = value;
          })

        Text(`${this.inputText.length}/${this.maxLength}`)
          .fontSize(12)
          .fontColor(this.themeState.colors.textColorTertiary)
          .width('100%')
          .textAlign(TextAlign.End)
          .margin({ top: 6, bottom: 20 })
      } else {
        TextInput({ text: this.inputText, placeholder: this.placeholder })
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorPrimary)
          .placeholderColor(this.themeState.colors.textColorTertiary)
          .width('100%')
          .height(40)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.themeState.colors.bgColorDialog)
          .border({ width: 1, color: this.themeState.colors.strokeColorPrimary })
          .borderRadius(8)
          .onChange((value: string): void => {
            this.inputText = value;
          })
          .margin({ bottom: 20 })
      }

      Button() {
        Text($r('app.string.chatsetting_confirm'))
          .fontSize(16)
          .fontColor(this.themeState.colors.textColorButton)
      }
      .width('100%')
      .height(36)
      .type(ButtonType.Capsule)
      .backgroundColor(this.themeState.colors.buttonColorPrimaryDefault)
      .onClick((): void => {
        this.onConfirm?.(this.inputText.trim());
        this.controller.close();
      })
    }
    .width('80%')
    .padding(20)
    .backgroundColor(this.themeState.colors.bgColorDialog)
    .borderRadius(12)
  }
}
