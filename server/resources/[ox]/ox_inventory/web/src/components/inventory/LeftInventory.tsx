import React, { useMemo } from 'react';
import InventorySlot from './InventorySlot';
import WeightBar from '../utils/WeightBar';
import { useAppSelector, useAppDispatch } from '../../store';
import {
  selectLeftInventory,
  selectLeftInventoryCollapsed,
  toggleLeftInventory,
} from '../../store/inventory';
import { getTotalWeight } from '../../helpers';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faChevronUp, faChevronDown } from '@fortawesome/free-solid-svg-icons';

const LeftInventory: React.FC = () => {
  const leftInventory = useAppSelector(selectLeftInventory);
  const isCollapsed = useAppSelector(selectLeftInventoryCollapsed);
  const dispatch = useAppDispatch();

  const totalWeight = useMemo(
    () => (leftInventory.maxWeight !== undefined ? Math.floor(getTotalWeight(leftInventory.items) * 1000) / 1000 : 0),
    [leftInventory.maxWeight, leftInventory.items]
  );

  const weightPercentage = useMemo(
    () => (leftInventory.maxWeight ? (totalWeight / leftInventory.maxWeight) * 100 : 0),
    [totalWeight, leftInventory.maxWeight]
  );

  const modifiedInventory = {
    ...leftInventory,
    items: leftInventory.items.slice(9),
    slots: Math.max(0, leftInventory.slots),
  };

  const collapseButton = (
    <button className="inventory-collapse-button" onClick={() => dispatch(toggleLeftInventory())}>
      <FontAwesomeIcon icon={isCollapsed ? faChevronDown : faChevronUp} size="lg" />
    </button>
  );

  return (
    <div className={`inventory-grid-wrapper left-inventory ${isCollapsed ? 'collapsed' : ''}`}>
      <div>
        <div className="inventory-grid-header-wrapper">
          <div className="inventory-header-content">
            <p>{leftInventory.label}</p>
            <div className="inventory-header-right">
              {leftInventory.maxWeight && (
                <p>
                  {Math.round((totalWeight / 1000) * 10) / 10}/{Math.round((leftInventory.maxWeight / 1000) * 10) / 10}
                  kg
                </p>
              )}
              {collapseButton}
            </div>
          </div>
        </div>
        {leftInventory.maxWeight && <WeightBar percent={weightPercentage} />}
      </div>
      <div className={`inventory-grid-container ${isCollapsed ? 'collapsed' : ''}`}>
        {modifiedInventory.items.map((item, index) => (
          <InventorySlot
            key={`left-${item.slot}`}
            item={item}
            inventoryType={leftInventory.type}
            inventoryGroups={leftInventory.groups}
            inventoryId={leftInventory.id}
          />
        ))}
      </div>
    </div>
  );
};

export default LeftInventory;
