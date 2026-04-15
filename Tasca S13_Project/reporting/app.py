import streamlit as st
from supabase import create_client, Client
import os
from dotenv import load_dotenv

st.markdown("""
    <style>
    .stButton>button {
        background-color: #2E86C1;
        color: white;
        border-radius: 8px;
        height: 3em;
        width: 100%;
    }
    </style>
""", unsafe_allow_html=True)

# -----------------------------
# CONFIG
# -----------------------------
load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")

supabase: Client = create_client(url, key)

# -----------------------------
# UI
# -----------------------------
st.set_page_config(page_title="Drug Coverage Checker", layout="centered")

st.title("💊 Drug Coverage Checker")
st.markdown("Check if your treatment is available and covered in Spain 🇪🇸")

drug_input = st.text_input("Enter drug name (DCI)", placeholder="e.g. Paracetamolum")

# -----------------------------
# LOGIC
# -----------------------------
def check_drug(drug_name):
    
    # 1. Search fuzzymatching
    response = supabase.table("fuzzymatching") \
        .select("*") \
        .ilike("dci_name_md", drug_name) \
        .execute()
    
    if not response.data:
        return "❌ Drug not found in matching database"
    
    match = response.data[0]
    matched_es = match["matched_dci_es"]
    atc_code = match["atc_code"]
    
    # 2. Search coverage
    coverage = supabase.table("drug_coverage") \
        .select("*") \
        .eq("source", "es") \
        .eq("dci_name", matched_es) \
        .eq("atc_code", atc_code) \
        .execute()
    
    if not coverage.data:
        return "⚠️ No coverage information found"
    
    is_covered = coverage.data[0]["is_covered"]
    
    # 3. Output message
    if is_covered:
        return "✅ Equivalent treatment is available and covered by insurance"
    else:
        return "⚠️ A similar treatment might not be available right now. Your family doctor can help you choose the best alternative."


# -----------------------------
# BUTTON ACTION
# -----------------------------
if st.button("Check availability"):
    if drug_input:
        result = check_drug(drug_input)
        st.success(result)
    else:
        st.warning("Please enter a drug name")