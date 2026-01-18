import { ActionIcon, Button, Group, NumberInput, Paper, Select, Text } from '@mantine/core';
import { useForm } from '@mantine/form';
import { useViewportSize } from '@mantine/hooks';
import { fetchNui } from '../../utils/fetchNui';
import type { SelectOption } from './CreateWarLayer';

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
          <Text size="lg" fw={500}>
            Create War
          </Text>
          <ActionIcon
            size="md"
            variant="light"
            color="red"
            onClick={() => fetchNui('hide-create-war-ui')}
          >
            X
          </ActionIcon>
        </Group>

        <form
          onSubmit={form.onSubmit((values) => {
            fetchNui('createWar', values);
            form.reset();
          })}
        >
          <Select
            withAsterisk
            label="Zone"
            placeholder="Select zone"
            data={zones}
            key={form.key('zone')}
            {...form.getInputProps('zone')}
          />

          <Select
            withAsterisk
            label="Defender Gang"
            placeholder="Select defender gang"
            data={gangs}
            key={form.key('defenderGang')}
            {...form.getInputProps('defenderGang')}
          />

          <Select
            withAsterisk
            label="Attacker Gang"
            placeholder="Select attacker gang"
            data={gangs}
            key={form.key('attackerGang')}
            {...form.getInputProps('attackerGang')}
          />

          <NumberInput
            withAsterisk
            label="War Time (minutes)"
            placeholder="Enter war time"
            key={form.key('warTime')}
            {...form.getInputProps('warTime')}
          />

          <Group justify="flex-end" mt="md">
            <Button type="submit">Submit</Button>
          </Group>
        </form>
      </Paper>
    </div>
  );
}

export default CreateWar;
