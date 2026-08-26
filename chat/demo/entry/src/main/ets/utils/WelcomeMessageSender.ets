import { MessageInputStore, TextSendMessagePayload, CompletionHandler } from '@tencentcloud/atomicxcore';
import { Log } from '@tencentcloud/atomicx/src/main/ets/basecomponent/Index';

class WelcomeMessageCompletionHandler implements CompletionHandler {
  onSuccess(): void {
    Log.i(WelcomeMessageSender.TAG, 'send welcome message success');
  }

  onFailure(code: number, desc: string): void {
    Log.e(WelcomeMessageSender.TAG, `send welcome message failed: ${code} ${desc}`);
  }
}

export class WelcomeMessageSender {
  static readonly TAG: string = 'WelcomeMessageSender';
  private static readonly ADMINISTRATOR_CONVERSATION_ID: string = 'c2c_administrator';
  private static readonly SEND_DELAY_MS: number = 1000;

  static scheduleWelcomeMessage(): void {
    setTimeout(() => {
      WelcomeMessageSender.sendWelcomeMessage();
    }, WelcomeMessageSender.SEND_DELAY_MS);
  }

  private static sendWelcomeMessage(): void {
    const welcomeText = getContext().resourceManager.getStringSync($r('app.string.demo_welcome_message').id);
    const inputStore = MessageInputStore.create(WelcomeMessageSender.ADMINISTRATOR_CONVERSATION_ID);
    inputStore.sendMessage(new TextSendMessagePayload(welcomeText), undefined, new WelcomeMessageCompletionHandler());
  }
}
