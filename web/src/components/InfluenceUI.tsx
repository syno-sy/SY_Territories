import { useState } from 'react';
import { Icon } from '@iconify/react';
import {
  Box,
  Button,
  Portal,
  Stack,
  Text,
  ThemeIcon,
  Transition,
  UnstyledButton,
} from '@mantine/core';
import { useFloatingWindow } from '@mantine/hooks';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { debugData } from '../utils/debugData';
import { fetchNui } from '../utils/fetchNui';
import classes from './WarStatUi.module.css';

/* --- Debug Data --- */
debugData(
  [
    // {
    //   action: 'showInfluenceUi',
    //   data: {
    //     zone: 'East V',
    //     gang: 'SRRA',
    //     gangColor: '255, 0, 0',
    //     influence: 75,
    //   },
    // },
    {
      action: 'getInfluenceUiPosition',
      data: { x: 1493, y: 742.8611068725586 },
    },
    {
      action: 'setInfluenceUiPosition',
      data: {
        zone: 'Chamberlain Hills',
        gang: 'Gang',
        gangColor: '255, 0, 0',
        influence: 75,
      },
    },
  ],
  1000
);

/* --- Utils --- */
// const clamp = (v: number, min: number, max: number) => Math.min(Math.max(v, min), max);
const ViewPort_Padding = 5;
const boxW = 200;
const boxH = 118.15;

/* --- Component --- */
export default function InfluenceUI({ influencePos }: { influencePos: { x: number; y: number } }) {
  const [influenceUiVisible, setInfluenceUiVisible] = useState(false);
  const [canSetPosition, setCanSetPosition] = useState(false);
  const [data, setData] = useState<UiData | null>(null);
  const [influenceUiPosition, setInfluenceUiPosition] = useState({ x: 100, y: 100 });

  const influenceUiFloatingWindow = useFloatingWindow({
    enabled: canSetPosition,
    constrainToViewport: true,
    constrainOffset: ViewPort_Padding,
    initialPosition: { top: influencePos.y || 100, left: influencePos.x || 100 },
    onPositionChange: setInfluenceUiPosition,
  });

  /* --- NUI Events --- */
  useNuiEvent<UiData>('showInfluenceUi', (payload) => {
    setData(payload);
    setInfluenceUiVisible(true);
  });

  useNuiEvent<UiData>('setInfluenceUiPosition', (payload) => {
    setData(payload);
    setCanSetPosition(true);
  });

  useNuiEvent<{ x: number; y: number }>('getInfluenceUiPosition', (payload) => {
    if (payload?.x !== undefined && payload?.y !== undefined) {
      setInfluenceUiPosition({ x: payload.x, y: payload.y });
    }
  });

  useNuiEvent('hideInfluenceUi', () => {
    setInfluenceUiVisible(false);
    setCanSetPosition(false);
  });

  /* --- Save Position --- */
  const savePosition = () => {
    console.log('savePosition', influenceUiPosition);
    fetchNui('setInfluenceUiPositionData', {
      x: influenceUiPosition.x,
      y: influenceUiPosition.y,
    });

    setData(null);
    setCanSetPosition(false);
  };

  if (influenceUiVisible && data) {
    return (
      <Transition mounted={influenceUiVisible} transition="fade" duration={300}>
        {(transitionStyles) => (
          <Portal style={{ ...transitionStyles }}>
            <Box
              ref={influenceUiFloatingWindow.ref}
              className={classes.box}
              p={10}
              w={boxW}
              h={boxH}
              style={{
                position: 'fixed',
                borderRadius: 'var(--mantine-radius-lg)',
                cursor: canSetPosition ? 'move' : 'default',
                transition: 'box-shadow 70ms ease',
                zIndex: 400,
              }}
            >
              <Box>
                <Stack align="center" justify="center" gap="0">
                  <div className={classes.Influence_Inner}>
                    <ThemeIcon size="sm" variant="light" color="yellow" mr={3}>
                      <Icon icon="pepicons-pencil:map" width="70%" height="70%" />
                    </ThemeIcon>
                    <span>Zone</span>
                  </div>
                  <Text ta="center">{data?.zone}</Text>
                </Stack>
              </Box>

              <UnstyledButton className={classes.Influence_}>
                <div className={classes.Influence_Inner}>
                  <ThemeIcon size="sm" variant="light" color="green" mr={3}>
                    <Icon icon="dashicons:shield" width="70%" height="70%" />
                  </ThemeIcon>
                  <span>Gang :</span>
                </div>
                <Text ta="center">{data?.gang}</Text>
              </UnstyledButton>

              <UnstyledButton className={classes.Influence_}>
                <div className={classes.Influence_Inner}>
                  <ThemeIcon size="sm" variant="light" mr={3}>
                    <Icon icon="dashicons:admin-links" width="70%" height="70%" />
                  </ThemeIcon>
                  <span>Influence :</span>
                </div>
                <Text ta="center">{data?.influence}%</Text>
              </UnstyledButton>
            </Box>
          </Portal>
        )}
      </Transition>
    );
  }

  if (canSetPosition)
    return (
      <Portal>
        <Transition mounted={canSetPosition} transition="fade" duration={300}>
          {(transitionStyles) => (
            <Portal style={{ ...transitionStyles, position: 'fixed', inset: 0 }}>
              <Button
                m={10}
                style={{ position: 'absolute', top: 0, right: 0, zIndex: 999999 }}
                onClick={savePosition}
              >
                Set Position
              </Button>
              <Box
                ref={influenceUiFloatingWindow.ref}
                className={classes.box}
                p={10}
                w={boxW}
                h={boxH}
                style={{
                  position: 'fixed',
                  borderRadius: 'var(--mantine-radius-lg)',
                  cursor: canSetPosition ? 'move' : 'default',
                  transition: 'box-shadow 70ms ease',
                  zIndex: 400,
                }}
                data-drag-handle
              >
                <Box>
                  <Stack align="center" justify="center" gap="0">
                    <div className={classes.Influence_Inner}>
                      <ThemeIcon size="sm" variant="light" color="yellow" mr={3}>
                        <Icon icon="pepicons-pencil:map" width="70%" height="70%" />
                      </ThemeIcon>
                      <span>Zone</span>
                    </div>
                    <Text ta="center">{data?.zone}</Text>
                  </Stack>
                </Box>
                <UnstyledButton className={classes.Influence_}>
                  <div className={classes.Influence_Inner}>
                    <ThemeIcon size="sm" variant="light" color="green" mr={3}>
                      <Icon icon="dashicons:shield" width="70%" height="70%" />
                    </ThemeIcon>
                    <span>Gang :</span>
                  </div>
                  <Text ta="center">{data?.gang}</Text>
                </UnstyledButton>
                <UnstyledButton className={classes.Influence_}>
                  <div className={classes.Influence_Inner}>
                    <ThemeIcon size="sm" variant="light" mr={3}>
                      <Icon icon="dashicons:admin-links" width="70%" height="70%" />
                    </ThemeIcon>
                    <span>Influence :</span>
                  </div>
                  <Text ta="center">{data?.influence}%</Text>
                </UnstyledButton>
              </Box>
            </Portal>
          )}
        </Transition>
      </Portal>
    );
}
