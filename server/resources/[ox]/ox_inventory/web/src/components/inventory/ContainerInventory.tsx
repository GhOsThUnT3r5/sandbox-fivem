import React, { useMemo } from 'react';
import InventorySlot from './InventorySlot';
import { useAppSelector, useAppDispatch } from '../../store';
import {
  selectContainerInventory,
  selectContainerInventoryCollapsed,
  toggleContainerInventory,
} from '../../store/inventory';
import { getTotalWeight } from '../../helpers';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faChevronUp, faChevronDown } from '@fortawesome/free-solid-svg-icons';

const ContainerInventory: React.FC = () => {
  const containerInventory = useAppSelector(selectContainerInventory);
  const isCollapsed = useAppSelector(selectContainerInventoryCollapsed);
  const dispatch = useAppDispatch();

  const totalWeight = useMemo(
    () => (containerInventory.maxWeight !== undefined ? Math.floor(getTotalWeight(containerInventory.items) * 1000) / 1000 : 0),
    [containerInventory.maxWeight, containerInventory.items]
  );

  // Don't render if no container/backpack is open
  if (!containerInventory.id || !containerInventory.items || containerInventory.items.length === 0) {
    return null;
  }

  const collapseButton = (
    <button className="inventory-collapse-button" onClick={() => dispatch(toggleContainerInventory())}>
      <FontAwesomeIcon icon={isCollapsed ? faChevronDown : faChevronUp} size="lg" />
    </button>
  );

  return (
    <div className={`inventory-grid-wrapper container-inventory ${isCollapsed ? 'collapsed' : ''}`}>
      <div>
        <div className="inventory-grid-header-wrapper">
          <div className="inventory-header-content">
            <p>{containerInventory.label}</p>
            <div className="inventory-header-right">
              {containerInventory.maxWeight && (
                <p>
                  {Math.round((totalWeight / 1000) * 10) / 10}/{Math.round((containerInventory.maxWeight / 1000) * 10) / 10}
                  kg
                </p>
              )}
              {collapseButton}
            </div>
          </div>
        </div>
      </div>
      <div className={`inventory-grid-container ${isCollapsed ? 'collapsed' : ''}`}>
        {containerInventory.items.map((item) => (
          <InventorySlot
            key={`container-${item.slot}`}
            item={item}
            inventoryType={containerInventory.type}
            inventoryGroups={containerInventory.groups}
            inventoryId={containerInventory.id}
          />
        ))}
      </div>
    </div>
  );
};

export default ContainerInventory;

