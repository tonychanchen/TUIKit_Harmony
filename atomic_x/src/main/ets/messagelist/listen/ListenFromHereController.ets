import { AudioPlayer, AudioPlayerListener } from '../../audioplayer/utils/AudioPlayer';
import { TtsPlaybackHelper } from './TtsPlaybackHelper';
import { ListenItem } from './ListenFromHere';

export interface ListenPlaybackState {
  isActive: boolean;
  isLoading: boolean;
  currentText: string;
}

export type ListenStateListener = (state: ListenPlaybackState) => void;

class ListenAudioListener implements AudioPlayerListener {
  private owner: ListenFromHereController;
  private currentSession: number;

  constructor(owner: ListenFromHereController, currentSession: number) {
    this.owner = owner;
    this.currentSession = currentSession;
  }

  onPlay(): void {
    this.owner.onAudioPlay(this.currentSession);
  }

  onCompletion(): void {
    this.owner.onAudioFinished(this.currentSession);
  }

  onError(_errorMessage: string): void {
    this.owner.onAudioFinished(this.currentSession);
  }
}

export class ListenFromHereController {
  private tts: TtsPlaybackHelper = new TtsPlaybackHelper();
  private audioPlayer: AudioPlayer = AudioPlayer.create();

  private queue: ListenItem[] = [];
  private index: number = -1;
  private active: boolean = false;
  private voiceId: string = '';
  private session: number = 0;

  private stateValue: ListenPlaybackState = { isActive: false, isLoading: false, currentText: '' };
  private listener: ListenStateListener | null = null;

  setStateListener(listener: ListenStateListener | null): void {
    this.listener = listener;
  }

  get state(): ListenPlaybackState {
    return this.stateValue;
  }

  start(plan: ListenItem[]): void {
    this.stop();
    if (plan.length === 0) {
      return;
    }
    this.queue = plan;
    this.index = 0;
    this.active = true;
    const currentSession = ++this.session;
    this.updateState({ isActive: true, isLoading: true, currentText: plan[0].speechText });
    this.playCurrent(true, currentSession);
  }

  stop(): void {
    const wasActive = this.active;
    this.active = false;
    this.session++;
    this.index = -1;
    this.queue = [];
    this.audioPlayer.setListener(null);
    this.audioPlayer.stop();
    this.tts.stop();
    if (wasActive || this.stateValue.isActive) {
      this.updateState({ isActive: false, isLoading: false, currentText: '' });
    }
  }

  private playCurrent(showLoading: boolean, currentSession: number): void {
    if (!this.active || currentSession !== this.session || this.index < 0 || this.index >= this.queue.length) {
      return;
    }
    const item = this.queue[this.index];
    this.updateState({ isActive: true, isLoading: showLoading, currentText: item.speechText });
    const audioPath = item.audioPath;

    if (item.speechText.length === 0) {
      if (audioPath && audioPath.length > 0) {
        this.playAudio(audioPath, currentSession);
      } else {
        this.advance(currentSession);
      }
      return;
    }

    this.tts.speak(item.speechText, this.voiceId, '', () => {
      this.clearLoading(currentSession);
    }, () => {
      if (!this.active || currentSession !== this.session) {
        return;
      }
      if (audioPath && audioPath.length > 0) {
        this.playAudio(audioPath, currentSession);
      } else {
        this.advance(currentSession);
      }
    }, () => {
      if (this.active && currentSession === this.session) {
        this.advance(currentSession);
      }
    });
  }

  private playAudio(audioPath: string, currentSession: number): void {
    const listener = new ListenAudioListener(this, currentSession);
    this.audioPlayer.setListener(listener);
    this.audioPlayer.play(audioPath);
  }

  onAudioPlay(currentSession: number): void {
    this.clearLoading(currentSession);
  }

  onAudioFinished(currentSession: number): void {
    if (this.active && currentSession === this.session) {
      this.advance(currentSession);
    }
  }

  private advance(currentSession: number): void {
    if (!this.active || currentSession !== this.session) {
      return;
    }
    this.index++;
    if (this.index >= this.queue.length) {
      this.stop();
    } else {
      this.playCurrent(false, currentSession);
    }
  }

  private clearLoading(currentSession: number): void {
    if (this.active && currentSession === this.session && this.stateValue.isLoading) {
      this.updateState({ isActive: this.stateValue.isActive, isLoading: false, currentText: this.stateValue.currentText });
    }
  }

  private updateState(state: ListenPlaybackState): void {
    this.stateValue = state;
    this.listener?.(state);
  }
}
