import { WebPlugin } from '@capacitor/core';

import type { CapacitorFingerprintPlugin } from './definitions';

export class CapacitorFingerprintWeb
  extends WebPlugin
  implements CapacitorFingerprintPlugin
{
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
