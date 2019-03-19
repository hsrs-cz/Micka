-- Please edit this file according your langugae support requirements

CREATE INDEX fxml_cs_idx ON md USING GIN (to_tsvector('cs', CAST (pxml AS varchar)));
CREATE INDEX fxml_es_idx ON md USING GIN (to_tsvector('es', CAST (pxml AS varchar)));
