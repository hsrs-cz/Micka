-- version 20200101

CREATE TABLE codelist
(
  codelist_id integer NOT NULL,
  el_id numeric(10,0) DEFAULT 0,
  codelist_name character varying(50),
  codelist_domain character varying(3),
  inspire numeric(1,0) DEFAULT 0,
  CONSTRAINT codelist_pkey PRIMARY KEY (codelist_id)
);
CREATE INDEX codelist_idx_el_id ON codelist USING btree(el_id);

CREATE TABLE codelist_my
(
  codelist_id integer NOT NULL,
  is_vis numeric(1,0) NOT NULL DEFAULT 1,
  CONSTRAINT codelist_my_pkey PRIMARY KEY (codelist_id)
);

CREATE TABLE contacts
(
  id serial NOT NULL,
  person character varying(80),
  organisation character varying(150),
  organisation_en character varying(150),
  tag character varying(250),
  org_function character varying(70),
  org_function_en character varying(70),
  phone character(20),
  fax character(20),
  point character varying(250),
  city character varying(250),
  adminarea character varying(250),
  postcode character(10),
  country character(25),
  email character(50),
  url character varying,
  view_group character varying(40),
  edit_group character varying(40),
  username character varying(40),
  CONSTRAINT contacts_pkey PRIMARY KEY (id)
);

CREATE TABLE elements
(
  el_id numeric(10,0) NOT NULL,
  el_name character varying(255),
  el_short_name character varying(50) NOT NULL,
  md_standard numeric(1,0) NOT NULL,
  form_code character varying(3),
  from_codelist numeric(10,0),
  only_value numeric(1,0) NOT NULL DEFAULT 0,
  form_ignore numeric(1,0) NOT NULL DEFAULT 0,
  form_pack numeric(1,0) NOT NULL DEFAULT 0,
  multi_lang numeric(1,0) NOT NULL DEFAULT 0,
  choice character(1),
  is_atrib numeric(1,0) NOT NULL DEFAULT 0,
  CONSTRAINT elements_pkey PRIMARY KEY (el_id)
);

CREATE TABLE harvest
(
  name character(255) NOT NULL,
  source character(256),
  type character(64),
  h_interval real,
  updated timestamp with time zone,
  result character varying,
  handlers character varying,
  period character(6),
  filter character varying(256),
  create_user character varying(50),
  active numeric(1,0),
  CONSTRAINT harvest_idx PRIMARY KEY (name)
);

CREATE TABLE label
(
  label_type character(2) NOT NULL,
  label_join numeric(10,0) DEFAULT 0,
  lang character(3) NOT NULL,
  label_text character varying(250) NOT NULL,
  label_help character varying
);
CREATE INDEX label_idx_label_join ON label USING btree(label_join);

CREATE TABLE mandatory
(
  mandt_code character(1) NOT NULL,
  text character varying(40),
  CONSTRAINT mandatory_pkey PRIMARY KEY (mandt_code)
);

CREATE TABLE packages
(
  package_id numeric(10,0) NOT NULL,
  package_order numeric(10,0) NOT NULL DEFAULT 0,
  package_name character varying(70),
  md_id numeric(10,0) DEFAULT 0,
  md_standard numeric(3,0),
  CONSTRAINT packages_pkey PRIMARY KEY (package_id)
);

CREATE TABLE profil
(
  profil_id smallint NOT NULL,
  md_id numeric(10,0) NOT NULL,
  mandt_code character varying(3),
  CONSTRAINT profil_idx PRIMARY KEY (profil_id, md_id)
);

CREATE TABLE profil_names
(
  profil_id smallint NOT NULL,
  profil_order smallint NOT NULL,
  profil_name character(40),
  md_standard numeric(3,0),
  is_vis numeric(1,0) DEFAULT 1,
  is_packages numeric(1,0) DEFAULT 0,
  is_inspire numeric(1,0) DEFAULT 0,
  edit_lite_template character varying(25),
  CONSTRAINT profil_names_pkey PRIMARY KEY (profil_id)
);

CREATE TABLE standard
(
  md_standard numeric(3,0) NOT NULL,
  md_standard_order numeric(3,0),
  md_standard_name character varying(50),
  md_standard_short_name character varying(15),
  is_vis numeric(1,0),
  CONSTRAINT standard_pkey PRIMARY KEY (md_standard)
);

CREATE TABLE standard_schema
(
  md_standard numeric(3,0) NOT NULL DEFAULT 0,
  md_id numeric(10,0) NOT NULL,
  parent_md_id numeric(10,0) NOT NULL,
  md_left numeric(6,0) NOT NULL,
  md_right numeric(6,0) NOT NULL,
  md_level numeric(3,0) NOT NULL,
  el_id numeric(10,0) NOT NULL,
  mandt_code character varying(3),
  min_nb numeric(3,0) NOT NULL DEFAULT 1,
  max_nb numeric(3,0),
  button_exe character varying(50),
  package_id numeric(10,0),
  md_path character varying(255),
  md_path_el character varying,
  md_mapping character(10),
  inspire_code character(5),
  is_uri numeric(1,0),
  CONSTRAINT tree_idx PRIMARY KEY (md_standard, md_id)
);
CREATE INDEX standard_schema_idx_el_id ON standard_schema USING btree(el_id);
CREATE INDEX standard_schema_idx_md_left ON standard_schema USING btree(md_left);
CREATE INDEX standard_schema_idx_md_mapping ON standard_schema USING btree(md_mapping COLLATE pg_catalog."default");
CREATE INDEX standard_schema_idx_md_right ON standard_schema USING btree(md_right);
CREATE INDEX standard_schema_idx_package_id ON standard_schema USING btree(package_id);

CREATE TABLE users
(
  id serial NOT NULL,
  username character(50) NOT NULL,
  password character(70) NOT NULL,
  role_editor boolean DEFAULT false,
  role_publisher boolean DEFAULT false,
  role_admin boolean DEFAULT false,
  groups character varying(100),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX users_username_key ON users USING btree(username COLLATE pg_catalog."default");

CREATE TABLE md
(
  recno numeric(10,0) NOT NULL,
  uuid character(80),
  md_standard numeric(3,0) NOT NULL DEFAULT 0,
  lang character varying(255) NOT NULL,
  data_type numeric(1,0) NOT NULL DEFAULT 0,
  create_user character varying(50) NOT NULL,
  create_date date NOT NULL,
  last_update_user character varying(50),
  last_update_date date,
  edit_group character varying(50),
  view_group character varying(50),
  x1 double precision,
  y1 double precision,
  x2 double precision,
  y2 double precision,
  the_geom geometry,
  range_begin date,
  range_end date,
  md_update date,
  title character varying(255),
  server_name character varying(255) DEFAULT 'local'::bpchar,
  valid smallint,
  prim smallint,
  for_inspire numeric(1,0),
  pxml xml,
  CONSTRAINT md_pkey PRIMARY KEY (recno),
  CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(the_geom) = 2),
  CONSTRAINT enforce_geotype_the_geom CHECK (geometrytype(the_geom) = 'MULTIPOLYGON'::text OR the_geom IS NULL),
  CONSTRAINT enforce_srid_the_geom CHECK (st_srid(the_geom) = 0)
);
CREATE INDEX md_last_update_idx ON md USING btree(last_update_date);
CREATE INDEX md_title_idx ON md USING btree(title COLLATE pg_catalog."default");
CREATE UNIQUE INDEX md_uuid_idx ON md USING btree(uuid COLLATE pg_catalog."default");
CREATE INDEX fxml_en_idx ON md USING GIN (to_tsvector('english', CAST (pxml AS varchar)));

CREATE TABLE md_values
(
  recno numeric(10,0) DEFAULT 0,
  md_id numeric(10,0) NOT NULL DEFAULT 0,
  md_value character varying,
  md_path character varying(255),
  lang character(3),
  package_id numeric(10,0)
);
CREATE INDEX md_values_mdid_idx ON md_values USING btree(md_id);
CREATE INDEX md_values_recno_idx ON md_values USING btree(recno);


CREATE TABLE edit_md
(
  recno numeric(10,0) NOT NULL,
  edit_user character varying(50),
  edit_timestamp integer,
  md_recno numeric(10,0) NOT NULL,
  uuid character(80),
  md_standard numeric(3,0) NOT NULL DEFAULT 0,
  lang character varying(255) NOT NULL,
  data_type numeric(1,0) NOT NULL DEFAULT 0,
  create_user character varying(50) NOT NULL,
  create_date date NOT NULL,
  last_update_user character varying(50),
  last_update_date date,
  edit_group character varying(50),
  view_group character varying(50),
  x1 double precision,
  y1 double precision,
  x2 double precision,
  y2 double precision,
  the_geom geometry,
  range_begin date,
  range_end date,
  md_update date,
  title character varying(255),
  server_name character varying(255) DEFAULT 'local'::bpchar,
  valid smallint,
  prim smallint,
  pxml xml,
  CONSTRAINT edit_md_pkey PRIMARY KEY (recno),
  CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(the_geom) = 2),
  CONSTRAINT enforce_geotype_the_geom CHECK (geometrytype(the_geom) = 'MULTIPOLYGON'::text OR the_geom IS NULL),
  CONSTRAINT enforce_srid_the_geom CHECK (st_srid(the_geom) = 0)
);
CREATE INDEX edit_md_title_idx ON edit_md USING btree(title COLLATE pg_catalog."default");
CREATE INDEX edit_md_uuid_idx ON edit_md USING btree(uuid COLLATE pg_catalog."default");

CREATE TABLE edit_md_values
(
  recno numeric(10,0) DEFAULT 0,
  md_id numeric(10,0) NOT NULL DEFAULT 0,
  md_value character varying,
  md_path character varying(255),
  lang character(3),
  package_id numeric(10,0)
);
CREATE INDEX edit_md_values_mdid_idx ON edit_md_values USING btree(md_id);
CREATE INDEX edit_md_values_recno_idx ON edit_md_values USING btree(recno);

