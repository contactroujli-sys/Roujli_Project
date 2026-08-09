export const axis = {
  tickLine: false,
  axisLine: false,
  tick: { fill: "var(--color-muted-foreground)", fontSize: 11 },
} as const;

export const grid = {
  strokeDasharray: "3 3",
  stroke: "var(--color-border)",
  vertical: false,
} as const;

export const chartTooltip = {
  cursor: { fill: "var(--color-secondary)", opacity: 0.5 },
  contentStyle: {
    background: "var(--color-card)",
    border: "1px solid var(--color-border)",
    borderRadius: 12,
    boxShadow: "var(--shadow-lift)",
    fontSize: 12,
  },
  labelStyle: { color: "var(--color-muted-foreground)", fontSize: 11, marginBottom: 4 },
  itemStyle: { color: "var(--color-foreground)" },
} as const;
