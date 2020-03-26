INSERT INTO elements VALUES (34, 'LanguageCode', 'LanguageCode', 0, 'C', -390, 1, 0, 0, 0, NULL, 0);
UPDATE standard_schema SET el_id=34 WHERE md_standard=0 AND md_id IN (5539,307);
INSERT INTO label VALUES ('EL',34,'eng','LanguageCode',NULL);
INSERT INTO label VALUES ('EL',34,'cze','LanguageCode',NULL);
INSERT INTO label VALUES ('EL',34,'spa','Código del Lenguaje',NULL);
