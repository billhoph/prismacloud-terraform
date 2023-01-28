import pandas as pd
from tabulate import tabulate

pd.set_option('display.max_colwidth', None)
# --Configuration-- #

data = pd.read_csv("demo_user_list.csv")

data_grp = data.groupby('acc_gp')['acc_id'].apply('||'.join).reset_index()

# putting pd into DataFrame
df_email = pd.DataFrame(data_grp)

print(tabulate(df_email, headers = 'keys', tablefmt = 'psql'))

# generating csv files
df_email.to_csv('acc_grps.csv',index=False)