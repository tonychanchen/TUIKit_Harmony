import { Avatar, AvatarContentType, AvatarSize,
  IMErrorCode,
  ThemeState, Toast, ToastType } from '../../../basecomponent/Index';
import { ContactInfo, ContactStore } from '@tencentcloud/atomicxcore';
import { LoginStore } from '@tencentcloud/atomicxcore';
import { CompletionHandlerAdapter } from '../../../basecomponent/utils/CompletionHandlers';

@Entry({ routeName: 'ContactDetailPage' })
@Component
export struct ContactDetailPage {
  @StorageLink('ThemeState') themeState: ThemeState = ThemeState.getInstance();
  @Prop userInfo?: ContactInfo;
  onClose?: () => void;
  @State isAddingFriend: boolean = false;
  @State remarkName: string = '';
  @State isEditingRemark: boolean = false;
  @State verificationMessage: string = '';
  @State showSendForm: boolean = false;
  @State groupName: string = '';
  @State private internalUserInfo: ContactInfo | null = null;
  private contactStore: ContactStore = ContactStore.shared;

  aboutToAppear() {
    if (this.userInfo) {
      this.internalUserInfo = this.userInfo;
    }
    if (this.internalUserInfo) {
      this.remarkName = this.internalUserInfo.nickname || '';
      this.verificationMessage = this.getDefaultVerificationMessage();
      this.groupName = getContext(this).resourceManager.getStringSync($r('app.string.my_friend'));
    }
  }

  private getDefaultVerificationMessage(): string {
    const loginUser = LoginStore.shared().state.loginUserInfo;
    const nickname = loginUser?.nickname || loginUser?.userID || '';
    return `我是${nickname}`;
  }

  private handleClose(): void {
    if (this.showSendForm) {
      this.showSendForm = false;
      return;
    }
    if (this.onClose) {
      this.onClose();
    }
  }

  private handleAddFriend() {
    if (!this.internalUserInfo || this.isAddingFriend) {
      return;
    }
    this.isAddingFriend = true;
    this.contactStore.addFriend(
      this.internalUserInfo.userID || '',
      this.remarkName || this.internalUserInfo.nickname || '',
      this.verificationMessage ?? ' ',
      new CompletionHandlerAdapter(() => {
        this.isAddingFriend = false;
        Toast.show($r('app.string.friend_request_sent'), ToastType.Success, this.getUIContext(), 3000);
        this.handleClose();
      }, (code: number, desc: string) => {
        this.isAddingFriend = false;
        const localizedMessage = IMErrorCode.getErrorMessage(code, '' + code + desc);
        Toast.error(localizedMessage, this.getUIContext());
      })
    );
  }

  build() {
    Column() {
      if (!this.showSendForm) {
        Column() {
          if (this.internalUserInfo) {
            Row() {
              Avatar({
                content: {
                  type: AvatarContentType.Image,
                  url: this.internalUserInfo.avatarURL,
                  name: this.internalUserInfo.nickname || this.internalUserInfo.userID || '',
                },
                avatarSize: AvatarSize.L,
              })

              Column() {
                Text(this.internalUserInfo.nickname || this.internalUserInfo.userID || '')
                  .fontSize(18)
                  .fontWeight(FontWeight.Regular)
                  .fontColor(this.themeState.colors.textColorPrimary)
                  .fontFamily('PingFang SC')

                Text(`ID：${this.internalUserInfo.userID}`)
                  .fontSize(13)
                  .fontColor(this.themeState.colors.textColorSecondary)
                  .fontFamily('PingFang SC')
                  .margin({ top: 4 })

                if (this.internalUserInfo.aboutMe) {
                  Text(`个性签名：${this.internalUserInfo.aboutMe}`)
                    .fontSize(13)
                    .fontColor(this.themeState.colors.textColorSecondary)
                    .fontFamily('PingFang SC')
                    .margin({ top: 2 })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 16 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            .alignItems(VerticalAlign.Top)
            .backgroundColor(this.themeState.colors.bgColorOperate)
          }
        }
        .width('100%')
        .backgroundColor(this.themeState.colors.bgColorOperate)

        Divider()
          .color(this.themeState.colors.bgColorDialogModule)
          .strokeWidth(8)
          .width('100%')

        Row() {
          Text($r('app.string.add_contacts_title'))
            .fontSize(16)
            .fontColor('#1C66E5')
            .fontFamily('PingFang SC')
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .onClick(() => {
          this.showSendForm = true;
        })

        Divider()
          .color(this.themeState.colors.strokeColorSecondary)
          .strokeWidth(0.5)
          .width('100%')

        Column()
          .layoutWeight(1)
          .width('100%')
          .backgroundColor(this.themeState.colors.bgColorDialogModule)
      } else {
        Column() {
          if (this.internalUserInfo) {
            Row() {
              Avatar({
                content: {
                  type: AvatarContentType.Image,
                  url: this.internalUserInfo.avatarURL,
                  name: this.internalUserInfo.nickname || this.internalUserInfo.userID || '',
                },
                avatarSize: AvatarSize.L,
              })

              Column() {
                Text(this.internalUserInfo.nickname || this.internalUserInfo.userID || '')
                  .fontSize(18)
                  .fontWeight(FontWeight.Regular)
                  .fontColor(this.themeState.colors.textColorPrimary)
                  .fontFamily('PingFang SC')

                Text(`ID：${this.internalUserInfo.userID}`)
                  .fontSize(13)
                  .fontColor(this.themeState.colors.textColorSecondary)
                  .fontFamily('PingFang SC')
                  .margin({ top: 4 })

                if (this.internalUserInfo.aboutMe) {
                  Text(`个性签名：${this.internalUserInfo.aboutMe}`)
                    .fontSize(13)
                    .fontColor(this.themeState.colors.textColorSecondary)
                    .fontFamily('PingFang SC')
                    .margin({ top: 2 })
                }
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              .margin({ left: 16 })
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 16, bottom: 16 })
            .alignItems(VerticalAlign.Top)
            .backgroundColor(this.themeState.colors.bgColorOperate)
          }
        }
        .width('100%')
        .backgroundColor(this.themeState.colors.bgColorOperate)

        Column() {
          Text($r('app.string.fill_verification_info'))
            .fontSize(14)
            .fontColor(this.themeState.colors.textColorTertiary)
            .fontFamily('PingFang SC')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .backgroundColor(this.themeState.colors.bgColorDialogModule)
        .alignItems(HorizontalAlign.Start)

        Column() {
          TextArea({
            text: this.verificationMessage,
            placeholder: $r('app.string.enter_verification_info')
          })
            .fontSize(16)
            .fontColor(this.themeState.colors.textColorPrimary)
            .placeholderColor(this.themeState.colors.textColorTertiary)
            .fontFamily('PingFang SC')
            .width('100%')
            .height(144)
            .backgroundColor(Color.Transparent)
            .border({ width: 0 })
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .align(Alignment.TopStart)
            .onChange((value: string) => {
              this.verificationMessage = value;
            })
        }
        .width('100%')
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .alignItems(HorizontalAlign.Start)

        Column()
          .width('100%')
          .height(10)
          .backgroundColor(this.themeState.colors.bgColorDialogModule)

        Row() {
          Text($r('app.string.remarks'))
            .fontSize(16)
            .fontColor(this.themeState.colors.textColorPrimary)
            .fontFamily('PingFang SC')

          Blank()

          if (this.isEditingRemark) {
            TextInput({ text: this.remarkName })
              .fontSize(16)
              .fontColor(this.themeState.colors.textColorPrimary)
              .backgroundColor(Color.Transparent)
              .border({ width: 0 })
              .textAlign(TextAlign.End)
              .fontFamily('PingFang SC')
              .layoutWeight(1)
              .onChange((value: string) => {
                this.remarkName = value;
              })
              .onSubmit(() => {
                this.isEditingRemark = false;
              })
              .defaultFocus(true)
          } else {
            Text(this.remarkName || '')
              .fontSize(16)
              .fontColor(this.themeState.colors.textColorSecondary)
              .fontFamily('PingFang SC')
          }
        }
        .width('100%')
        .height(48)
        .padding({ left: 16, right: 16 })
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .onClick(() => {
          this.isEditingRemark = true;
        })

        Column()
          .width('100%')
          .height(10)
          .backgroundColor(this.themeState.colors.bgColorDialogModule)

        Row() {
          Text(this.isAddingFriend ? $r('app.string.sending') : $r('app.string.send'))
            .fontSize(16)
            .fontColor('#1C66E5')
            .fontFamily('PingFang SC')
        }
        .width('100%')
        .height(48)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.themeState.colors.bgColorOperate)
        .onClick(() => {
          if (!this.isAddingFriend) {
            this.handleAddFriend();
          }
        })

        Column()
          .layoutWeight(1)
          .width('100%')
          .backgroundColor(this.themeState.colors.bgColorDialogModule)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeState.colors.bgColorDialogModule)
  }
}