import { Inventory } from './inventory';

export type State = {
  leftInventory: Inventory;
  containerInventory: Inventory;
  rightInventory: Inventory;
  utilityInventory: Inventory;
  currentView: 'normal' | 'utility';
  itemAmount: number;
  shiftPressed: boolean;
  isBusy: boolean;
  leftInventoryCollapsed: boolean;
  containerInventoryCollapsed: boolean;
  rightInventoryCollapsed: boolean;
  additionalMetadata: Array<{ metadata: string; value: string }>;
  history?: {
    leftInventory: Inventory;
    containerInventory: Inventory;
    rightInventory: Inventory;
  };
};
