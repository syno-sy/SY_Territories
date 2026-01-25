import { useMemo, useState } from 'react';
import { useDraggable } from '@dnd-kit/core';
import { CSS } from '@dnd-kit/utilities';
import { RingsProgress } from '@gfazioli/mantine-rings-progress';
import { Icon } from '@iconify/react';
import {
  ActionIcon,
  Box,
  Button,
  Group,
  Paper,
  Progress,
  Stack,
  Text,
  ThemeIcon,
  Transition,
} from '@mantine/core';
import { useViewportSize } from '@mantine/hooks';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { debugData } from '../utils/debugData';
import { fetchNui } from '../utils/fetchNui';
import classes from './WarStatUi.module.css';

/* ------------------------------------------------------------------ */
/* Debug */
/* ------------------------------------------------------------------ */

debugData(
  [
    {
      action: 'setWarStatUiPosition',
      data: {
        zone: 'East V',
        gang: 'SRRA',
        gangColor: '255, 0, 0',
        influence: 75,
      },
    },
    {
      action: 'setUiData',
      data: {
        zone: 'East V',
        gang: 'SRRA',
        gangColor: '255, 0, 0',
        influence: 75,
      },
    },
    {
      action: 'setGangStatus',
      data: [
        { code: 'defender', gang: 'TVA', value: 10, max: 20 },
        { code: 'attacker', gang: 'KVA', value: 8, max: 20 },
      ],
    },
    {
      action: 'setTimerData',
      data: { minutes: 2, seconds: 59, total: 200 },
    },
  ],
  10
);

const clamp = (v: number, min: number, max: number) => Math.min(Math.max(v, min), max);
const ViewPort_Padding = 5;
const boxW = 280;
const boxH = 161.17;

export default function AppComp({ position }: { position: { x: number; y: number } }) {
  const [warUivisible, setWarUiVisible] = useState(false);
  const [canSetPosition, setCanSetPosition] = useState(false);

  const [uiData, setUiData] = useState<any>(null);
  const [gangStatus, setGangStatus] = useState<any[]>([]);
  const [timerData, setTimerData] = useState<any>(null);

  const { width: viewportW, height: viewportH } = useViewportSize();

  const { attributes, listeners, setNodeRef, transform, isDragging } = useDraggable({
    id: 'war-stat-ui',
    disabled: !canSetPosition,
  });

  /* --- NUI Events --- */
  useNuiEvent('setWarStatVisible', (data) => setWarUiVisible(data.visible));
  useNuiEvent('setUiData', setUiData);
  useNuiEvent('setGangStatus', setGangStatus);
  useNuiEvent('setTimerData', setTimerData);
  useNuiEvent('setWarStatUiPosition', () => setCanSetPosition(true));

  const timerProgress = useMemo(() => {
    if (!timerData?.total || timerData.total <= 0) return 0;
    const remainingSeconds = timerData.minutes * 60 + (timerData.seconds ?? 0);
    return clamp((remainingSeconds / timerData.total) * 100, 0, 100);
  }, [timerData]);

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
    borderRadius: 'var(--mantine-radius-lg)',
    cursor: canSetPosition ? (isDragging ? 'grabbing' : 'grab') : 'default',
  };

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
    fetchNui('setWarStatUiPositionData', { x: finalX, y: finalY });
    setCanSetPosition(false);
  };

  if (warUivisible) {
    return (
      <Transition mounted={warUivisible} transition="fade" duration={300}>
        {(transitionStyles) => (
          <div style={{ ...transitionStyles, position: 'fixed', inset: 0, pointerEvents: 'none' }}>
            <Box
              className={classes.box}
              p={5}
              h={boxH}
              w={boxW}
              style={{ ...style, pointerEvents: 'auto' }}
            >
              <Group justify="center">
                <Group justify="space-between" align="center" mr={10}>
                  <ThemeIcon size={'sm'} variant="light" color="green" radius="lg">
                    <Icon icon="bx:shield-quarter" width={24} height={24} />
                  </ThemeIcon>
                  <Text c="white" size="md" mt={5}>
                    Zone : {uiData?.zone ?? 'N/A'}
                  </Text>
                </Group>
              </Group>

              <Group justify="center" p={0}>
                <Stack gap={0} align="center" justify="space-between">
                  <RingsProgress
                    size={80}
                    thickness={8}
                    roundCaps
                    rings={[
                      {
                        value: uiData?.influence ?? 0,
                        color: `rgb(${uiData?.gangColor ?? '255,255,255'})`,
                      },
                    ]}
                    label={
                      <Text c="white" ta="center" size="xs">
                        {uiData?.gang ?? 'N/A'}
                        <br />
                        {uiData?.influence ?? 0}%
                      </Text>
                    }
                  />
                </Stack>
                <Stack w="60%" gap={2}>
                  {gangStatus?.map((gang, index) => (
                    <Paper
                      key={index}
                      className={classes.paper}
                      py={0}
                      px={3}
                      radius="md"
                      style={{
                        backgroundColor:
                          gang.code === 'attacker'
                            ? 'var(--mantine-color-red-light-hover)'
                            : 'var(--mantine-color-green-light-hover)',
                      }}
                    >
                      <Group justify="space-between">
                        <Group gap={8}>
                          <ActionIcon
                            size={'20px'}
                            variant="light"
                            radius="md"
                            color={gang.code === 'defender' ? '#2DFE54' : '#FF000C'}
                          >
                            <Icon
                              icon={
                                gang.code === 'defender' ? 'lucide:shield-check' : 'lucide:skull'
                              }
                              width={14}
                              height={14}
                            />
                          </ActionIcon>
                          <Text size="sm" c={gang.code === 'defender' ? '#2DFE54' : '#FF000C'}>
                            {gang.gang}
                          </Text>
                        </Group>
                        <Progress
                          w="30%"
                          value={(gang.value / gang.max) * 100}
                          color={gang.code === 'defender' ? '#2DFE54' : '#FF000C'}
                        />
                        <Text c="white" size="sm">
                          {gang.value}
                        </Text>
                      </Group>
                    </Paper>
                  ))}
                </Stack>
              </Group>

              <Stack w="100%" align="center" gap={0}>
                <Text c="white" size="32px">
                  {timerData?.minutes ?? 0}:{String(timerData?.seconds ?? 0).padStart(2, '0')}
                </Text>
                <Progress
                  w="40%"
                  radius="md"
                  size="md"
                  value={timerProgress}
                  color={(timerData?.minutes ?? 0) < 3 ? 'red' : 'green'}
                />
              </Stack>
            </Box>
          </div>
        )}
      </Transition>
    );
  }

  if (canSetPosition) {
    return (
      <Transition mounted={canSetPosition} transition="fade" duration={300}>
        {(transitionStyles) => (
          <div style={{ ...transitionStyles, position: 'fixed', inset: 0 }}>
            <Button
              m={10}
              style={{ position: 'absolute', top: 0, right: 0, zIndex: 999 }}
              onClick={savePosition}
            >
              Set Position
            </Button>
            <Box
              ref={setNodeRef}
              {...listeners}
              {...attributes}
              className={classes.box}
              p={5}
              h={boxH}
              w={boxW}
              style={{ ...style, pointerEvents: 'auto' }}
            >
              <Group justify="center">
                <Group justify="space-between" align="center" mr={10}>
                  <ThemeIcon size={'sm'} variant="light" color="green" radius="lg">
                    <Icon icon="bx:shield-quarter" width={24} height={24} />
                  </ThemeIcon>
                  <Text c="white" size="md" mt={5}>
                    Zone : {uiData?.zone ?? 'N/A'}
                  </Text>
                </Group>
              </Group>

              <Group justify="center" p={0}>
                <Stack gap={0} align="center" justify="space-between">
                  <RingsProgress
                    size={80}
                    thickness={8}
                    roundCaps
                    rings={[
                      {
                        value: uiData?.influence ?? 0,
                        color: `rgb(${uiData?.gangColor ?? '255,255,255'})`,
                      },
                    ]}
                    label={
                      <Text c="white" ta="center" size="xs">
                        {uiData?.gang ?? 'N/A'}
                        <br />
                        {uiData?.influence ?? 0}%
                      </Text>
                    }
                  />
                </Stack>
                <Stack w="60%" gap={2}>
                  {gangStatus?.map((gang, index) => (
                    <Paper
                      key={index}
                      className={classes.paper}
                      py={0}
                      px={3}
                      radius="md"
                      style={{
                        backgroundColor:
                          gang.code === 'attacker'
                            ? 'var(--mantine-color-red-light-hover)'
                            : 'var(--mantine-color-green-light-hover)',
                      }}
                    >
                      <Group justify="space-between">
                        <Group gap={8}>
                          <ActionIcon
                            size={'20px'}
                            variant="light"
                            radius="md"
                            color={gang.code === 'defender' ? '#2DFE54' : '#FF000C'}
                          >
                            <Icon
                              icon={
                                gang.code === 'defender' ? 'lucide:shield-check' : 'lucide:skull'
                              }
                              width={14}
                              height={14}
                            />
                          </ActionIcon>
                          <Text size="sm" c={gang.code === 'defender' ? '#2DFE54' : '#FF000C'}>
                            {gang.gang}
                          </Text>
                        </Group>
                        <Progress
                          w="30%"
                          value={(gang.value / gang.max) * 100}
                          color={gang.code === 'defender' ? '#2DFE54' : '#FF000C'}
                        />
                        <Text c="white" size="sm">
                          {gang.value}
                        </Text>
                      </Group>
                    </Paper>
                  ))}
                </Stack>
              </Group>

              <Stack w="100%" align="center" gap={0}>
                <Text c="white" size="32px">
                  {timerData?.minutes ?? 0}:{String(timerData?.seconds ?? 0).padStart(2, '0')}
                </Text>
                <Progress
                  w="40%"
                  radius="md"
                  size="md"
                  value={timerProgress}
                  color={(timerData?.minutes ?? 0) < 3 ? 'red' : 'green'}
                />
              </Stack>
            </Box>
          </div>
        )}
      </Transition>
    );
  }

  return null;
}
