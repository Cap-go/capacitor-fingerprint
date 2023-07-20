import { WebPlugin } from '@capacitor/core';
import type { LoadOptions } from '@fingerprintjs/fingerprintjs-pro';
import FingerprintJS from '@fingerprintjs/fingerprintjs-pro'

import type { CapacitorFingerprintPlugin, VisitorId, getVisitor } from './definitions';
import type { VisitorData } from './types';

export class CapacitorFingerprintWeb
  extends WebPlugin
  implements CapacitorFingerprintPlugin
{
  agent: any;
  async load(options: LoadOptions): Promise<void> {
    this.agent = await FingerprintJS.load(options)
  }
  async getVisitorId(options?: getVisitor): Promise<VisitorId> {
    const result = await this.agent.get(options)
    return result.visitorId
  }
  async getVisitorData(options?: getVisitor): Promise<VisitorData> {
    const result = await this.agent.get(options)
    return result
  }
}
