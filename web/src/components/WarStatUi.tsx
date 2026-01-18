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
        gang: 'TVA',
        gangColor: '255, 0, 0',
        influence: 75,
      },
    },
    {
      action: 'setGangStatus',
      data: [
        { code: 'defender', gang: 'TVA', value: 10 },
        { code: 'attacker', gang: 'KVA', value: 8 },
      ],
    },
    {
      action: 'setTimerData',
      data: { minutes: 2, seconds: 59, total: 200 },
    },
    {
      action: 'showCreateWarUi',
      data: {
        zones: [
          { value: 'eastv', label: 'East V' },
          { value: 'davis', label: 'Davis' },
        ],
        gangs: [
          { value: 'tva', label: 'TVA' },
          { value: 'kva', label: 'KVA' },
          { value: 'tga', label: 'TGA' },
          { value: 'srra', label: 'SRRA' },
        ],
      },
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
  /* Memoized Timer Progress */
  /* ------------------------------------------------------------------ */

  // const timerProgress = useMemo(() => {
  //   if (!timerData) return 0;

  //   const remainingSeconds = timerData.minutes * 60 + (timerData.seconds ?? 0);

  //   return Math.max(0, Math.min((remainingSeconds / timerData.total) * 100, 100));
  // }, [timerData]);

  const timerProgress = useMemo(() => {
    if (!timerData || !timerData.total || timerData.total <= 0) return 0;

    const remainingSeconds = timerData.minutes * 60 + (timerData.seconds ?? 0);

    // Calculation: (Current / Original) * 100
    const progress = (remainingSeconds / timerData.total) * 100;

    return Math.max(0, Math.min(progress, 100));
  }, [timerData]);

  const isCritical = (timerData?.minutes ?? 0) < 3;

  /* ------------------------------------------------------------------ */
  /* Render */
  /* ------------------------------------------------------------------ */

  return (
    <>
      {' '}
      {visible && (
        <div
          ref={ref}
          style={{
            height: height - 211,
            width: width - 341,
            position: 'relative',
          }}
        >
          <Box
            className={classes.box}
            p={5}
            m={5}
            h={200}
            w={330}
            style={{
              borderRadius: 25,
              position: 'absolute',
              left: `calc(${value.x * 100}%)`,
              top: `calc(${value.y * 100}%)`,
            }}
          >
            <Group justify="space-between">
              {/* Influence Ring */}
              <Stack gap={0} align="center" justify="space-between">
                <Text c="white" fw={500} size="md">
                  {locale.ui_TextInfluence}
                </Text>

                <RingsProgress
                  size={110}
                  thickness={10}
                  roundCaps
                  rings={[
                    {
                      value: Math.min(uiData?.influence ?? 0, 100),
                      color: `rgb(${uiData?.gangColor ?? '255,255,255'})`,
                    },
                  ]}
                  label={
                    <Text c="white" fw={700} ta="center" size="xl">
                      {uiData?.gang ?? 'N/A'}
                      <br />
                      {uiData?.influence ?? 0}%
                    </Text>
                  }
                />
              </Stack>

              {/* Zone & Gangs */}
              <Stack w="60%">
                <Group justify="right" align="center" mr={10}>
                  <ThemeIcon variant="light" radius="lg">
                    <Icon icon="bx:shield-quarter" width={24} height={24} />
                  </ThemeIcon>

                  <Text c="white" fw={600} size="lg" mt={5}>
                    Zone : {uiData?.zone ?? 'N/A'}
                  </Text>
                </Group>

                {gangStatus?.map((gang, index) => (
                  <Paper key={index} className={classes.paper} p={3} radius="md">
                    <Group justify="space-between">
                      <Group gap={8}>
                        <ActionIcon
                          variant="light"
                          radius="md"
                          color={gang.code === 'defender' ? '#2DFE54' : '#FF000C'}
                        >
                          <Icon
                            icon={gang.code === 'defender' ? 'lucide:shield-check' : 'lucide:skull'}
                            width={16}
                            height={16}
                          />
                        </ActionIcon>

                        <Text c={gang.code === 'defender' ? '#2DFE54' : '#FF000C'} fw={600}>
                          {gang.gang}
                        </Text>
                      </Group>

                      <Progress
                        w="30%"
                        value={Math.min(gang.value * 10, 100)}
                        color={gang.code === 'defender' ? '#2DFE54' : '#FF000C'}
                        styles={{
                          root: {
                            backgroundColor: gang.code === 'defender' ? '#2dfe541f' : '#ff000c1f',
                          },
                        }}
                      />

                      <Text c="white" fw={600} size="lg">
                        {gang.value}
                      </Text>
                    </Group>
                  </Paper>
                ))}
              </Stack>
            </Group>

            {/* Timer */}
            <Stack w="100%" align="center" gap={0}>
              <Text c="white" fw={400} size="42px" style={{ fontVariantNumeric: 'tabular-nums' }}>
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
