import { useMemo, useState } from 'react';
import { Icon } from '@iconify/react';
import {
  ActionIcon,
  Box,
  Button,
  Group,
  Paper,
  Portal,
  Progress,
  RingProgress,
  Stack,
  Text,
  ThemeIcon,
  Transition,
} from '@mantine/core';
import { useFloatingWindow } from '@mantine/hooks';
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

export default function WarStatUi({ warStatPos }: { warStatPos: { x: number; y: number } }) {
  const [warUiVisible, setWarUiVisible] = useState(false);
  const [canSetPosition, setCanSetPosition] = useState(false);
  const [warStatUiPosition, setWarStatUiPosition] = useState({ x: 100, y: 100 });

  const [uiData, setUiData] = useState<any>(null);
  const [gangStatus, setGangStatus] = useState<any[]>([]);
  const [timerData, setTimerData] = useState<any>(null);

  const warStatUiFloatingWindow = useFloatingWindow({
    enabled: canSetPosition,
    constrainToViewport: true,
    constrainOffset: ViewPort_Padding,
    initialPosition: { top: warStatPos.y || 300, left: warStatPos.x || 20 },
    onPositionChange: setWarStatUiPosition,
  });

  /* --- NUI Events --- */
  useNuiEvent('setWarStatVisible', (data) => setWarUiVisible(data.visible));
  useNuiEvent('setUiData', setUiData);
  useNuiEvent('setGangStatus', setGangStatus);
  useNuiEvent('setTimerData', setTimerData);
  useNuiEvent('setWarStatUiPosition', () => setCanSetPosition(true));

  useNuiEvent<{ x: number; y: number }>('getWarStatUiPosition', (payload) => {
    if (payload?.x !== undefined && payload?.y !== undefined) {
      setWarStatUiPosition({ x: payload.x, y: payload.y });
    }
  });

  const timerProgress = useMemo(() => {
    if (!timerData?.total || timerData.total <= 0) return 0;
    const remainingSeconds = timerData.minutes * 60 + (timerData.seconds ?? 0);
    return clamp((remainingSeconds / timerData.total) * 100, 0, 100);
  }, [timerData]);

  const savePosition = () => {
    fetchNui('setWarStatUiPositionData', { x: warStatUiPosition.x, y: warStatUiPosition.y });
    setCanSetPosition(false);
  };

  if (warUiVisible) {
    return (
      <Transition mounted={warUiVisible} transition="fade" duration={300}>
        {(transitionStyles) => (
          <Portal style={{ ...transitionStyles }}>
            <Box
              className={classes.box}
              p={5}
              h={boxH}
              w={boxW}
              style={{
                position: 'fixed',
                left: warStatUiPosition.x,
                top: warStatUiPosition.y,
                borderRadius: 'var(--mantine-radius-lg)',
                cursor: canSetPosition ? 'move' : 'default',
                transition: 'box-shadow 70ms ease',
                zIndex: 400,
              }}
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
                  <RingProgress
                    size={80}
                    thickness={8}
                    roundCaps
                    sections={[
                      {
                        value: uiData?.influence ?? 0,
                        color: `rgb(${uiData?.gangColor ?? '255,255,255'})`,
                      },
                    ]}
                    rootColor={`rgba(${uiData?.gangColor}, 0.3)`}
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
          </Portal>
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
              style={{ position: 'absolute', top: 0, right: 0, zIndex: 999999 }}
              onClick={savePosition}
            >
              Set Position
            </Button>
            <Box
              ref={warStatUiFloatingWindow.ref}
              className={classes.box}
              p={5}
              h={boxH}
              w={boxW}
              style={{
                position: 'fixed',
                borderRadius: 'var(--mantine-radius-lg)',
                cursor: canSetPosition ? 'move' : 'default',
                transition: 'box-shadow 70ms ease',
                zIndex: 400,
              }}
              data-drag-handle
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
                  <RingProgress
                    size={80}
                    thickness={8}
                    roundCaps
                    sections={[
                      {
                        value: uiData?.influence ?? 0,
                        color: `rgb(${uiData?.gangColor ?? '255,255,255'})`,
                      },
                    ]}
                    rootColor={`rgba(${uiData?.gangColor}, 0.3)`}
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
