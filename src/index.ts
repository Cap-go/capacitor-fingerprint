import { registerPlugin } from '@capacitor/core';

import type { CapacitorFingerprintPlugin } from './definitions';

const CapacitorFingerprint = registerPlugin<CapacitorFingerprintPlugin>(
  'CapacitorFingerprint',
  {
    web: () => import('./web').then(m => new m.CapacitorFingerprintWeb()),
  },
);

export * from './definitions';
export { CapacitorFingerprint };
