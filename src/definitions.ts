import type { LoadOptions } from '@fingerprintjs/fingerprintjs-pro';

import type { Tags, VisitorData } from './types';

export type VisitorId = string
export interface getVisitor {
  tags?: Tags;
  linkedId?: string;
}
export interface CapacitorFingerprintPlugin {
  load(options: LoadOptions): Promise<void>;
  getVisitorId(options: getVisitor): Promise<VisitorId>;
  getVisitorData(options: getVisitor): Promise<VisitorData>;

}
