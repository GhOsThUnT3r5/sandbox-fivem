import { Inventory } from './inventory';
import { Slot, SlotWithItem } from './slot';

export type DragSource = {
  item: Pick<SlotWithItem, 'slot' | 'name' | 'rarity' | 'metadata' | 'count'>;
  inventory: Inventory['type'];
  image?: string;
};

export type DropTarget = {
  item: Pick<Slot, 'slot'>;
  inventory: Inventory['type'];
};
