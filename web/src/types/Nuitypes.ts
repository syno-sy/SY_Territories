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
}

interface TimerData {
  minutes: number;
  seconds: number;
  total: number;
}