import { CaseReducer, PayloadAction } from '@reduxjs/toolkit';
import { itemDurability } from '../helpers';
import { inventorySlice } from '../store/inventory';
import { Items } from '../store/items';
import { InventoryType, Slot, State } from '../typings';

export type ItemsPayload = { item: Slot; inventory?: InventoryType };

interface Payload {
  items?: ItemsPayload | ItemsPayload[];
  itemCount?: Record<string, number>;
  weightData?: { inventoryId: string; maxWeight: number };
  slotsData?: { inventoryId: string; slots: number };
}

export const refreshSlotsReducer: CaseReducer<State, PayloadAction<Payload>> = (state, action) => {
  if (action.payload.items) {
    if (!Array.isArray(action.payload.items)) action.payload.items = [action.payload.items];
    const curTime = Math.floor(Date.now() / 1000);

    Object.values(action.payload.items)
      .filter((data) => !!data)
      .forEach((data) => {
        let targetInventory;
        
        if (data.inventory) {
          if (data.inventory === InventoryType.PLAYER) {
            targetInventory = state.leftInventory;
          } else if (data.inventory === InventoryType.CONTAINER || data.inventory === InventoryType.BACKPACK) {
            targetInventory = state.containerInventory;
          } else {
            targetInventory = state.rightInventory;
          }
        } else {
          targetInventory = state.leftInventory;
        }

        data.item.durability = itemDurability(data.item.metadata, curTime);

        while (targetInventory.items.length < data.item.slot) {
          targetInventory.items.push({ slot: targetInventory.items.length + 1 });
        }

        targetInventory.items[data.item.slot - 1] = data.item;

        if (targetInventory === state.leftInventory && data.item.slot <= 5) {
          state.utilityInventory.items[data.item.slot - 1] = data.item;
        }

        if (targetInventory === state.utilityInventory && data.item.slot <= 5) {
          state.leftInventory.items[data.item.slot - 1] = data.item;
        }
      });

    // Janky workaround to force a state rerender for crafting inventory to
    // run canCraftItem checks
    if (state.rightInventory.type === InventoryType.CRAFTING) {
      state.rightInventory = { ...state.rightInventory };
    }
  }

  if (action.payload.itemCount) {
    const items = Object.entries(action.payload.itemCount);

    for (let i = 0; i < items.length; i++) {
      const item = items[i][0];
      const count = items[i][1];

      if (Items[item]!) {
        Items[item]!.count += count;
      }
    }
  }

  // Refresh maxWeight when SetMaxWeight is ran while an inventory is open
  if (action.payload.weightData) {
    const inventoryId = action.payload.weightData.inventoryId;
    const inventoryMaxWeight = action.payload.weightData.maxWeight;
    const inv =
      inventoryId === state.leftInventory.id
        ? 'leftInventory'
        : inventoryId === state.containerInventory.id
        ? 'containerInventory'
        : inventoryId === state.rightInventory.id
        ? 'rightInventory'
        : null;

    if (!inv) return;

    state[inv].maxWeight = inventoryMaxWeight;
  }

  if (action.payload.slotsData) {
    const { inventoryId } = action.payload.slotsData;
    const { slots } = action.payload.slotsData;

    const inv =
      inventoryId === state.leftInventory.id
        ? 'leftInventory'
        : inventoryId === state.containerInventory.id
        ? 'containerInventory'
        : inventoryId === state.rightInventory.id
        ? 'rightInventory'
        : null;

    if (!inv) return;

    state[inv].slots = slots;
  }
};
