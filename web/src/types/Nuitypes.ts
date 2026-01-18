/* ------------------------------------------------------------------ */
/* Types */
/* ------------------------------------------------------------------ */

interface UiData {
  zone: string;
  gang: string;
  gangColor: string;
  influence: number;
}

interface GangStatus {
  code: 'defender' | 'attacker';
  gang: string;
  value: number;
  max: number;
}

interface TimerData {
  minutes: number;
  seconds: number;
  total: number;
}

interface SelectOption {
  value: string;
  label: string;
};