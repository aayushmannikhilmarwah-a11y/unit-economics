# Revolut-Style Fintech Unit Economics Model

End-to-end project modelling 36-month unit economics for a Revolut-style consumer fintech. Synthetic data generated in Python, analysed via SQL (SQLite), forecast built in Excel with scenario and sensitivity analysis.

## Overview
- Generated 30,000 synthetic users and ~2.5M transactions across 5 acquisition channels
- Loaded into SQLite and queried for cohort retention, ARPU trend, LTV by channel, and LTV:CAC ratios
- Built a 36-month P&L forecast in Excel with base / bull / bear scenarios
- Calibrated assumptions against publicly disclosed Revolut benchmarks

## Stack
- Python (pandas, numpy, faker) — synthetic data generation
- SQLite + DB Browser for SQLite — storage and querying
- SQL — CTEs, window functions, cohort joins
- Excel — forecasting and scenarios

## Files
- `generate_data.py` — synthetic dataset generation
- `queries.sql` — analytical SQL queries
- `Revolut_Forecast.xlsx` — P&L forecast model

## Key findings (base case)
- Month-12 cohort retention: ~55%
- Blended LTV: £42.50  |  Blended CAC: £33  |  Blended LTV:CAC: 1.29x
- Channel split: Organic the only profitable channel at 1.72x LTV:CAC; paid channels all sub-1.0x (Influencer worst at 0.08x)
- 36-month cumulative revenue: £6.6m (base) / £12.1m (bull) / £2.8m (bear)
- Break-even month: month 26 (base case); month 3 (bull); never (bear)

## Limitations
- Model assumes constant growth rates — does not include TAM saturation or growth deceleration
- Operating cost % held flat — no operating leverage modelled
- In a v2 I would add: TAM ceiling on MAU, declining growth rates, op cost % declining toward 40% with scale
