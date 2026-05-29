# import requests
# import csv
# import xml.etree.ElementTree as ET
# from datetime import datetime
# import os
#
# os.environ["http_proxy"] = "http://245hsbd013%40ibab.ac.in:tanega2001@proxy.ibab.ac.in:3128"
# os.environ["https_proxy"] = "http://245hsbd013%40ibab.ac.in:tanega2001@proxy.ibab.ac.in:3128"
#
# def search_pubmed(query, max_results=15, mindate="2020/01/01", search_type="reviews"):
#     base_url = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/"
#
#     # Choose search filter based on user choice
#     if search_type == "reviews":
#         filter_term = "(review[pt] OR systematic review)"
#     elif search_type == "research":
#         filter_term = "(clinical trial[pt] OR randomized controlled trial[pt] OR RCT OR 'clinical study')"
#     else:  # both
#         filter_term = "(review[pt] OR systematic review OR clinical trial[pt] OR randomized controlled trial[pt])"
#
#     search_params = {
#         "db": "pubmed",
#         "term": f"{query} AND {filter_term}",
#         "retmax": max_results,
#         "mindate": mindate,
#         "sort": "relevance",
#         "retmode": "xml"
#     }
#
#     search_resp = requests.get(base_url + "esearch.fcgi", params=search_params)
#     root = ET.fromstring(search_resp.content)
#     pmids = [id_elem.text for id_elem in root.findall(".//Id")]
#
#     if not pmids:
#         print("❌ No papers found.")
#         return []
#
#     # Fetch abstracts
#     fetch_params = {
#         "db": "pubmed",
#         "id": ",".join(pmids),
#         "retmode": "xml"
#     }
#     fetch_resp = requests.get(base_url + "efetch.fcgi", params=fetch_params)
#     fetch_root = ET.fromstring(fetch_resp.content)
#
#     papers = []
#     for article in fetch_root.findall(".//PubmedArticle"):
#         pmid = article.find(".//PMID").text
#         title = article.find(".//ArticleTitle").text or "N/A"
#         abstract = ""
#         abs_elem = article.find(".//Abstract/AbstractText")
#         if abs_elem is not None:
#             abstract = abs_elem.text or ""
#         papers.append({"PMID": pmid, "Title": title, "Abstract": abstract})
#
#     return papers
#
#
# def generate_table_template(feature_name, papers, search_type):
#     columns = [
#         "Source", "Source_Type", "Action", "Direction", "Effect_Magnitude", "Target",
#         "Target_Type", "Node_State", "Pathway_Axis", "Mechanism", "Physiological_Effect",
#         "Organ_Tissue_Cell", "Primary_Location"
#     ]
#     filename = f"{feature_name.replace(' ', '_')}_Molecular_Table_{search_type}_{datetime.now().strftime('%Y%m%d')}.csv"
#
#     with open(filename, "w", newline="", encoding="utf-8") as f:
#         writer = csv.writer(f)
#         writer.writerow(columns)
#         writer.writerow([f"── AUTO-GENERATED TEMPLATE FOR {feature_name.upper()} ── ({search_type.upper()})"])
#         writer.writerow(["[Paste rows here after LLM extraction]", "", "", "", "", "", "", "", "", "", "", "", ""])
#
#     print(f"✅ Template saved: {filename}")
#     print(f"Found {len(papers)} papers ({search_type}).")
#
#     # Show first 5 for quick validation
#     for p in papers[:5]:
#         print(f"\nPMID: {p['PMID']} | {p['Title'][:120]}...")
#         print(f"Abstract snippet: {p['Abstract'][:250]}...")
#
#
# # === USAGE ===
# if __name__ == "__main__":
#     feature = input("Enter clinical feature (e.g. 'insulin resistance obesity'): ")
#     print("\nWhat do you want to search for?")
#     print("1 = Reviews only (best for Molecular Table pathways)")
#     print("2 = Original research / RCTs only (best for Actives & meta-analysis)")
#     print("3 = Both")
#     choice = input("Enter 1, 2 or 3: ")
#
#     search_type = "reviews" if choice == "1" else "research" if choice == "2" else "both"
#     papers = search_pubmed(feature, search_type=search_type)
#     generate_table_template(feature, papers, search_type)


# Pipeline: PDF/abstract → entity extraction → validation → table

# Step 1 — Extract with structured prompt
system_prompt = """
You extract molecular interaction rows. For each interaction output JSON with:
{
  "source": str,           # upstream molecule/state
  "source_type": str,      # Hormone | Enzyme | Kinase | Metabolite | etc.
  "action": str,           # Binds | Phosphorylates | Activates | Releases
  "direction": int,        # +1 activating, -1 inhibitory
  "target": str,
  "target_type": str,
  "pathway_axis": str,     # Insulin Signaling | Lipotoxicity | Inflammation
  "mechanism": str,        # one sentence max
  "evidence": str          # PMID or "inferred"
}
Return a JSON array only. No prose.
"""

# Step 2 — Build graph and validate
import networkx as nx


def validate_network(rows):
    G = nx.DiGraph()
    for r in rows:
        G.add_edge(r["source"], r["target"],
                   direction=r["direction"],
                   action=r["action"])

    issues = []

    # Check 1: isolated nodes (appear only as source, never as target — not a known root)
    known_roots = {"Insulin", "Obesity / Adiposity Expansion", "Dietary Fat"}
    for node in G.nodes():
        if G.in_degree(node) == 0 and node not in known_roots:
            issues.append(f"Floating source (no upstream): {node}")

    # Check 2: dead-end nodes (appear only as target, never as source)
    known_sinks = {"Type 2 Diabetes", "GLUT4 translocation", "Gluconeogenesis suppression"}
    for node in G.nodes():
        if G.out_degree(node) == 0 and node not in known_sinks:
            issues.append(f"Dead-end node (no downstream): {node}")

    # Check 3: self-loops
    for u, v in G.edges():
        if u == v:
            issues.append(f"Self-loop: {u}")

    # Check 4: weakly connected components
    components = list(nx.weakly_connected_components(G))
    if len(components) > 1:
        issues.append(f"Disconnected graph: {len(components)} components")

    return issues, G

# Step 3 — Cross-check against curated DB (optional but powerful)
# Map your node names to UniProt/HGNC IDs, then verify edges against:
# - STRING DB (protein interactions)
# - SignaLink / KEGG PATHWAY
# - PhosphoSitePlus (for phosphorylation events specifically)