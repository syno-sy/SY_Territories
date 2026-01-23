import { useState } from 'react';
import { useDraggable } from '@dnd-kit/core';
import { CSS } from '@dnd-kit/utilities';
import { Icon } from '@iconify/react';
import { Box, Button, Text, ThemeIcon, Transition, UnstyledButton } from '@mantine/core';
import { useViewportSize } from '@mantine/hooks';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { debugData } from '../utils/debugData';
import { fetchNui } from '../utils/fetchNui';
import classes from './WarStatUi.module.css';

/* --- Debug Data --- */
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
    {
      action: 'setInfluenceUiPosition',
      data: {
        zone: 'Zone',
        gang: 'Gang',
        gangColor: '255, 0, 0',
        influence: 75,
      },
    },
  ],
  1000
);

const BOX_WIDTH = 210;
const BOX_HEIGHT = 107.5;

const clamp = (v: number, min: number, max: number) => Math.min(Math.max(v, min), max);

export default function InfluenceUI({ position }: InfluenceUIProps) {
  const [visible, setVisible] = useState(false);
  const [canSetPosition, setCanSetPosition] = useState(false);
  const [data, setData] = useState<UiData | null>(null);
  const { width, height } = useViewportSize();

  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({
    id: 'influence-ui-box',
    disabled: !canSetPosition,
  });

  useNuiEvent<UiData>('showInfluenceUi', (payload) => {
    setData(payload);
    setVisible(true);
  });

  useNuiEvent('setInfluenceUiPosition', (payload) => {
    setData(payload);
    setVisible(true);
    setCanSetPosition(true);
  });

  useNuiEvent('hideInfluenceUi', () => {
    setVisible(false);
    setCanSetPosition(false);
  });

  const x = position.x + (transform?.x ?? 0);
  const y = position.y + (transform?.y ?? 0);

  const clampedX = clamp(x, 0, width - BOX_WIDTH);
  const clampedY = clamp(y, 0, height - BOX_HEIGHT);

  const style = {
    transform: CSS.Transform.toString({
      x: clampedX,
      y: clampedY,
      scaleX: 1,
      scaleY: 1,
    }),
    borderRadius: 'var(--mantine-radius-lg)',
    cursor: canSetPosition ? (isDragging ? 'grabbing' : 'grab') : 'default',
    position: 'fixed' as const,
  };

  return (
    <Transition mounted={visible} transition="fade" duration={300}>
      {(transitionStyles) => (
        <div style={{ ...transitionStyles, position: 'fixed', inset: 0 }}>
          {canSetPosition && (
            <Button
              m={10}
              style={{ position: 'absolute', top: 0, right: 0, zIndex: 999 }}
              onClick={() => {
                setCanSetPosition(false);
                setVisible(false);
                fetchNui('setInfluenceUiPositionData', {
                  x: clampedX,
                  y: clampedY,
                });
              }}
            >
              Set Position
            </Button>
          )}

          <Box
            ref={setNodeRef}
            {...listeners}
            {...attributes}
            className={classes.box}
            p={10}
            w={200}
            h={96.5}
            style={style}
          >
            <UnstyledButton className={classes.Influence_}>
              <div className={classes.Influence_Inner}>
                <ThemeIcon size="sm" variant="light" color="red" mr={3}>
                  <Icon icon="pepicons-pencil:map" width="70%" height="70%" />
                </ThemeIcon>
                <span>Zone :</span>
              </div>
              <Text ta="center">{data?.zone}</Text>
            </UnstyledButton>

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
        </div>
      )}
    </Transition>
  );
}
