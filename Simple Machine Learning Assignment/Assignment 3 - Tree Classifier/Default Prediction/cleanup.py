import pandas as pd
df=pd.read_csv("LoanStats3a.csv")
df=df[['loan_amnt','term','sub_grade','emp_length'
       ,'home_ownership','verification_status','purpose','loan_status']]
df=df.dropna()
df=df[df.loan_status.isin(['Fully Paid','Charged Off'])]
df=df[df.emp_length!='n/a']
df['term']=df.term.apply(lambda x: int(x.split()[0]))

grades=['G','F','E','D','C','B','A']
df['gradeencoding']=df['sub_grade'].apply(lambda x: grades.index(x[0])+(0.7-0.1*float(x[1])))
def empllengthprocess(x):
    x=x.split('year')[0]
    if('+') in x:
        return 12
    if ('<') in x:
        return 0
    else:
        return int(x)
df['emplen']=df.emp_length.apply(lambda x: empllengthprocess(x))
df=df[['loan_amnt','term','verification_status','gradeencoding','emplen','purpose','home_ownership',
       #'emp_title',
       'loan_status']]
df.to_csv('Loans_processed.csv',index=False)