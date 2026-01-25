import { useState } from 'react';
import { useDraggable } from '@dnd-kit/core';
import { CSS } from '@dnd-kit/utilities';
import { Icon } from '@iconify/react';
import { Box, Button, Stack, Text, ThemeIcon, Transition, UnstyledButton } from '@mantine/core';
import { useViewportSize } from '@mantine/hooks';
import { useNuiEvent } from '../hooks/useNuiEvent';
// import { debugData } from '../utils/debugData';
import { fetchNui } from '../utils/fetchNui';
import classes from './WarStatUi.module.css';

/* --- Debug Data --- */
// debugData(
//   [
//     {
//       action: 'showInfluenceUi',
//       data: {
//         zone: 'East V',
//         gang: 'SRRA',
//         gangColor: '255, 0, 0',
//         influence: 75,
//       },
//     },
//     {
//       action: 'setInfluenceUiPosition',
//       data: {
//         zone: 'Chamberlain Hills',
//         gang: 'Gang',
//         gangColor: '255, 0, 0',
//         influence: 75,
//       },
//     },
//   ],
//   1000
// );

/* --- Utils --- */
const clamp = (v: number, min: number, max: number) => Math.min(Math.max(v, min), max);
const ViewPort_Padding = 5;
const boxW = 200;
const boxH = 118.15;

/* --- Component --- */
export default function InfluenceUI({ position }: InfluenceUIProps) {
  const [visible, setVisible] = useState(false);
  const [canSetPosition, setCanSetPosition] = useState(false);
  const [data, setData] = useState<UiData | null>(null);

  const { width: viewportW, height: viewportH } = useViewportSize();

  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({
    id: 'influence-ui-box',
    disabled: !canSetPosition,
  });

  const setRefs = (el: HTMLDivElement | null) => {
    setNodeRef(el);
  };
  /* --- NUI Events --- */
  useNuiEvent<UiData>('showInfluenceUi', (payload) => {
    setData(payload);
    setVisible(true);
  });

  useNuiEvent<UiData>('setInfluenceUiPosition', (payload) => {
    setData(payload);
    // setVisible(true);
    setCanSetPosition(true);
  });

  useNuiEvent('hideInfluenceUi', () => {
    setVisible(false);
    setCanSetPosition(false);
  });

  const clampedTransform = {
    x: clamp(
      transform?.x ?? 0,
      ViewPort_Padding - position.x,
      viewportW - boxW - position.x - ViewPort_Padding
    ),
    y: clamp(
      transform?.y ?? 0,
      ViewPort_Padding - position.y,
      viewportH - boxH - position.y - ViewPort_Padding
    ),
  };

  const style = {
    position: 'fixed' as const,
    left: position.x,
    top: position.y,
    transform: CSS.Transform.toString({
      x: clampedTransform.x,
      y: clampedTransform.y,
      scaleX: 1,
      scaleY: 1,
    }),
    color: 'var(--mantine-color-white)',
    borderRadius: 'var(--mantine-radius-lg)',
    cursor: canSetPosition ? (isDragging ? 'grabbing' : 'grab') : 'default',
  };

  /* --- Save Position --- */
  const savePosition = () => {
    const finalX = clamp(
      position.x + (transform?.x ?? 0),
      ViewPort_Padding,
      viewportW - boxW - ViewPort_Padding
    );

    const finalY = clamp(
      position.y + (transform?.y ?? 0),
      ViewPort_Padding,
      viewportH - boxH - ViewPort_Padding
    );

    fetchNui('setInfluenceUiPositionData', {
      x: finalX,
      y: finalY,
    });

    // setVisible(false);
    setData(null);
    setCanSetPosition(false);
  };

  if (visible && data) {
    return (
      <Transition mounted={visible} transition="fade" duration={300}>
        {(transitionStyles) => (
          <div style={{ ...transitionStyles, position: 'fixed', inset: 0 }}>
            <Box className={classes.box} p={10} style={style} w={boxW} h={boxH}>
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
          </div>
        )}
      </Transition>
    );
  }

  if (canSetPosition)
    return (
      <>
        <Transition mounted={canSetPosition} transition="fade" duration={300}>
          {(transitionStyles) => (
            <div style={{ ...transitionStyles, position: 'fixed', inset: 0 }}>
              {canSetPosition && (
                <>
                  <Button
                    m={10}
                    style={{ position: 'absolute', top: 0, right: 0, zIndex: 999 }}
                    onClick={savePosition}
                  >
                    Set Position
                  </Button>
                  <Box
                    ref={setRefs}
                    {...listeners}
                    {...attributes}
                    className={classes.box}
                    p={10}
                    style={style}
                    w={boxW}
                    h={boxH}
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
                </>
              )}
            </div>
          )}
        </Transition>
      </>
    );
}
