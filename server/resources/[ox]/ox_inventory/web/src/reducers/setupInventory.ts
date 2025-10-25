import { CaseReducer, PayloadAction } from '@reduxjs/toolkit';
import { getItemData, itemDurability } from '../helpers';
import { Items } from '../store/items';
import { Inventory, State } from '../typings';

export const setupInventoryReducer: CaseReducer<
  State,
  PayloadAction<{
    leftInventory?: Inventory;
    containerInventory?: Inventory;
    rightInventory?: Inventory;
  }>
> = (state, action) => {
  const { leftInventory, containerInventory, rightInventory } = action.payload;
  const curTime = Math.floor(Date.now() / 1000);

  // Allow partial updates (e.g., just updating container)
  if (!leftInventory && !rightInventory && containerInventory !== undefined) {
    // This is just a container update, skip the normal checks
  } else {
    if (
      leftInventory &&
      rightInventory &&
      state.leftInventory &&
      state.rightInventory &&
      state.leftInventory.id === leftInventory.id &&
      state.rightInventory.id === rightInventory.id
    ) {
      return;
    }

    if (rightInventory && !leftInventory && state.rightInventory && state.rightInventory.id === rightInventory.id) {
      return;
    }

    if (leftInventory && !rightInventory && state.leftInventory && state.leftInventory.id === leftInventory.id) {
      return;
    }
  }

  if (leftInventory) {
    const isShop = leftInventory.type === 'shop';
    const actualSlots = isShop ? Object.keys(leftInventory.items).length : leftInventory.slots;

    const isNewInventory = !state.leftInventory || state.leftInventory.id !== leftInventory.id;

    if (isNewInventory) {
      state.leftInventory = {
        ...leftInventory,
        slots: actualSlots,
        items: Array.from(Array(actualSlots), (_, index) => {
          const slotNumber = index + 1;

          let item;
          if (Array.isArray(leftInventory.items)) {
            item = leftInventory.items.find((item) => item && item.slot === slotNumber) || { slot: slotNumber };
          } else {
            item = leftInventory.items[slotNumber] || { slot: slotNumber };
          }

          if (!item.name) return item;

          if (typeof Items[item.name] === 'undefined') {
            getItemData(item.name);
          }

          item.durability = itemDurability(item.metadata, curTime);
          return item;
        }),
      };
    } else {
      state.leftInventory = {
        ...state.leftInventory,
        ...leftInventory,
        items: state.leftInventory.items,
      };
    }
  }

  if (rightInventory) {
    const isShop = rightInventory.type === 'shop';
    const actualSlots = isShop ? Object.keys(rightInventory.items).length : rightInventory.slots;

    const isNewInventory = !state.rightInventory || state.rightInventory.id !== rightInventory.id;

    const hasExistingItems =
      state.rightInventory &&
      state.rightInventory.items &&
      state.rightInventory.items.some((item) => item && item.name);

    const isInventoryTransition = state.rightInventory && state.rightInventory.type !== rightInventory.type;

    const shouldPreserve =
      !isNewInventory || (state.rightInventory && state.rightInventory.id === rightInventory.id && hasExistingItems);

    if (shouldPreserve) {
      const cleanedItems = Array.from(Array(actualSlots), (_, index) => {
        const slotNumber = index + 1;

        let item = state.rightInventory.items.find((item) => item && item.slot === slotNumber);

        if (!item && state.rightInventory.items[index]) {
          item = state.rightInventory.items[index];
        }

        if (!item || !item.name || item.name === '') {
          return { slot: slotNumber };
        }

        const cleanedItem = {
          ...item,
          slot: slotNumber,
          durability: itemDurability(item.metadata, curTime),
        };

        if (typeof Items[item.name] === 'undefined') {
          getItemData(item.name);
        }

        return cleanedItem;
      });

      state.rightInventory = {
        ...state.rightInventory,
        ...rightInventory,
        items: cleanedItems,
      };
    } else if (isNewInventory) {
      if (isInventoryTransition) {
        if (rightInventory.type === 'drop' && hasExistingItems) {
          const cleanedItems = Array.from(Array(actualSlots), (_, index) => {
            const slotNumber = index + 1;

            let item = state.rightInventory.items.find((item) => item && item.slot === slotNumber);

            if (!item && state.rightInventory.items[index]) {
              item = state.rightInventory.items[index];
            }

            if (!item || !item.name || item.name === '') {
              return { slot: slotNumber };
            }

            const cleanedItem = {
              ...item,
              slot: slotNumber,
              durability: itemDurability(item.metadata, curTime),
            };

            if (typeof Items[item.name] === 'undefined') {
              getItemData(item.name);
            }

            return cleanedItem;
          });

          state.rightInventory = {
            ...state.rightInventory,
            ...rightInventory,
            items: cleanedItems,
            slots: actualSlots,
          };

          return;
        }
      }

      state.rightInventory = {
        ...rightInventory,
        slots: actualSlots,
        items: Array.from(Array(actualSlots), (_, index) => {
          const slotNumber = index + 1;

          let item;
          if (Array.isArray(rightInventory.items)) {
            item = rightInventory.items.find((item) => item && item.slot === slotNumber) || { slot: slotNumber };
          } else {
            item = rightInventory.items[slotNumber] || { slot: slotNumber };
          }

          if (!item.name) return item;

          if (typeof Items[item.name] === 'undefined') {
            getItemData(item.name);
          }

          item.durability = itemDurability(item.metadata, curTime);
          return item;
        }),
      };
    } else {
      const cleanedItems = Array.from(Array(actualSlots), (_, index) => {
        const slotNumber = index + 1;

        let item = state.rightInventory.items.find((item) => item && item.slot === slotNumber);

        if (!item && state.rightInventory.items[index]) {
          item = state.rightInventory.items[index];
        }

        if (!item || !item.name || item.name === '') {
          return { slot: slotNumber };
        }

        const cleanedItem = {
          ...item,
          slot: slotNumber,
          durability: itemDurability(item.metadata, curTime),
        };

        if (typeof Items[item.name] === 'undefined') {
          getItemData(item.name);
        }

        return cleanedItem;
      });

      state.rightInventory = {
        ...state.rightInventory,
        ...rightInventory,
        items: cleanedItems,
      };
    }
  }

  if (containerInventory) {
    const actualSlots = containerInventory.slots;
    const isNewInventory = !state.containerInventory || state.containerInventory.id !== containerInventory.id;

    if (isNewInventory) {
      state.containerInventory = {
        ...containerInventory,
        slots: actualSlots,
        items: Array.from(Array(actualSlots), (_, index) => {
          const slotNumber = index + 1;

          let item;
          if (Array.isArray(containerInventory.items)) {
            item = containerInventory.items.find((item) => item && item.slot === slotNumber) || { slot: slotNumber };
          } else {
            item = containerInventory.items[slotNumber] || { slot: slotNumber };
          }

          if (!item.name) return item;

          if (typeof Items[item.name] === 'undefined') {
            getItemData(item.name);
          }

          item.durability = itemDurability(item.metadata, curTime);
          return item;
        }),
      };
    } else {
      state.containerInventory = {
        ...state.containerInventory,
        ...containerInventory,
        items: state.containerInventory.items,
      };
    }
  } else {
    // Clear container inventory if not provided or empty
    if (state.containerInventory && state.containerInventory.id) {
      state.containerInventory = {
        id: '',
        type: '',
        slots: 0,
        maxWeight: 0,
        items: [],
      };
    }
  }

  if (leftInventory) {
    state.utilityInventory = {
      ...state.utilityInventory,
      id: leftInventory.id,
      type: leftInventory.type,
      items: Array.from(Array(9), (_, index) => {
        const slotNumber = index + 1;
        const item = leftInventory.items[slotNumber] || { slot: slotNumber };

        if (!item.name) return item;

        if (typeof Items[item.name] === 'undefined') {
          getItemData(item.name);
        }

        item.durability = itemDurability(item.metadata, curTime);
        return item;
      }),
    };
  }

  state.shiftPressed = false;
  state.isBusy = false;
};
