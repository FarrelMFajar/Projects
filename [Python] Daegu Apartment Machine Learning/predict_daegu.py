# Import necessary libraries
import streamlit as st
import pandas as pd
import numpy as np
import pickle
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.compose import ColumnTransformer
from sklearn.preprocessing import OneHotEncoder, RobustScaler, StandardScaler, RobustScaler, OrdinalEncoder
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error
from xgboost import XGBRegressor
from sklearn.ensemble import RandomForestRegressor
from sklearn.compose import TransformedTargetRegressor

# Set page configuration
st.set_page_config(page_title='Apartment Price Prediction in Daegu', layout='wide')

# Sidebar for page navigation
page = st.sidebar.selectbox("Select Page", ['Data Visualization', 'Prediction'])

# Function to load and cache data
@st.cache(allow_output_mutation=True)
def load_data():
    filepath = 'df.csv'
    df = pd.read_csv(filepath)
    return df


# Function to train model
def train_model(df):
    numerical_cols = [
        'N_FacilitiesNearBy(ETC)', 'N_FacilitiesNearBy(PublicOffice)',
        'N_SchoolNearBy(University)', 'YearBuilt', 'Size(sqf)','N_Parkinglot(Basement)'
    ]
    categorical_cols = ['SubwayStation', 'HallwayType']
    ordinal_cols = ['TimeToSubway']
    X = df.drop('SalePrice', axis=1)
    y = df['SalePrice']  

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    time_to_subway_categories = ['0-5min', '5min~10min', '10min~15min', '15min~20min', 'no_bus_stop_nearby']
    
    # Define preprocessing for numeric and categorical features
    preprocessor = ColumnTransformer(
        transformers=[
            ('num', StandardScaler(), numerical_cols),
            ('cat', OneHotEncoder(), categorical_cols),
            ('ord', Pipeline(steps=[
                ('ordencode', OrdinalEncoder(categories=[time_to_subway_categories])),
                ('scale', StandardScaler())
            ]), ordinal_cols),
        ]
    )

    # Define the model as RandomForestRegressor
    model = RandomForestRegressor(
        n_estimators=200,       # Set number of trees in the forest
        random_state=42,        # For reproducibility
        n_jobs=-1               # Use all available CPUs for faster training
    )

    # Create pipeline
    pipeline = Pipeline(steps=[('preprocessor', preprocessor), ('model', model)])

    # Train the pipeline
    pipeline.fit(X_train, y_train)

    # Make predictions
    y_pred = pipeline.predict(X_test)

    # Calculate performance metrics
    mse = mean_squared_error(y_test, y_pred)
    rmse = np.sqrt(mse)
    mae = mean_absolute_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)

    return pipeline, rmse, mae, r2

# Function to save the model
def save_model(model, filename='model.pkl'):
    with open(filename, 'wb') as file:
        pickle.dump(model, file)

# Function to load the model
def load_model(filename='model.pkl'):
    with open(filename, 'rb') as file:
        model = pickle.load(file)
    return model

# Data Visualization Page
if page == 'Data Visualization':
    st.title('Daegu Apartment Data Visualization')

    data = load_data()
    st.subheader("Data Overview")
    st.write("Here is the overview of the dataset:")
    st.dataframe(data.head(10))

    st.subheader("Data Summary")
    st.write("Here is the summary statistics of the dataset:")
    st.write(data.describe())

    st.subheader("Feature Distribution")
    selected_feature = st.selectbox("Select Feature for Distribution", data.columns)
    fig, ax = plt.subplots()
    sns.histplot(data[selected_feature], kde=True, ax=ax)
    st.pyplot(fig)

    st.subheader("Feature vs SalePrice")
    feature = st.selectbox("Select Feature for Scatter Plot", data.columns.drop('SalePrice'))
    fig, ax = plt.subplots()
    sns.scatterplot(x=data[feature], y=data['SalePrice'], ax=ax)
    st.pyplot(fig)

# Prediction Page
elif page == 'Prediction':
    st.title('Apartment Price Prediction')

    # Load dataset and model
    data = load_data()
    model, rmse, mae, r2 = train_model(data)

    # User input features
    st.subheader("Input Features")
    input_data = {}
    for feature in data.columns.drop('SalePrice'):
        if data[feature].dtype == 'float64' or data[feature].dtype == 'int64':
            input_data[feature] = st.number_input(f'Enter {feature}', value=float(data[feature].mean()))
        else:
            options = list(data[feature].unique())
            input_data[feature] = st.selectbox(f'Select {feature}', options=options)

    # Convert input data to DataFrame
    input_df = pd.DataFrame([input_data])

    if st.button('Predict'):
        with st.spinner('Predicting...'):
            data = load_data()
            model, rmse, mae, r2 = train_model(data)
            input_df = pd.DataFrame([input_data])
            predictions = model.predict(input_df)
            st.success('Prediction Complete!')
            st.metric(label=f"The predicted price is:", value=f"KRW{predictions[0]:,.2f}")
            st.write("Model Performance:")
            st.metric(label="RMSE", value=f"{rmse:.2f}")
            st.metric(label="MAE", value=f"{mae:.2f}")
            st.metric(label="R2 Score", value=f"{r2:.2f}")


