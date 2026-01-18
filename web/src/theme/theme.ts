import { createTheme, MantineColorsTuple } from '@mantine/core';

const uiColor: MantineColorsTuple = [
  '#ffebff',
  '#f5d5fb',
  '#e6a8f3',
  '#d779eb',
  '#cb51e4',
  '#c337e0',
  '#c02adf',
  '#a91cc6',
  '#9715b1',
  '#84099c'
];

export const theme = createTheme({
 colors: {
    uiColor,
  },
  primaryColor: 'uiColor',
  defaultRadius: 'lg',
  fontFamily: 'Gugi, sans-serif',
  headings: {
    fontFamily: 'Gugi, sans-serif',
  },
});
