import React, { RefObject, useRef } from 'react';
import { DragLayerMonitor, useDragLayer, XYCoord } from 'react-dnd';
import { DragSource } from '../../typings';
import { Items } from '../../store/items';

interface DragLayerProps {
  data: DragSource;
  currentOffset: XYCoord | null;
  isDragging: boolean;
}

const subtract = (a: XYCoord, b: XYCoord): XYCoord => {
  return {
    x: a.x - b.x,
    y: a.y - b.y,
  };
};

const calculateParentOffset = (monitor: DragLayerMonitor): XYCoord => {
  const client = monitor.getInitialClientOffset();
  const source = monitor.getInitialSourceClientOffset();
  if (client === null || source === null || client.x === undefined || client.y === undefined) {
    return { x: 0, y: 0 };
  }
  return subtract(client, source);
};

export const calculatePointerPosition = (monitor: DragLayerMonitor, childRef: RefObject<Element>): XYCoord | null => {
  const offset = monitor.getClientOffset();
  if (offset === null) {
    return null;
  }

  if (!childRef.current || !childRef.current.getBoundingClientRect) {
    return subtract(offset, calculateParentOffset(monitor));
  }

  const bb = childRef.current.getBoundingClientRect();
  const middle = { x: bb.width / 2, y: bb.height / 2 };
  return subtract(offset, middle);
};

const DragPreview: React.FC = () => {
  const element = useRef<HTMLDivElement>(null);

  const { data, isDragging, currentOffset } = useDragLayer<DragLayerProps>((monitor) => ({
    data: monitor.getItem(),
    currentOffset: calculatePointerPosition(monitor, element),
    isDragging: monitor.isDragging(),
  }));

  const getRarityClass = () => {
    if (!data?.item) return '';
    const rarity = data.item.metadata?.rarity || data.item.rarity || Items[data.item.name]?.rarity;
    return rarity ? `rarity-${rarity}` : '';
  };

  return (
    <>
      {isDragging && currentOffset && data.item && (
        <div
          className="item-drag-preview"
          ref={element}
          style={{
            transform: `translate(${currentOffset.x}px, ${currentOffset.y}px)`,
          }}
        >
          <div 
            className={`item-drag-preview-container ${getRarityClass()}`}
            style={{
              backgroundImage: data.image,
            }}
          />
          <div className="item-drag-preview-label">
            {data.item.metadata?.label ? data.item.metadata.label : Items[data.item.name]?.label || data.item.name}
          </div>
          {data.item.count && data.item.count > 1 && (
            <div className="item-drag-preview-count">
              {data.item.count}
            </div>
          )}
        </div>
      )}
    </>
  );
};

export default DragPreview;
