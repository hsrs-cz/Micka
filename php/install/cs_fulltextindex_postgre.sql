-- Please edit this file according your language support requirements
CREATE INDEX fxml_cs_idx ON md USING GIN (to_tsvector('cs', CAST (pxml AS varchar)));
