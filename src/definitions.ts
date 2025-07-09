export interface StepData {
  steps: number;
}

export interface PermissionResult {
  granted: boolean;
}

export interface DateRange {
  start: number; // timestamp in ms
  end: number;
}

export interface PedometerPlugin {
  checkPermission(): Promise<PermissionResult>;
  start(): Promise<void>;
  stop(): Promise<void>;
  getStepsBetween(options: DateRange): Promise<StepData>;
  addListener(eventName: 'stepUpdate', listenerFunc: (data: StepData) => void): Promise<any>;
  removeAllListeners(): Promise<void>;
}
