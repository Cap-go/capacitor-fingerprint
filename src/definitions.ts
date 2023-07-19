export interface CapacitorFingerprintPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
