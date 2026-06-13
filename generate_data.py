import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random

random.seed(42)
np.random.seed(42)

N_USERS = 30000
START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2025, 12, 31)

channels = ['Organic', 'Paid Social', 'Paid Search', 'Referral', 'Influencer']
channel_weights = [0.25, 0.30, 0.20, 0.15, 0.10]
channel_cac = {'Organic': 5, 'Paid Social': 25, 'Paid Search': 35,
               'Referral': 10, 'Influencer': 40}

# Generate users
users_data = []
for user_id in range(1, N_USERS + 1):
    signup_date = START_DATE + timedelta(days=random.randint(0, (END_DATE - START_DATE).days))
    channel = np.random.choice(channels, p=channel_weights)
    country = np.random.choice(['UK', 'India', 'USA', 'Germany', 'France'],
                                p=[0.4, 0.2, 0.15, 0.15, 0.1])
    plan = np.random.choice(['Standard', 'Plus', 'Premium', 'Metal', 'Ultra'],
                             p=[0.6, 0.15, 0.12, 0.10, 0.03])
    monthly_churn = np.random.uniform(0.02, 0.08)
    users_data.append({
        'user_id': user_id,
        'signup_date': signup_date.strftime('%Y-%m-%d'),
        'channel': channel,
        'country': country,
        'plan': plan,
        'monthly_churn_rate': round(monthly_churn, 4)
    })

users_df = pd.DataFrame(users_data)

# Generate transactions
transactions_data = []
for _, user in users_df.iterrows():
    current_date = pd.to_datetime(user['signup_date'])
    end_date = pd.to_datetime('2025-12-31')
    while current_date <= end_date:
        if random.random() < user['monthly_churn_rate']:
            break
        n_transactions = np.random.poisson(8)
        for _ in range(n_transactions):
            txn_date = current_date + timedelta(days=random.randint(0, 28))
            if txn_date <= end_date:
                txn_amount = np.random.lognormal(3, 1)
                revenue = txn_amount * 0.015
                transactions_data.append({
                    'user_id': user['user_id'],
                    'transaction_date': txn_date.strftime('%Y-%m-%d'),
                    'amount': round(txn_amount, 2),
                    'revenue': round(revenue, 2)
                })
        current_date += timedelta(days=30)

transactions_df = pd.DataFrame(transactions_data)

# Marketing spend
marketing_data = []
for c, cac in channel_cac.items():
    for year in [2023, 2024, 2025]:
        for month in range(1, 13):
            spend = cac * np.random.randint(800, 1500)
            marketing_data.append({
                'channel': c,
                'year': year,
                'month': month,
                'spend': spend
            })
marketing_df = pd.DataFrame(marketing_data)

users_df.to_csv('users.csv', index=False)
transactions_df.to_csv('transactions.csv', index=False)
marketing_df.to_csv('marketing.csv', index=False)
print('Done. Generated 3 CSVs.')
print(f'Users: {len(users_df)}, Transactions: {len(transactions_df)}, Marketing rows: {len(marketing_df)}')