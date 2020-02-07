-- Please edit this file according your language support requirements
CREATE INDEX fxml_es_idx ON md USING GIN (to_tsvector('es', CAST (pxml AS varchar)));
