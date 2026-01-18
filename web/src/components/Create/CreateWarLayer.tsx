import { useState } from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { debugData } from '../../utils/debugData';
import CreateWar from './CreateWar';

export type SelectOption = {
  value: string;
  label: string;
};

debugData(
  [
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

export default function CreateWarLayer() {
  const [visible, setVisible] = useState(false);
  const [data, setData] = useState<{
    zones: SelectOption[];
    gangs: SelectOption[];
  } | null>(null);

  useNuiEvent('showCreateWarUi', (payload) => {
    setVisible(true);
    setData({
      zones: payload.zones ?? [],
      gangs: payload.gangs ?? [],
    });
  });

  useNuiEvent('hideCreateWarUi', () => {
    setVisible(false);
    setData(null);
  });

  if (!visible || !data) return null;

  return <CreateWar zones={data.zones} gangs={data.gangs} />;
}
