import React, { useEffect, useState } from 'react';
import ReactDOM from 'react-dom/client';
import { MantineProvider } from '@mantine/core';

import './index.css';
import '@mantine/core/styles.css';

import CreateWarLayer from './components/Create/CreateWarLayer';
import InfluenceUI from './components/InfluenceUI';
import WarStatUi from './components/WarStatUi';
import { useNuiEvent } from './hooks/useNuiEvent';
import LocaleProvider from './providers/LocaleProvider';
import { theme } from './theme/theme';
// import { debugData } from './utils/debugData';
import { fetchNui } from './utils/fetchNui';
import { isEnvBrowser } from './utils/misc';

// debugData([
// {
//   action: 'getInfluenceUiPosition',
//   data: { x: 100, y: 500 },
// },
// {
//   action: 'getWarStatUiPosition',
//   data: { x: 500, y: 500 },
// },
// {
//   action: 'setWarStatUiPosition',
//   data: {
//     zone: 'East V',
//     gang: 'SRRA',
//     gangColor: '255, 0, 0',
//     influence: 75,
//   },
// },
// {
//   action: 'showInfluenceUi',
//   data: {
//     zone: 'East V',
//     gang: 'SRRA',
//     gangColor: '255, 0, 0',
//     influence: 75,
//   },
// },
// {
//   action: 'setWarStatVisible',
//   data: { visible: true },
// },
// {
//   action: 'showCreateWarUi',
//   data: {
//     zones: [
//       { value: 'eastv', label: 'East V' },
//       { value: 'davis', label: 'Davis' },
//     ],
//     gangs: [
//       { value: 'tva', label: 'TVA' },
//       { value: 'kva', label: 'KVA' },
//       { value: 'tga', label: 'TGA' },
//       { value: 'srra', label: 'SRRA' },
//     ],
//   },
// },
// ]);

function Root() {
  const [influencePos, setInfluencePos] = useState({ x: 100, y: 100 });
  const [warStatPos, setWarStatPos] = useState({ x: 500, y: 100 });

  useNuiEvent<{ x: number; y: number }>('getInfluenceUiPosition', (data) => {
    if (data?.x !== undefined) setInfluencePos(data);
  });

  useNuiEvent<{ x: number; y: number }>('getWarStatUiPosition', (data) => {
    if (data?.x !== undefined) setWarStatPos(data);
  });
  useEffect(() => {
    fetchNui('getInfluenceUiPosition').catch(() => {});
    fetchNui('getWarStatUiPosition').catch(() => {});
  }, []);
  return (
    <LocaleProvider>
      <MantineProvider defaultColorScheme="dark" theme={theme}>
        <WarStatUi warStatPos={warStatPos} />
        <InfluenceUI influencePos={influencePos} />
        <CreateWarLayer />
      </MantineProvider>
    </LocaleProvider>
  );
}

// Browser Background for Testing
if (isEnvBrowser()) {
  const root = document.getElementById('root');
  if (root) {
    root.style.backgroundImage = 'url("https://i.imgur.com/3pzRj9n.png")';
    root.style.backgroundSize = 'cover';
  }
}

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <Root />
  </React.StrictMode>
);
