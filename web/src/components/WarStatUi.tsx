import { useMemo, useState } from 'react';
import { RingsProgress } from '@gfazioli/mantine-rings-progress';
import { Icon } from '@iconify/react';
import { ActionIcon, Box, Group, Paper, Progress, Stack, Text, ThemeIcon } from '@mantine/core';
import { useMove, useViewportSize } from '@mantine/hooks';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { useLocales } from '../providers/LocaleProvider';
import { debugData } from '../utils/debugData';
import { isEnvBrowser } from '../utils/misc';
import classes from './WarStatUi.module.css';

/* ------------------------------------------------------------------ */
/* Debug */
/* ------------------------------------------------------------------ */

debugData(
  [
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

/* ------------------------------------------------------------------ */
/* Component */
/* ------------------------------------------------------------------ */

export default function AppComp() {
  const { locale } = useLocales();
  const [visible, setVisible] = useState(isEnvBrowser());
  const { width, height } = useViewportSize();

  const [value, setValue] = useState({ x: 1, y: 1 });
  const { ref } = useMove(setValue);

  const [uiData, setUiData] = useState<UiData | null>(null);
  const [gangStatus, setGangStatus] = useState<GangStatus[] | null>(null);
  const [timerData, setTimerData] = useState<TimerData | null>(null);

  /* ------------------------------------------------------------------ */
  /* NUI Events */
  /* ------------------------------------------------------------------ */
  useNuiEvent('setWarStatVisible', (data: { visible?: boolean }) => {
    setVisible(data.visible || false);
  });
  useNuiEvent<UiData>('setUiData', setUiData);
  useNuiEvent<GangStatus[]>('setGangStatus', setGangStatus);
  useNuiEvent<TimerData>('setTimerData', setTimerData);

  /* ------------------------------------------------------------------ */
  /* Timer Hooks */
  /* ------------------------------------------------------------------ */

  const timerProgress = useMemo(() => {
    if (!timerData || !timerData.total || timerData.total <= 0) return 0;

    const remainingSeconds = timerData.minutes * 60 + (timerData.seconds ?? 0);

    // Calculation: (Current / Original) * 100
    const progress = (remainingSeconds / timerData.total) * 100;

    return Math.max(0, Math.min(progress, 100));
  }, [timerData]);

  const isCritical = (timerData?.minutes ?? 0) < 3;

  /* ------------------------------------------------------------------ */
  /* UI Render */
  /* ------------------------------------------------------------------ */

  return (
    <>
      {visible && (
        <div
          ref={ref}
          style={{
            height: height - 196,
            width: width - 341,
            position: 'relative',
          }}
        >
          <Box
            className={classes.box}
            p={5}
            m={5}
            h={185}
            w={330}
            style={{
              borderRadius: 25,
              position: 'absolute',
              left: `calc(${value.x * 100}%)`,
              top: `calc(${value.y * 100}%)`,
            }}
          >
            <Group justify="space-between">
              <Text w={100} ta={'center'} c="white" size="lg">
                {locale.ui_TextInfluence}
              </Text>
              <Group justify="right" align="center" mr={10}>
                <ThemeIcon variant="light" radius="lg">
                  <Icon icon="bx:shield-quarter" width={24} height={24} />
                </ThemeIcon>

                <Text c="white" size="lg" mt={5}>
                  Zone : {uiData?.zone ?? 'N/A'}
                </Text>
              </Group>
            </Group>
            <Group justify="space-between" p={0}>
              {/* Influence Ring */}
              <Stack gap={0} align="center" justify="space-between">
                <RingsProgress
                  size={100}
                  thickness={10}
                  roundCaps
                  rings={[
                    {
                      value: Math.min(uiData?.influence ?? 0, 100),
                      color: `rgb(${uiData?.gangColor ?? '255,255,255'})`,
                    },
                  ]}
                  label={
                    <Text c="white" ta="center" size="md">
                      {uiData?.gang ?? 'N/A'}
                      <br />
                      {uiData?.influence ?? 0}%
                    </Text>
                  }
                />
              </Stack>

              {/* Zone & Gangs */}
              <Stack w="60%" gap={2}>
                {gangStatus?.map((gang, index) => {
                  const gangPercentage = gang.max > 0 ? (gang.value / gang.max) * 100 : 100;
                  return (
                    <Paper
                      key={index}
                      className={classes.paper}
                      py={0}
                      px={5}
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

                          <Text c={gang.code === 'defender' ? '#2DFE54' : '#FF000C'}>
                            {gang.gang}
                          </Text>
                        </Group>

                        <Progress
                          w="30%"
                          value={gangPercentage}
                          color={gang.code === 'defender' ? '#2DFE54' : '#FF000C'}
                          styles={{
                            root: {
                              backgroundColor: gang.code === 'defender' ? '#2dfe541f' : '#ff000c1f',
                            },
                          }}
                        />

                        <Text c="white" size="lg">
                          {gang.value}
                        </Text>
                      </Group>
                    </Paper>
                  );
                })}
              </Stack>
            </Group>

            {/* Timer */}
            <Stack w="100%" align="center" gap={0}>
              <Text c="white" size="32px">
                {timerData?.minutes ?? 0}:{String(timerData?.seconds ?? 0).padStart(2, '0')}
              </Text>

              <Progress
                w="40%"
                radius="md"
                size="md"
                value={timerProgress}
                color={isCritical ? 'red' : 'green'}
                styles={{
                  root: {
                    backgroundColor: isCritical ? '#ff000c1f' : '#2dfe541f',
                  },
                  section: {
                    transition: 'width 0.8s linear',
                  },
                }}
              />
            </Stack>
          </Box>
        </div>
      )}
    </>
  );
}
