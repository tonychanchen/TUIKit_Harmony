import { MessageInfo, MessageType, TextMessagePayload, AudioMessagePayload, MergedMessagePayload } from '@tencentcloud/atomicxcore';
import { MessageUtils } from '../utils/MessageUtils';

export interface ListenItem {
  speechText: string;
  audioPath?: string;
}

export interface ListenPlanResources {
  selfSpeaker: string;
  says: (name: string) => string;
  sentImage: (name: string) => string;
  sentVideo: (name: string) => string;
  sentFile: (name: string) => string;
  sentMerged: (name: string, title: string) => string;
}

const SELF_SPEAKER_KEY: string = 'self';
const OTHER_SPEAKER_KEY_PREFIX: string = 'user:';

export class TtsTextSanitizer {
  private static readonly EMOJI_REGEX: RegExp =
    /[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{2190}-\u{21FF}\u{2B00}-\u{2BFF}\u{FE00}-\u{FE0F}\u{1F000}-\u{1F02F}\u{1F1E6}-\u{1F1FF}\u{200D}\u{20E3}]/gu;
  private static readonly BRACKET_EMOJI_REGEX: RegExp = /\[[^\[\]]{1,10}\]/g;

  static sanitize(text: string): string {
    if (!text || text.length === 0) {
      return '';
    }
    let result = text.replace(TtsTextSanitizer.BRACKET_EMOJI_REGEX, '');
    result = result.replace(TtsTextSanitizer.EMOJI_REGEX, '');
    return result.trim();
  }
}

export function buildListenPlan(messages: MessageInfo[], resources: ListenPlanResources): ListenItem[] {
  const items: ListenItem[] = [];
  let lastSpeakerKey: string | null = null;
  for (const message of messages) {
    const isSelf = message.isSentBySelf;
    const speakerKey = isSelf ? SELF_SPEAKER_KEY : OTHER_SPEAKER_KEY_PREFIX + (message.from?.userID ?? '');
    const speaker = isSelf ? resources.selfSpeaker : MessageUtils.senderDisplayName(message);
    const sameAsPrevious = lastSpeakerKey !== null && lastSpeakerKey === speakerKey;
    switch (message.messageType) {
      case MessageType.TEXT: {
        const raw = (message.messagePayload as TextMessagePayload)?.text ?? '';
        const content = TtsTextSanitizer.sanitize(raw);
        if (content.length === 0) {
          continue;
        }
        const speechText = sameAsPrevious ? content : resources.says(speaker) + content;
        items.push({ speechText });
        break;
      }
      case MessageType.IMAGE: {
        const speechText = sameAsPrevious ? resources.sentImage('').trim() : resources.sentImage(speaker);
        items.push({ speechText });
        break;
      }
      case MessageType.VIDEO: {
        const speechText = sameAsPrevious ? resources.sentVideo('').trim() : resources.sentVideo(speaker);
        items.push({ speechText });
        break;
      }
      case MessageType.FILE: {
        const speechText = sameAsPrevious ? resources.sentFile('').trim() : resources.sentFile(speaker);
        items.push({ speechText });
        break;
      }
      case MessageType.MERGED: {
        const rawTitle = (message.messagePayload as MergedMessagePayload)?.title ?? '';
        const title = TtsTextSanitizer.sanitize(rawTitle);
        const speechText = sameAsPrevious
          ? resources.sentMerged('', title).trim()
          : resources.sentMerged(speaker, title);
        items.push({ speechText });
        break;
      }
      case MessageType.AUDIO: {
        const payload = message.messagePayload as AudioMessagePayload;
        let path: string | undefined = undefined;
        if (payload?.audioPath && payload.audioPath.length > 0) {
          path = payload.audioPath;
        } else if (payload?.audioURL && payload.audioURL.length > 0) {
          path = payload.audioURL;
        }
        const speechText = sameAsPrevious ? '' : resources.says(speaker);
        items.push({ speechText, audioPath: path });
        break;
      }
      default:
        continue;
    }
    lastSpeakerKey = speakerKey;
  }
  return items;
}
