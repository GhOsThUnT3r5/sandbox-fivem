import React, { useMemo } from 'react';

const colorChannelMixer = (colorChannelA: number, colorChannelB: number, amountToMix: number) => {
  let channelA = colorChannelA * amountToMix;
  let channelB = colorChannelB * (1 - amountToMix);
  return channelA + channelB;
};

const colorMixer = (rgbA: number[], rgbB: number[], amountToMix: number) => {
  let r = colorChannelMixer(rgbA[0], rgbB[0], amountToMix);
  let g = colorChannelMixer(rgbA[1], rgbB[1], amountToMix);
  let b = colorChannelMixer(rgbA[2], rgbB[2], amountToMix);
  return `rgb(${r}, ${g}, ${b})`;
};

const COLORS = {
  // Colors used - https://materialui.co/flatuicolors
  primaryColor: [231, 76, 60], // Red (Pomegranate)
  secondColor: [39, 174, 96], // Green (Nephritis)
  accentColor: [211, 84, 0], // Orange (Oragne)
};

const WeightBar: React.FC<{ percent: number; durability?: boolean; rarity?: number }> = ({ percent, durability, rarity }) => {
  const color = useMemo(
    () => {
      if (durability && rarity) {
        // Use rarity-based colors that match the existing rarity system
        const rarityColors = {
          1: [150, 150, 150], // Common - Gray
          2: [100, 150, 255], // Uncommon - Blue
          3: [150, 100, 255], // Rare - Purple
          4: [255, 215, 0], // Epic - Gold
          5: [255, 215, 0], // Objective - Gold
          6: [255, 100, 100], // Legendary - Red
          7: [128, 0, 32], // Exotic - Burgundy
        };
        
        const baseColor = rarityColors[rarity as keyof typeof rarityColors] || rarityColors[1];
        
        // Create a gradient from red (low) to rarity color (high)
        if (percent < 25) {
          // Very low durability - mostly red
          return colorMixer([231, 76, 60], [180, 60, 60], percent / 25);
        } else if (percent < 50) {
          // Low durability - red to dark rarity color
          const darkRarity = [baseColor[0] * 0.4, baseColor[1] * 0.4, baseColor[2] * 0.4];
          return colorMixer([180, 60, 60], darkRarity, (percent - 25) / 25);
        } else if (percent < 75) {
          // Medium durability - dark to medium rarity color
          const darkRarity = [baseColor[0] * 0.4, baseColor[1] * 0.4, baseColor[2] * 0.4];
          const mediumRarity = [baseColor[0] * 0.7, baseColor[1] * 0.7, baseColor[2] * 0.7];
          return colorMixer(darkRarity, mediumRarity, (percent - 50) / 25);
        } else {
          // High durability - medium to full rarity color
          const mediumRarity = [baseColor[0] * 0.7, baseColor[1] * 0.7, baseColor[2] * 0.7];
          return colorMixer(mediumRarity, baseColor, (percent - 75) / 25);
        }
      }
      
      return durability
        ? percent < 50
          ? colorMixer(COLORS.accentColor, COLORS.primaryColor, percent / 100)
          : colorMixer(COLORS.secondColor, COLORS.accentColor, percent / 100)
        : percent > 50
        ? colorMixer(COLORS.primaryColor, COLORS.accentColor, percent / 100)
        : colorMixer(COLORS.accentColor, COLORS.secondColor, percent / 50);
    },
    [durability, percent, rarity]
  );

  return (
    <div className={durability ? 'durability-bar' : 'weight-bar'}>
      <div
        style={{
          visibility: percent > 0 ? 'visible' : 'hidden',
          height: '100%',
          width: `${percent}%`,
          backgroundColor: color,
          transition: `background ${0.3}s ease, width ${0.3}s ease`,
        }}
      ></div>
    </div>
  );
};
export default WeightBar;
