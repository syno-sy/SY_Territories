import React, { useState } from 'react';
import ReactDOM from 'react-dom/client';

import './index.css';
import '@mantine/core/styles.css';

import { DndContext, DragEndEvent } from '@dnd-kit/core';
import { MantineProvider } from '@mantine/core';
import CreateWarLayer from './components/Create/CreateWarLayer';
import InfluenceUI from './components/InfluenceUI';
import AppComp from './components/WarStatUi';
import LocaleProvider from './providers/LocaleProvider';
import { theme } from './theme/theme';
import { debugData } from './utils/debugData';
import { isEnvBrowser } from './utils/misc';

debugData([
  {
    action: 'setVisible',
    data: 'show-ui',
  },
]);

function Root() {
  const [influencePos, setInfluencePos] = useState({ x: 0, y: 0 });

  const handleDragEnd = (event: DragEndEvent) => {
    if (event.active.id === 'influence-ui-box' && event.delta) {
      setInfluencePos((pos) => ({
        x: pos.x + event.delta.x,
        y: pos.y + event.delta.y,
      }));
    }
  };

  return (
    <LocaleProvider>
      <MantineProvider defaultColorScheme="dark" theme={{ ...theme }}>
        <DndContext onDragEnd={handleDragEnd}>
          <AppComp />
          <CreateWarLayer />
          <InfluenceUI position={influencePos} />
        </DndContext>
      </MantineProvider>
    </LocaleProvider>
  );
}

if (isEnvBrowser()) {
  const root = document.getElementById('root');
  root!.style.backgroundImage = 'url("https://i.imgur.com/3pzRj9n.png")';
  root!.style.backgroundSize = 'cover';
  root!.style.backgroundRepeat = 'no-repeat';
  root!.style.backgroundPosition = 'center';
}

ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
  <React.StrictMode>
    <Root />
  </React.StrictMode>
);
