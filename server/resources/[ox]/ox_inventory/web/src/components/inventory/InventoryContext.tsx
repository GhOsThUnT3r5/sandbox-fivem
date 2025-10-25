import { onUse } from '../../dnd/onUse';
import { onGive } from '../../dnd/onGive';
import { onDrop } from '../../dnd/onDrop';
import { Items } from '../../store/items';
import { fetchNui } from '../../utils/fetchNui';
import { Locale } from '../../store/locale';
import { isSlotWithItem, findAvailableSlot } from '../../helpers';
import { setClipboard } from '../../utils/setClipboard';
import { useAppSelector } from '../../store';
import React, { useState } from 'react';
import { Menu, MenuItem } from '../utils/menu/Menu';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faCopy, faHammer, faHandHolding, faTrash, faHandPointUp, faCut } from '@fortawesome/free-solid-svg-icons';
import { IconProp } from '@fortawesome/fontawesome-svg-core';

interface DataProps {
  action: string;
  component?: string;
  slot?: number;
  serial?: string;
  id?: number;
}

interface Button {
  label: string;
  index: number;
  group?: string;
  icon?: IconProp;
}

interface Group {
  groupName: string | null;
  buttons: ButtonWithIndex[];
}

interface ButtonWithIndex extends Button {
  index: number;
}

interface GroupedButtons extends Array<Group> {}

const InventoryContext: React.FC = () => {
  const contextMenu = useAppSelector((state) => state.contextMenu);
  const item = contextMenu.item;
  const leftInventory = useAppSelector((state) => state.inventory.leftInventory);
  const [showSplitDialog, setShowSplitDialog] = useState(false);
  const [splitAmount, setSplitAmount] = useState(1);

  const canDropItem = () => {
    if (!item || !isSlotWithItem(item)) return false;

    const itemData = Items[item.name];
    if (!itemData) return false;

    try {
      const availableSlot = findAvailableSlot(item, itemData, leftInventory.items, 'player');
      return availableSlot !== undefined;
    } catch (error) {
      return false;
    }
  };

  const handleClick = (data: DataProps) => {
    if (!item) return;

    switch (data && data.action) {
      case 'use':
        onUse({ name: item.name, slot: item.slot });
        break;
      case 'give':
        onGive({ name: item.name, slot: item.slot });
        break;
      case 'drop':
        if (isSlotWithItem(item) && canDropItem()) {
          onDrop({ item: item, inventory: 'player' });
        }
        break;
      case 'split':
        setShowSplitDialog(true);
        break;
      case 'remove':
        fetchNui('removeComponent', { component: data?.component, slot: data?.slot });
        break;
      case 'removeAmmo':
        fetchNui('removeAmmo', item.slot);
        break;
      case 'copy':
        setClipboard(data.serial || '');
        break;
      case 'custom':
        fetchNui('useButton', { id: (data?.id || 0) + 1, slot: item.slot });
        break;
    }
  };

  const handleSplit = async () => {
    if (!item || !isSlotWithItem(item)) return;
    
    try {
      // Find an empty slot in main inventory (slots 10+), not utility slots (1-9)
      const emptySlot = leftInventory.items.findIndex((slot, index) => !slot.name && index >= 9);
      if (emptySlot === -1) {
        setShowSplitDialog(false);
        return;
      }

      // Call backend to split the item
      await fetchNui('swapItems', {
        fromSlot: item.slot,
        fromType: 'player',
        toSlot: emptySlot + 1,
        toType: 'player',
        count: splitAmount,
      });
      
      setShowSplitDialog(false);
      setSplitAmount(1);
    } catch (error) {
      setShowSplitDialog(false);
    }
  };

  const groupButtons = (buttons: any): GroupedButtons => {
    return buttons.reduce((groups: Group[], button: Button, index: number) => {
      if (button.group) {
        const groupIndex = groups.findIndex((group) => group.groupName === button.group);
        if (groupIndex !== -1) {
          groups[groupIndex].buttons.push({ ...button, index });
        } else {
          groups.push({
            groupName: button.group,
            buttons: [{ ...button, index }],
          });
        }
      } else {
        groups.push({
          groupName: null,
          buttons: [{ ...button, index }],
        });
      }
      return groups;
    }, []);
  };

  return (
    <>
      <Menu>
        <MenuItem
          onClick={() => handleClick({ action: 'use' })}
          label={Locale.ui_use || 'Use'}
          icon={<FontAwesomeIcon icon={faHandPointUp} />}
        />
        <MenuItem
          onClick={() => handleClick({ action: 'give' })}
          label={Locale.ui_give || 'Give'}
          icon={<FontAwesomeIcon icon={faHandHolding} />}
        />
        <MenuItem
          onClick={() => handleClick({ action: 'drop' })}
          label={Locale.ui_drop || 'Drop'}
          icon={<FontAwesomeIcon icon={faTrash} />}
          disabled={!canDropItem()}
        />
        {item && isSlotWithItem(item) && item.count && item.count > 1 && (
          <MenuItem
            onClick={() => handleClick({ action: 'split' })}
            label={Locale.ui_split || 'Split'}
            icon={<FontAwesomeIcon icon={faCut} />}
          />
        )}
        {item && item.metadata?.ammo > 0 && (
          <MenuItem
            onClick={() => handleClick({ action: 'removeAmmo' })}
            label={Locale.ui_remove_ammo}
            icon={<FontAwesomeIcon icon={faTrash} />}
          />
        )}
        {item && item.metadata?.serial && (
          <MenuItem
            onClick={() => handleClick({ action: 'copy', serial: item.metadata?.serial })}
            label={Locale.ui_copy}
            icon={<FontAwesomeIcon icon={faCopy} />}
          />
        )}
        {item && item.metadata?.components && item.metadata?.components.length > 0 && (
          <Menu label={Locale.ui_removeattachments}>
            {item &&
              item.metadata?.components.map((component: string, index: number) => (
                <MenuItem
                  key={index}
                  onClick={() => handleClick({ action: 'remove', component, slot: item.slot })}
                  label={Items[component]?.label || ''}
                  icon={<FontAwesomeIcon icon={faHammer} />}
                />
              ))}
          </Menu>
        )}
        {((item && item.name && Items[item.name]?.buttons?.length) || 0) > 0 && (
          <>
            {item &&
              item.name &&
              groupButtons(Items[item.name]?.buttons).map((group: Group, index: number) => (
                <React.Fragment key={index}>
                  {group.groupName ? (
                    <Menu label={group.groupName}>
                      {group.buttons.map((button: Button) => (
                        <MenuItem
                          key={button.index}
                          onClick={() => handleClick({ action: 'custom', id: button.index })}
                          label={button.label}
                          icon={<FontAwesomeIcon icon={button.icon as IconProp} />}
                        />
                      ))}
                    </Menu>
                  ) : (
                    group.buttons.map((button: Button) => (
                      <MenuItem
                        key={button.index}
                        onClick={() => handleClick({ action: 'custom', id: button.index })}
                        label={button.label}
                        icon={<FontAwesomeIcon icon={button.icon as IconProp} />}
                      />
                    ))
                  )}
                </React.Fragment>
              ))}
          </>
        )}
      </Menu>
      {showSplitDialog && item && isSlotWithItem(item) && (
        <div className="split-dialog-overlay" onClick={() => setShowSplitDialog(false)}>
          <div className="split-dialog" onClick={(e) => e.stopPropagation()}>
            <div className="split-dialog-header">
              <h3>{Locale.ui_split || 'Split'} {Items[item.name]?.label || item.name}</h3>
            </div>
            <div className="split-dialog-content">
              <p>Amount: {splitAmount} / {item.count}</p>
              <input
                type="range"
                min="1"
                max={item.count - 1}
                value={splitAmount}
                onChange={(e) => setSplitAmount(parseInt(e.target.value))}
                className="split-slider"
              />
              <input
                type="number"
                min="1"
                max={item.count - 1}
                value={splitAmount}
                onChange={(e) => setSplitAmount(Math.min(Math.max(1, parseInt(e.target.value) || 1), item.count - 1))}
                className="split-input"
              />
            </div>
            <div className="split-dialog-actions">
              <button onClick={() => setShowSplitDialog(false)} className="split-button split-cancel">
                Cancel
              </button>
              <button onClick={handleSplit} className="split-button split-confirm">
                Split
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default InventoryContext;
