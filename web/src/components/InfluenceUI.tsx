import { useState } from 'react';
import { Icon } from '@iconify/react';
import { Box, Text, ThemeIcon, UnstyledButton } from '@mantine/core';
import { useMove, useViewportSize } from '@mantine/hooks';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { debugData } from '../utils/debugData';
import classes from './WarStatUi.module.css';

/* ------------------------------------------------------------------ */
/* Debug */
/* ------------------------------------------------------------------ */
debugData(
  [
    {
      action: 'showInfluenceUi',
      data: {
        zone: 'East V',
        gang: 'SRRA',
        gangColor: '255, 0, 0',
        influence: 75,
      },
    },
  ],
  10
);

export default function InfluenceUI() {
  const [visible, setVisible] = useState(false);
  const { width, height } = useViewportSize();
  const [data, setData] = useState<UiData | null>(null);
  //   move
  const [value, setValue] = useState({ x: 1, y: 1 });
  const { ref } = useMove(setValue);

  useNuiEvent('showInfluenceUi', (payload) => {
    setVisible(true);
    setData({
      zone: payload.zone,
      gang: payload.gang,
      gangColor: payload.gangColor,
      influence: payload.influence,
    });
  });

  useNuiEvent('hideInfluenceUi', () => {
    setVisible(false);
    setData(null);
  });

  if (!visible || !data) return null;

  return (
    <div
      ref={ref}
      style={{
        height: height - 107.5,
        width: width - 210,
        position: 'fixed',
        inset: 0,
        display: 'flex',
      }}
    >
      <Box
        className={classes.box}
        p={10}
        m={5}
        h={96.5}
        w={200}
        style={{
          borderRadius: `var(--mantine-radius-lg)`,
          position: 'absolute',
          left: `calc(${value.x * 100}%)`,
          top: `calc(${value.y * 100}%)`,
        }}
      >
        {/* <Paper p={5} bg={'none'} c={'white'}> */}
        <UnstyledButton className={classes.Influence_}>
          <div className={classes.Influence_Inner}>
            <ThemeIcon size={'sm'} variant="light" color="red" mr={3}>
              <Icon icon="pepicons-pencil:map" width="70%" height="70%" />
            </ThemeIcon>
            <span>Zone :</span>
          </div>
          <Text h={'100%'} ta={'center'}>
            {data.zone}
          </Text>
        </UnstyledButton>
        <UnstyledButton className={classes.Influence_}>
          <div className={classes.Influence_Inner}>
            <ThemeIcon size={'sm'} variant="light" mr={3} color={'green'}>
              <Icon icon="dashicons:shield" width="70%" height="70%" />
            </ThemeIcon>
            <span>Gang :</span>
          </div>
          <Text h={'100%'} ta={'center'}>
            {data.gang}
          </Text>
        </UnstyledButton>
        <UnstyledButton className={classes.Influence_}>
          <div className={classes.Influence_Inner}>
            <ThemeIcon size={'sm'} variant="light" mr={3}>
              <Icon icon="dashicons:admin-links" width="70%" height="70%" />
            </ThemeIcon>
            <span>Influence :</span>
          </div>
          <Text h={'100%'} ta={'center'}>
            {data.influence}%
          </Text>
        </UnstyledButton>
        {/* </Paper> */}
      </Box>
    </div>
  );
}
