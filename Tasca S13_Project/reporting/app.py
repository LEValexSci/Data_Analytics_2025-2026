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
st.set_page_config(page_title="Drug Treatment Coverage Checker", layout="centered")

st.title("💊 Drug Treatment Coverage Checker")
st.markdown("Check if your treatment is available and covered in Spain 🇪🇸")

drug_input = st.text_input("Enter drug name (DCI)", placeholder="e.g. Paracetamolum")
age = st.number_input("Your age", min_value=0, max_value=120)
country = st.text_input("Country of origin or Ethnicity", placeholder="e.g. Spain")
gender = st.number_input("Your sex by birth", placeholder="e.g. Woman")

# -----------------------------
# LOG SEARCH
# -----------------------------
def log_search(query, matched_es, atc_code, is_covered, result, age, country):
    supabase.table("search_logs").insert({
        "query": query,
        "matched_dci_es": matched_es,
        "atc_code": atc_code,
        "is_covered": is_covered,
        "result_message": result,
        "user_age": age,
        "user_country": country
    }).execute()
# -----------------------------
# LOGIC
# -----------------------------
def check_drug(drug_name, age=None, country=None, gender=None):
    drug_name = drug_name.strip().lower()

    response = supabase.table("fuzzymatching") \
        .select("*") \
        .ilike("dci_name_md", f"%{drug_name}%") \
        .execute()

    if not response.data:
        result_message = "❌ Drug not found in matching database"

        log_search(drug_name, None, None, None, result_message, age, country)
        return result_message

    matches = response.data

    best_match = max(matches, key=lambda x: x.get("fuzzy_score", 0))

    matched_es = best_match.get("matched_dci_es")
    atc_es = best_match.get("atc_es")
    atc_md = best_match.get("atc_md")

    coverage = None

    if matched_es and atc_es:
        coverage = supabase.table("drug_coverage") \
            .select("*") \
            .eq("source", "es") \
            .eq("dci_name", matched_es) \
            .eq("atc_code", atc_es) \
            .execute()

    if (not coverage or not coverage.data) and atc_md:
        coverage = supabase.table("drug_coverage") \
            .select("*") \
            .eq("source", "es") \
            .eq("atc_code", atc_md) \
            .execute()

    if not coverage or not coverage.data:
        result_message = "⚠️ No coverage information found"
        log_search(drug_name, matched_es, atc_es or atc_md, None, result_message, age, country)
        return result_message

    is_covered = coverage.data[0].get("is_covered")

    if is_covered:
        result_message = "✅ Equivalent treatment is available and covered by insurance"
    else:
        result_message = "⚠️ A similar treatment might not be available right now."

    # 🔥 LOG EVERYTHING
    log_search(drug_name, matched_es, atc_es or atc_md, is_covered, result_message, age, country)

    return result_message


# -----------------------------
# BUTTON ACTION
# -----------------------------
if st.button("Check availability"):
    if drug_input:
        result = check_drug(drug_input, age, country)
        st.success(result)
    else:
        st.warning("Please enter a drug name")