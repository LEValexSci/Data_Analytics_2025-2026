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

# -----------------------------
# LOGIC
# -----------------------------
def check_drug(drug_name):
    drug_name = drug_name.strip().lower()

    # -----------------------------
    # 1. Search fuzzymatching
    # -----------------------------
    response = supabase.table("fuzzymatching") \
        .select("*") \
        .ilike("dci_name_md", f"%{drug_name}%") \
        .execute()

    if not response.data:
        return "❌ Drug not found in matching database"

    matches = response.data

    # -----------------------------
    # 2. Select best match (highest fuzzy_score)
    # -----------------------------
    # Filter out rows without fuzzy_score just in case
    matches_with_score = [m for m in matches if m.get("fuzzy_score") is not None]

    if matches_with_score:
        best_match = max(matches_with_score, key=lambda x: x.get("fuzzy_score", 0))
    else:
        best_match = matches[0]  # fallback if no scores

    matched_es = best_match.get("matched_dci_es")
    atc_es = best_match.get("atc_es")
    atc_md = best_match.get("atc_md")

    # -----------------------------
    # 3. Search coverage (PRIMARY: using matched_dci_es + atc_es)
    # -----------------------------
    coverage = None

    if matched_es and atc_es:
        coverage = supabase.table("drug_coverage") \
            .select("*") \
            .eq("source", "es") \
            .eq("dci_name", matched_es) \
            .eq("atc_code", atc_es) \
            .execute()

    # -----------------------------
    # 4. Fallback: use atc_md if no ES match
    # -----------------------------
    if (not coverage or not coverage.data) and atc_md:
        coverage = supabase.table("drug_coverage") \
            .select("*") \
            .eq("source", "es") \
            .eq("atc_code", atc_md) \
            .execute()

    # -----------------------------
    # 5. Evaluate result
    # -----------------------------
    if not coverage or not coverage.data:
        return "⚠️ No coverage information found"

    is_covered = coverage.data[0].get("is_covered")

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