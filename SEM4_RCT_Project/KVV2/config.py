import os

NCBI_API_KEY = os.getenv("NCBI_API_KEY", "")
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")

# PubMed search query
SEARCH_QUERY = (
    '("obesity"[MeSH] OR "obesity"[tiab])'
    ' AND ("hyperphagia"[tiab] OR "binge eating"[tiab] OR "appetite"[tiab])'
    ' AND ("randomized controlled trial"[pt] OR "RCT"[tiab])'
    ' AND "humans"[MeSH Terms]'
)

CLINICAL_FEATURE = "hyperphagia"
DISEASE          = "obesity"

# Quantitative columns the LLM should extract
QUANT_COLUMNS = [
    "key_active",
    "n_total", "n_treatment", "n_control",
    "dose_mg", "duration_weeks",
    "hyperphagia_score_hq_ct_baseline", "hyperphagia_score_hq_ct_endpoint", "hyperphagia_score_hq_ct_change",
    "appetite_vas_baseline", "appetite_vas_endpoint", "appetite_vas_change",
    "binge_eating_per_week_baseline", "binge_eating_per_week_endpoint", "binge_eating_per_week_change",
    "p_value", "effect_size", "confidence_interval",
]

# File names passed between steps
PMID_FILE       = "pmids.txt"
PAPERS_FILE     = "papers.json"
EXTRACTED_FILE  = "extracted.json"
VALIDATED_FILE  = "validated.json"
EXCEL_FILE      = "obesity_hyperphagia_rcts.xlsx"

# Limits
MAX_RESULTS     = 500          # cap total PMIDs fetched
BATCH_SIZE      = 20           # PMIDs per efetch call
REQUEST_DELAY   = 0.11 if NCBI_API_KEY else 0.35   # seconds between calls
GROQ_MODEL      = "llama3-70b-8192"
GROQ_DELAY      = 2.2          # seconds between Groq calls (free tier ~30/min)