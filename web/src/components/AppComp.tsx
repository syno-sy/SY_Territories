import { useState } from 'react';
import { Box, Group, Progress, RingProgress, Stack, Text } from '@mantine/core';
import { useMove, useViewportSize } from '@mantine/hooks';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { useLocales } from '../providers/LocaleProvider';
import { debugData } from '../utils/debugData';

debugData(
  [
    {
      action: 'setUiData',
      data: {
        zone: 'East V',
        gang: 'Ballas',
        influence: 75,
      },
    },
  ],
  10
);

export default function AppComp() {
  // locale provider
  const { locale } = useLocales();

  const { width: ViewPortWidth, height: ViewPortHeight } = useViewportSize();
  const [value, setValue] = useState({ x: 1, y: 1 });
  const { ref } = useMove(setValue);

  const [uiData, setUiData] = useState<any>(null);

  useNuiEvent<any>('setUiData', (data) => {
    setUiData(data);
  });
  return (
    <div
      ref={ref}
      style={{
        height: ViewPortHeight - 161,
        width: ViewPortWidth - 341,
        position: 'relative',
      }}
    >
      <Box
        p={5}
        m={5}
        h={150}
        w={330}
        bg={'#25262b'}
        style={{
          borderRadius: 25,
          position: 'absolute',
          left: `calc(${value.x * 100}% )`,
          top: `calc(${value.y * 100}% )`,
          backgroundColor: 'black',
        }}
      >
        <Group justify="space-between">
          <RingProgress
            size={100}
            sections={[{ value: uiData?.influence || 0, color: 'blue' }]}
            thickness={10}
            roundCaps
            label={
              <>
                <Text c="blue" fw={700} ta="center" size="xl">
                  {uiData?.gang || 'N/A'}
                </Text>
              </>
            }
          />
          <Text c="blue" fw={700} ta="center" size="xl">
            {uiData?.gang || 'N/A'}
          </Text>
        </Group>
        <Stack align="center" justify="space-between" gap="0">
          <Text>{locale.ui_TextInfluence}</Text>
          <Progress.Root size={'lg'} w={250}>
            <Progress.Section value={uiData?.influence || 0} color="orange">
              <Progress.Label>{uiData?.influence || 0}%</Progress.Label>
            </Progress.Section>
          </Progress.Root>
        </Stack>
      </Box>
    </div>
  );
}
