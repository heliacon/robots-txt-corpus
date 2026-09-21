-- Indexes for robots-corpus-lite.db. robots-corpus.db already has them.
-- Run:  sqlite3 robots-corpus-lite.db < indexes.sql   (safe to run again)

CREATE INDEX IF NOT EXISTS idx_sites_band ON sites(band);
CREATE INDEX IF NOT EXISTS idx_sites_cf ON sites(cloudflare_managed);
CREATE INDEX IF NOT EXISTS idx_agents_token ON agents(token);
CREATE INDEX IF NOT EXISTS idx_agents_domain ON agents(domain);
CREATE INDEX IF NOT EXISTS idx_agents_role ON agents(role);
CREATE INDEX IF NOT EXISTS idx_agents_shaped ON agents(ai_shaped, in_registry);
CREATE INDEX IF NOT EXISTS idx_sites_template ON sites(template_id);
CREATE INDEX IF NOT EXISTS idx_agents_tok_allow ON agents(token, allowed_at_root);
CREATE INDEX IF NOT EXISTS idx_findings_rank ON findings(rank);
