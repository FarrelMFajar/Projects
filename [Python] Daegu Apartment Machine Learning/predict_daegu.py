import streamlit as st
import pandas as pd
import numpy as np
import pickle

# Load the model
@st.cache_resource
def load_model():
    with open('ml.pkl', 'rb') as file:
        model = pickle.load(file)
    return model

# Define app interface
st.title('Apartment Price Prediction: Daegu')

# Input fields for prediction
st.subheader("Enter Apartment Details:")
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

# Prediction button
if st.button('Predict'):
    model = load_model()
    input_df = pd.DataFrame([input_data])
    
    # Note: Preprocessing should match training setup
    # You need to include preprocessing steps here before feeding data to the model
    
    # Predict price
    prediction = model.predict(input_df)
    st.success(f"Predicted Price: ₩{prediction[0]:,.2f}")
