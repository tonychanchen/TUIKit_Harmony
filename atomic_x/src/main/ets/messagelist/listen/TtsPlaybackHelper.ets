import { V2TIMManager } from '@tencentcloud/imsdk';
import { AudioPlayer, AudioPlayerListener } from '../../audioplayer/utils/AudioPlayer';

type ExperimentalAPIResult = string | Object | undefined;

interface ExperimentalAPIError {
  code?: number;
  message?: string;
}

interface ConvertTextToVoiceResult {
  audioUrl?: string;
}

class TtsAudioListener implements AudioPlayerListener {
  private owner: TtsPlaybackHelper;
  private currentSession: number;
  private startCallback?: () => void;
  private completeCallback?: () => void;
  private errorCallback?: (message: string) => void;

  constructor(owner: TtsPlaybackHelper, currentSession: number, onStart?: () => void,
    onComplete?: () => void, onError?: (message: string) => void) {
    this.owner = owner;
    this.currentSession = currentSession;
    this.startCallback = onStart;
    this.completeCallback = onComplete;
    this.errorCallback = onError;
  }

  onPlay(): void {
    this.owner.handlePlaybackStart(this.currentSession, this.startCallback);
  }

  onCompletion(): void {
    this.owner.handlePlaybackComplete(this.currentSession, this.completeCallback);
  }

  onError(errorMessage: string): void {
    this.owner.handlePlaybackError(this.currentSession, errorMessage, this.errorCallback);
  }
}

export class TtsPlaybackHelper {
  private static readonly API_CONVERT_TEXT_TO_VOICE: string = 'convertTextToVoice';
  private static readonly KEY_TEXT: string = 'text';
  private static readonly KEY_VOICE_ID: string = 'voiceId';
  private static readonly KEY_AUDIO_FORMAT: string = 'audioFormat';
  private static readonly KEY_LANGUAGE: string = 'language';
  private static readonly DEFAULT_AUDIO_FORMAT: string = 'wav';
  private static readonly ERROR_UNKNOWN: number = -1;

  private playing: boolean = false;
  private player: AudioPlayer | null = null;
  private session: number = 0;
  private pendingOnComplete: (() => void) | null = null;

  isPlaying(): boolean {
    return this.playing;
  }

  speak(text: string, voiceId: string = '', language: string = '', onStart?: () => void,
    onComplete?: () => void, onError?: (message: string) => void): void {
    const currentSession = ++this.session;
    this.pendingOnComplete = onComplete ?? null;
    this.convertTextToVoice(text, voiceId, language, (audioUrl: string) => {
      if (currentSession !== this.session) {
        return;
      }
      this.startPlayback(currentSession, audioUrl, onStart, onComplete, onError);
    }, (_code: number, desc: string) => {
      if (currentSession !== this.session) {
        return;
      }
      this.playing = false;
      this.pendingOnComplete = null;
      onError?.(desc);
    });
  }

  stop(): void {
    this.session++;
    const current = this.player;
    this.player = null;
    this.playing = false;
    const onComplete = this.pendingOnComplete;
    this.pendingOnComplete = null;
    current?.setListener(null);
    current?.stop();
    onComplete?.();
  }

  private convertTextToVoice(text: string, voiceId: string, language: string,
    onSuccess: (audioUrl: string) => void, onFailure: (code: number, desc: string) => void): void {
    try {
      const promise = V2TIMManager.getInstance()
        .callExperimentalAPI(TtsPlaybackHelper.API_CONVERT_TEXT_TO_VOICE,
          TtsPlaybackHelper.buildConvertTextToVoiceParams(text, voiceId, language));
      if (!promise) {
        onFailure(TtsPlaybackHelper.ERROR_UNKNOWN, '');
        return;
      }
      promise
        .then((result: ExperimentalAPIResult) => {
          const audioUrl = TtsPlaybackHelper.parseAudioUrl(result?.toString() ?? '');
          if (!audioUrl || audioUrl.length === 0) {
            onFailure(TtsPlaybackHelper.ERROR_UNKNOWN, 'tts audio url is empty');
          } else {
            onSuccess(audioUrl);
          }
        })
        .catch((error: ExperimentalAPIError) => {
          onFailure(error.code ?? TtsPlaybackHelper.ERROR_UNKNOWN, error.message ?? '');
        });
    } catch (exception) {
      const error = exception as Error;
      onFailure(TtsPlaybackHelper.ERROR_UNKNOWN, error.message ?? '');
    }
  }

  private startPlayback(currentSession: number, audioUrl: string, onStart?: () => void,
    onComplete?: () => void, onError?: (message: string) => void): void {
    this.releasePlayer();
    const newPlayer = AudioPlayer.create();
    this.player = newPlayer;
    const listener = new TtsAudioListener(this, currentSession, onStart, onComplete, onError);
    newPlayer.setListener(listener);
    newPlayer.play(audioUrl);
  }

  handlePlaybackStart(currentSession: number, onStart?: () => void): void {
    if (currentSession !== this.session) {
      return;
    }
    this.playing = true;
    onStart?.();
  }

  handlePlaybackComplete(currentSession: number, onComplete?: () => void): void {
    if (currentSession !== this.session) {
      return;
    }
    this.playing = false;
    this.player = null;
    this.pendingOnComplete = null;
    onComplete?.();
  }

  handlePlaybackError(currentSession: number, errorMessage: string, onError?: (message: string) => void): void {
    if (currentSession !== this.session) {
      return;
    }
    this.playing = false;
    this.player = null;
    this.pendingOnComplete = null;
    onError?.(errorMessage);
  }

  private releasePlayer(): void {
    const current = this.player;
    this.player = null;
    current?.setListener(null);
    current?.stop();
  }

  private static buildConvertTextToVoiceParams(text: string, voiceId: string, language: string): string {
    const params: Record<string, Object> = {};
    params[TtsPlaybackHelper.KEY_TEXT] = text;
    params[TtsPlaybackHelper.KEY_AUDIO_FORMAT] = TtsPlaybackHelper.DEFAULT_AUDIO_FORMAT;
    params[TtsPlaybackHelper.KEY_LANGUAGE] = language;
    if (voiceId.length > 0) {
      params[TtsPlaybackHelper.KEY_VOICE_ID] = voiceId;
    }
    return JSON.stringify(params);
  }

  private static parseAudioUrl(result: string): string | undefined {
    if (result.length === 0) {
      return undefined;
    }
    try {
      const parsed = JSON.parse(result) as ConvertTextToVoiceResult;
      return parsed.audioUrl;
    } catch (_error) {
      return undefined;
    }
  }
}
