import { useMemo } from 'react';
import { Icon } from '@iconify/react';
import { ActionIcon, Button, Group, NumberInput, Paper, Select, Text } from '@mantine/core';
import { useForm } from '@mantine/form';
import { useViewportSize } from '@mantine/hooks';
import { fetchNui } from '../../utils/fetchNui';

type Props = {
  zones: SelectOption[];
  gangs: SelectOption[];
};

function CreateWar({ zones, gangs }: Props) {
  const { width, height } = useViewportSize();

  const form = useForm({
    mode: 'uncontrolled',
    initialValues: {
      zone: '',
      defenderGang: '',
      attackerGang: '',
      warTime: 0,
    },

    validate: {
      zone: (value) => (value ? null : 'Zone is required'),
      defenderGang: (value) => (value ? null : 'Defender Gang is required'),
      attackerGang: (value) => (value ? null : 'Attacker Gang is required'),
      warTime: (value) => (value > 0 ? null : 'War time must be greater than 0'),
    },
  });

  // 1. Sort Gangs in Ascending order by label
  const sortedGangs = useMemo(() => {
    return [...gangs].sort((a, b) => a.label.localeCompare(b.label));
  }, [gangs]);

  // 2. Determine Attacker options (disable the one selected in Defender)
  const attackerGangs = useMemo(() => {
    return sortedGangs.map((gang) => ({
      ...gang,
      disabled: gang.value === form.values.defenderGang,
    }));
  }, [sortedGangs, form.values.defenderGang]);

  return (
    <div
      style={{
        width,
        height,
        position: 'fixed',
        inset: 0,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <Paper w={400} radius="lg" p="md" shadow="sm" withBorder>
        <Group justify="space-between" mb="md">
          <div />
          <Text size="xl" fw={600}>
            Create War
          </Text>
          <ActionIcon
            size="md"
            variant="light"
            color="red"
            onClick={() => fetchNui('hide-create-war-ui')}
          >
            <Icon icon="solar:close-circle-outline" width="24" height="24" />
          </ActionIcon>
        </Group>

        <form
          onSubmit={form.onSubmit((values) => {
            fetchNui('createWar', values);
            form.reset();
          })}
        >
          <Select
            searchable
            withAsterisk
            label="Zone"
            placeholder="Select zone"
            data={zones}
            key={form.key('zone')}
            {...form.getInputProps('zone')}
          />

          <Select
            searchable
            withAsterisk
            label="Defender Gang"
            placeholder="Select defender gang"
            data={sortedGangs} // Using sorted list
            {...form.getInputProps('defenderGang')}
            onChange={(val) => {
              form.setFieldValue('defenderGang', val ?? '');
              if (val === form.values.attackerGang) {
                form.setFieldValue('attackerGang', '');
              }
            }}
            mb="sm"
          />

          <Select
            searchable
            withAsterisk
            label="Attacker Gang"
            placeholder="Select attacker gang"
            data={attackerGangs}
            {...form.getInputProps('attackerGang')}
            mb="sm"
          />
          <NumberInput
            withAsterisk
            label="War Time (minutes)"
            placeholder="Enter war time"
            key={form.key('warTime')}
            {...form.getInputProps('warTime')}
          />

          <Group justify="flex-end" mt="md">
            <Button variant="light" type="submit">
              Submit
            </Button>
          </Group>
        </form>
      </Paper>
    </div>
  );
}

export default CreateWar;
