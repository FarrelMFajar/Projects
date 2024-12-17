# Load dataset
@st.cache_data
def load_data():
    return pd.read_csv('Daegu_Cleaned.csv')

# Feature engineering
@st.cache_data
def preprocess_data(df):
    df['price_per_sqm'] = df['SalePrice'] / df['Size(sqf)']
    return df

# Evaluate model
@st.cache_data
def evaluate_model(model, X, y):
    y_pred = model.predict(X)
    residuals = y - y_pred
    rmse = np.sqrt(mean_squared_error(y, y_pred))
    mae = mean_absolute_error(y, y_pred)
    r2 = r2_score(y, y_pred)
    return y_pred, residuals, rmse, mae, r2

# Streamlit app configuration
st.set_page_config(page_title='Apartment Price Prediction: Daegu', layout='wide')

# Sidebar navigation
page = st.sidebar.selectbox("Select Page", ['Data Visualization', 'Prediction'])

model = load_model()
data = preprocess_data(load_data())

if page == 'Data Visualization':
    st.title('Apartment Daegu Data Visualization')

    # Dataset overview
    st.subheader("Data Overview")
    st.dataframe(data.head(10))

    # Feature distribution
    st.subheader("Feature Distributions")
    selected_feature = st.selectbox("Select Feature", data.columns)
    plt.figure(figsize=(10, 5))
    sns.histplot(data[selected_feature], kde=True, color='blue')
    plt.title(f"Distribution of {selected_feature}")
    st.pyplot(plt)

    # Feature-target relationships
    st.subheader("Feature vs Target Relationship")
    selected_feature_rel = st.selectbox("Select Feature for Relationship", data.columns)
    plt.figure(figsize=(10, 5))
    sns.scatterplot(x=data[selected_feature_rel], y=data['SalePrice'], color='blue')
    plt.title(f'Relationship between {selected_feature_rel} and SalePrice')
    st.pyplot(plt)

elif page == 'Prediction':
    st.title('Apartment Price Prediction')
    st.write("Input Apartment Details: ")

    input_data = {
        'Size(sqf)': st.number_input("Size (sqft)", min_value=0.0, step=1.0),
        'YearBuilt': st.number_input("Year Built", min_value=1900, max_value=2024, step=1),
        'N_Parkinglot(Basement)': st.number_input("Number of Parking Lots (Basement)", min_value=0, step=1),
        'HallwayType': st.selectbox("Hallway Type", options=['Mixed', 'Corridor', 'Terraced']),
        'TimeToSubway': st.selectbox("Time to Subway", options=['0-5min', '5-10min', '10-15min', '15-20min', 'no_bus_stop_nearby']),
        'SubwayStation': st.selectbox("Subway Station", options=['Bangoge', 'Kyungbuk_uni_hospital', 'Chil-sung-market', 'Daegu', 'Banwoldang', 'Sin-nam', 'Myung-duk', 'no_subway_nearby']),
        'N_FacilitiesNearBy(ETC)': st.number_input("Number of Nearby Facilities (ETC)", min_value=0, step=1),
        'N_FacilitiesNearBy(PublicOffice)': st.number_input("Number of Nearby Public Office Facilities", min_value=0, step=1),
        'N_SchoolNearBy(University)': st.number_input("Number of Nearby Universities", min_value=0, step=1),
    }

    if st.button('Predict'):
        input_df = pd.DataFrame([input_data])
        prediction = model.predict(input_df)[0]
        st.success('Prediction Complete!')
        st.metric(label="Predicted Price", value=f"₩{prediction:,.2f}")

        # Model evaluation
        X = data.drop('SalePrice', axis=1)
        y = data['SalePrice']
        y_pred, residuals, rmse, mae, r2 = evaluate_model(model, X, y)

        # Evaluation metrics
        st.subheader("Model Evaluation Metrics")
        st.metric(label="RMSE", value=f"{rmse:.2f}")
        st.metric(label="MAE", value=f"{mae:.2f}")
        st.metric(label="R² Score", value=f"{r2:.2f}")

        # Prediction vs Actual Plot
        st.subheader("Prediction vs Actual Plot")
        plt.figure(figsize=(10, 6))
        sns.scatterplot(x=y, y=y_pred, color='blue')
        plt.xlabel('Actual Price')
        plt.ylabel('Predicted Price')
        plt.title('Predicted vs Actual Prices')
        st.pyplot(plt)

        # Residual Plot
        st.subheader("Residual Plot")
        plt.figure(figsize=(10, 6))
        sns.scatterplot(x=y_pred, y=residuals, color='blue')
        plt.axhline(0, color='red', linestyle='--')
        plt.xlabel('Predicted Price')
        plt.ylabel('Residuals')
        plt.title('Residuals Plot')
        st.pyplot(plt)

        # Error Distribution Plot
        st.subheader("Error Distribution")
        plt.figure(figsize=(10, 6))
        sns.histplot(residuals, kde=True, color='blue')
        plt.xlabel('Residuals')
        plt.title('Distribution of Residuals')
        st.pyplot(plt)

        # Feature Importance (if applicable)
        if hasattr(model, 'feature_importances_'):
            st.subheader("Feature Importance")
            importance = pd.Series(model.feature_importances_, index=X.columns)
            importance.nlargest(10).plot(kind='barh', color='blue')
            plt.title('Top 10 Important Features')
            st.pyplot(plt)
