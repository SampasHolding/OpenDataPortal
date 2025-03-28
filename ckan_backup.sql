--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.activity (
    id text NOT NULL,
    "timestamp" timestamp without time zone,
    user_id text,
    object_id text,
    activity_type text,
    data text
);


ALTER TABLE public.activity OWNER TO ckan_default;

--
-- Name: activity_detail; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.activity_detail (
    id text NOT NULL,
    activity_id text,
    object_id text,
    object_type text,
    activity_type text,
    data text
);


ALTER TABLE public.activity_detail OWNER TO ckan_default;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO ckan_default;

--
-- Name: api_token; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.api_token (
    id text NOT NULL,
    name text,
    user_id text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_access timestamp without time zone,
    plugin_extras jsonb
);


ALTER TABLE public.api_token OWNER TO ckan_default;

--
-- Name: dashboard; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.dashboard (
    user_id text NOT NULL,
    activity_stream_last_viewed timestamp without time zone NOT NULL,
    email_last_sent timestamp without time zone DEFAULT LOCALTIMESTAMP NOT NULL
);


ALTER TABLE public.dashboard OWNER TO ckan_default;

--
-- Name: group; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public."group" (
    id text NOT NULL,
    name text NOT NULL,
    title text,
    description text,
    created timestamp without time zone,
    state text,
    type text NOT NULL,
    approval_status text,
    image_url text,
    is_organization boolean DEFAULT false,
    extras jsonb,
    CONSTRAINT group_flat_extras CHECK (((jsonb_typeof(extras) = 'object'::text) AND (NOT jsonb_path_exists(extras, '$.*?(@.type() != "string")'::jsonpath))))
);


ALTER TABLE public."group" OWNER TO ckan_default;

--
-- Name: member; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.member (
    id text NOT NULL,
    group_id text,
    table_id text NOT NULL,
    state text,
    table_name text NOT NULL,
    capacity text NOT NULL
);


ALTER TABLE public.member OWNER TO ckan_default;

--
-- Name: package; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.package (
    id text NOT NULL,
    name character varying(100) NOT NULL,
    title text,
    version character varying(100),
    url text,
    notes text,
    author text,
    author_email text,
    maintainer text,
    maintainer_email text,
    state text,
    license_id text,
    type text,
    owner_org text,
    private boolean DEFAULT false,
    metadata_modified timestamp without time zone,
    creator_user_id text,
    metadata_created timestamp without time zone,
    plugin_data jsonb,
    extras jsonb,
    CONSTRAINT package_flat_extras CHECK (((jsonb_typeof(extras) = 'object'::text) AND (NOT jsonb_path_exists(extras, '$.*?(@.type() != "string")'::jsonpath))))
);


ALTER TABLE public.package OWNER TO ckan_default;

--
-- Name: package_member; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.package_member (
    package_id text NOT NULL,
    user_id text NOT NULL,
    capacity text NOT NULL,
    modified timestamp without time zone NOT NULL
);


ALTER TABLE public.package_member OWNER TO ckan_default;

--
-- Name: package_relationship; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.package_relationship (
    id text NOT NULL,
    subject_package_id text,
    object_package_id text,
    type text,
    comment text,
    state text
);


ALTER TABLE public.package_relationship OWNER TO ckan_default;

--
-- Name: package_tag; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.package_tag (
    id text NOT NULL,
    state text,
    package_id text,
    tag_id text
);


ALTER TABLE public.package_tag OWNER TO ckan_default;

--
-- Name: resource; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.resource (
    id text NOT NULL,
    url text NOT NULL,
    format text,
    description text,
    "position" integer,
    hash text,
    state text,
    extras text,
    name text,
    resource_type text,
    mimetype text,
    mimetype_inner text,
    size bigint,
    last_modified timestamp without time zone,
    cache_url text,
    cache_last_updated timestamp without time zone,
    created timestamp without time zone,
    url_type text,
    package_id text DEFAULT ''::text NOT NULL,
    metadata_modified timestamp without time zone
);


ALTER TABLE public.resource OWNER TO ckan_default;

--
-- Name: resource_view; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.resource_view (
    id text NOT NULL,
    resource_id text,
    title text,
    description text,
    view_type text NOT NULL,
    "order" integer NOT NULL,
    config text
);


ALTER TABLE public.resource_view OWNER TO ckan_default;

--
-- Name: system_info; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.system_info (
    id integer NOT NULL,
    key character varying(100) NOT NULL,
    value text,
    state text DEFAULT 'active'::text NOT NULL
);


ALTER TABLE public.system_info OWNER TO ckan_default;

--
-- Name: system_info_id_seq; Type: SEQUENCE; Schema: public; Owner: ckan_default
--

CREATE SEQUENCE public.system_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.system_info_id_seq OWNER TO ckan_default;

--
-- Name: system_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ckan_default
--

ALTER SEQUENCE public.system_info_id_seq OWNED BY public.system_info.id;


--
-- Name: tag; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.tag (
    id text NOT NULL,
    name character varying(100) NOT NULL,
    vocabulary_id character varying(100)
);


ALTER TABLE public.tag OWNER TO ckan_default;

--
-- Name: task_status; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.task_status (
    id text NOT NULL,
    entity_id text NOT NULL,
    entity_type text NOT NULL,
    task_type text NOT NULL,
    key text NOT NULL,
    value text NOT NULL,
    state text,
    error text,
    last_updated timestamp without time zone
);


ALTER TABLE public.task_status OWNER TO ckan_default;

--
-- Name: term_translation; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.term_translation (
    term text NOT NULL,
    term_translation text NOT NULL,
    lang_code text NOT NULL
);


ALTER TABLE public.term_translation OWNER TO ckan_default;

--
-- Name: tracking_raw; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.tracking_raw (
    user_key character varying(100) NOT NULL,
    url text NOT NULL,
    tracking_type character varying(10) NOT NULL,
    access_timestamp timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.tracking_raw OWNER TO ckan_default;

--
-- Name: tracking_summary; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.tracking_summary (
    url text NOT NULL,
    package_id text,
    tracking_type character varying(10) NOT NULL,
    count integer NOT NULL,
    running_total integer DEFAULT 0 NOT NULL,
    recent_views integer DEFAULT 0 NOT NULL,
    tracking_date date
);


ALTER TABLE public.tracking_summary OWNER TO ckan_default;

--
-- Name: user; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public."user" (
    id text NOT NULL,
    name text NOT NULL,
    apikey text,
    created timestamp without time zone,
    about text,
    password text,
    fullname text,
    email text,
    reset_key text,
    sysadmin boolean DEFAULT false,
    activity_streams_email_notifications boolean DEFAULT false,
    state text DEFAULT 'active'::text NOT NULL,
    plugin_extras jsonb,
    image_url text,
    last_active timestamp without time zone
);


ALTER TABLE public."user" OWNER TO ckan_default;

--
-- Name: user_following_dataset; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.user_following_dataset (
    follower_id text NOT NULL,
    object_id text NOT NULL,
    datetime timestamp without time zone NOT NULL
);


ALTER TABLE public.user_following_dataset OWNER TO ckan_default;

--
-- Name: user_following_group; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.user_following_group (
    follower_id text NOT NULL,
    object_id text NOT NULL,
    datetime timestamp without time zone NOT NULL
);


ALTER TABLE public.user_following_group OWNER TO ckan_default;

--
-- Name: user_following_user; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.user_following_user (
    follower_id text NOT NULL,
    object_id text NOT NULL,
    datetime timestamp without time zone NOT NULL
);


ALTER TABLE public.user_following_user OWNER TO ckan_default;

--
-- Name: vocabulary; Type: TABLE; Schema: public; Owner: ckan_default
--

CREATE TABLE public.vocabulary (
    id text NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.vocabulary OWNER TO ckan_default;

--
-- Name: system_info id; Type: DEFAULT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.system_info ALTER COLUMN id SET DEFAULT nextval('public.system_info_id_seq'::regclass);


--
-- Data for Name: activity; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.activity (id, "timestamp", user_id, object_id, activity_type, data) FROM stdin;
\.


--
-- Data for Name: activity_detail; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.activity_detail (id, activity_id, object_id, object_type, activity_type, data) FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.alembic_version (version_num) FROM stdin;
4eaa5fcf3092
\.


--
-- Data for Name: api_token; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.api_token (id, name, user_id, created_at, last_access, plugin_extras) FROM stdin;
\.


--
-- Data for Name: dashboard; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.dashboard (user_id, activity_stream_last_viewed, email_last_sent) FROM stdin;
a951e63f-324a-485c-adfe-563160f38f89	2025-03-06 09:25:07.369591	2025-03-06 09:25:07.369591
0914d4ba-8d7b-4cd9-a25e-5d102cb6a1eb	2025-03-06 12:24:33.250264	2025-03-06 12:24:33.250264
04ba30ac-9099-42ee-8d69-63fbbd69d3dd	2025-03-06 13:09:15.710839	2025-03-06 13:09:15.710839
\.


--
-- Data for Name: group; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public."group" (id, name, title, description, created, state, type, approval_status, image_url, is_organization, extras) FROM stdin;
bcb39b27-e4ce-4147-8863-e8b3eb21fcd9	my-organization	sampas	sampassampas	2025-03-06 12:28:49.013038	active	organization	approved	2025-03-06-092849.004114sampaslogo.png	t	{}
8a97f8fc-878a-4fb7-b7ba-164f8e18c1b5	my-test	deneme	this is a test organization	2025-03-06 16:28:44.372458	active	organization	approved		t	{}
ce800650-3063-4f4e-8858-362a359a7b4d	altyapi	Altyap─▒	Altyap─▒ i┼şleri ile ilgili veri seti grubu	2025-03-07 11:18:51.023796	active	group	approved		f	{}
6330253d-bd7a-4160-aa12-2480095423c1	bilgi-guvenligi	Bilgi G├╝venli─şi	Bilgi g├╝venli─şi veri seti grubu	2025-03-07 11:19:24.970398	active	group	approved		f	{}
5310c6e8-d16c-4be2-b8f5-f4ce4dd5adc5	bilgi-teknolojileri	Bilgi Teknolojileri	Bilgi teknolojileri veri seti grubu	2025-03-07 11:20:03.819215	active	group	approved		f	{}
9d79c160-0157-403d-aeaf-0b5511ba1074	cbs	CBS	CBS veri seti grubu	2025-03-07 11:20:45.717992	active	group	approved		f	{}
3863a181-a5c5-4f1d-8b8c-3543eaa1e8ab	ekonomi	Ekonom─▒	ekonom─▒ veri seti grubu	2025-03-07 11:21:40.674138	active	group	approved		f	{}
301ce132-4676-468c-9b5c-b22f43d17f50	enerji	Enerji	enerji veri seti grubu	2025-03-07 11:22:05.106456	active	group	approved		f	{}
80cfbe53-c789-4282-87e0-ccb7472140df	afet-acil	Afet ve Acil durum	 afet ve acil durum 	2025-03-07 11:18:07.298386	active	group	approved		f	{}
661f097a-6de2-48e7-a928-b12ee9df5725	cevre	├çevre	├çevre	2025-03-07 11:21:13.057018	active	group	approved		f	{}
5c8dcb56-2788-4811-85ff-d53883494ad2	iletisim	─░leti┼şim	ileti┼şim	2025-03-07 11:26:46.553469	active	group	approved		f	{}
7a134a2d-0491-498f-825b-6084998e2096	insan	─░nsan	insan	2025-03-07 11:27:10.058873	active	group	approved		f	{}
ff65f271-5539-4ac6-a929-a715e9b27d71	mekan-yonetimi	Mekan Y├Ânetimi	mekan y├Ânetimi	2025-03-07 11:27:37.693949	active	group	approved		f	{}
e42c8503-b8ba-4ab1-bb04-5d26ce436f41	saglik	Sa─şl─▒k	sa─şl─▒k	2025-03-07 11:28:30.070307	active	group	approved		f	{}
a1702786-37ad-4d3b-8209-0c87fb29e861	ulasim	Ula┼ş─▒m	ula┼ş─▒m	2025-03-07 11:28:47.978345	active	group	approved		f	{}
40e0490a-8dfc-451a-bdf9-7fb71c2d74b6	yapi	Yap─▒	yap─▒	2025-03-07 11:29:02.745222	active	group	approved		f	{}
0ac2abf9-c48b-488b-a802-2c0fc6f29e9d	yonetisim	Y├Âneti┼şim	y├Âneti┼şim	2025-03-07 11:29:25.385785	active	group	approved		f	{}
c94dc821-f3c7-498c-94e9-59bfbb90485b	guvenlik	G├╝venlik	g├╝venlik	2025-03-07 11:22:27.862585	active	group	approved		f	{}
\.


--
-- Data for Name: member; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.member (id, group_id, table_id, state, table_name, capacity) FROM stdin;
6b577b17-44c1-4407-aa88-a92367ddffc3	bcb39b27-e4ce-4147-8863-e8b3eb21fcd9	05a26e77-1db6-4b7f-ba46-b71d07022d15	active	package	organization
18c66579-5202-4ba1-8754-bd7580065160	bcb39b27-e4ce-4147-8863-e8b3eb21fcd9	05a26e77-1db6-4b7f-ba46-b71d07022d15	deleted	package	public
61129c73-2bcf-4529-9b13-ca4ab770296d	bcb39b27-e4ce-4147-8863-e8b3eb21fcd9	9876f98d-28e7-4b05-a0e5-c18b050d4519	active	package	organization
8a247b19-6c19-452b-81ba-84fe6423165a	9d79c160-0157-403d-aeaf-0b5511ba1074	9876f98d-28e7-4b05-a0e5-c18b050d4519	active	package	public
d4b04b0d-6916-4008-b3c1-1bd976deba3d	e42c8503-b8ba-4ab1-bb04-5d26ce436f41	f00647ea-cf39-4c4b-b7d2-96d707771f7d	active	package	public
e09091f5-7197-48bf-a96d-8ef2fdfdf954	bcb39b27-e4ce-4147-8863-e8b3eb21fcd9	0914d4ba-8d7b-4cd9-a25e-5d102cb6a1eb	active	user	member
04c13a5c-3206-44c1-975f-846cc46fa4f7	bcb39b27-e4ce-4147-8863-e8b3eb21fcd9	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
9db1a34e-4874-42fc-b9d2-d36f47a63bc6	bcb39b27-e4ce-4147-8863-e8b3eb21fcd9	04ba30ac-9099-42ee-8d69-63fbbd69d3dd	active	user	admin
609b04ab-c443-495b-8ab7-a38c63b8dfc5	bcb39b27-e4ce-4147-8863-e8b3eb21fcd9	6933a809-675a-49d2-850e-34056f8e6886	active	user	editor
b8f44a09-c221-46f1-8460-b7b880fac695	8a97f8fc-878a-4fb7-b7ba-164f8e18c1b5	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
71beb56f-c728-4567-a5cb-d9e925428100	8a97f8fc-878a-4fb7-b7ba-164f8e18c1b5	04ba30ac-9099-42ee-8d69-63fbbd69d3dd	active	user	admin
5357a761-691a-4ae7-91ae-ed5d46455cc4	8a97f8fc-878a-4fb7-b7ba-164f8e18c1b5	0914d4ba-8d7b-4cd9-a25e-5d102cb6a1eb	active	user	member
96260aa8-4ed2-4b0a-8083-f86d97b6e882	8a97f8fc-878a-4fb7-b7ba-164f8e18c1b5	89d898b1-6ccb-49d6-a765-7b73ee82d763	active	package	organization
ae0b9a55-868b-4a60-9e73-24ab0cf99925	8a97f8fc-878a-4fb7-b7ba-164f8e18c1b5	f00647ea-cf39-4c4b-b7d2-96d707771f7d	active	package	organization
3207067d-b82c-4470-8622-e23b6f9ff569	8a97f8fc-878a-4fb7-b7ba-164f8e18c1b5	5035c79e-bf6d-41e7-81fd-ae8304e5cc9c	active	package	organization
ddff0c5b-40f0-4e68-8638-07bf79da0a82	80cfbe53-c789-4282-87e0-ccb7472140df	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
ef16dd78-cd27-452a-8e26-36d9ea440776	ce800650-3063-4f4e-8858-362a359a7b4d	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
e046ae24-6281-4629-9d9f-f2091dfbbd35	6330253d-bd7a-4160-aa12-2480095423c1	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
865d6b58-d24b-4524-9b00-20c4be8f424b	5310c6e8-d16c-4be2-b8f5-f4ce4dd5adc5	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
9ece15d5-2945-4952-ad05-3c3551e3fa3f	9d79c160-0157-403d-aeaf-0b5511ba1074	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
fcc48650-f5d9-4ad8-a3bc-9bef27d85903	661f097a-6de2-48e7-a928-b12ee9df5725	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
f36e6bdd-0523-408c-b38c-f5b12c4cda45	3863a181-a5c5-4f1d-8b8c-3543eaa1e8ab	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
8c1bcca5-41e0-438b-8364-ccbccd896947	301ce132-4676-468c-9b5c-b22f43d17f50	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
c2ffd124-2971-4c75-afec-1a870663d494	c94dc821-f3c7-498c-94e9-59bfbb90485b	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
820fa338-148b-42f1-a3ae-f8a41c754cc2	5c8dcb56-2788-4811-85ff-d53883494ad2	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
3a037179-5cf9-4f22-a255-373a088966ff	7a134a2d-0491-498f-825b-6084998e2096	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
da22f2c1-2a13-4be6-8186-68aac880d1b8	ff65f271-5539-4ac6-a929-a715e9b27d71	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
284c41cf-dfcf-4c9d-a83e-cd52c2bc90cf	e42c8503-b8ba-4ab1-bb04-5d26ce436f41	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
bf2151b9-124d-4cda-91f2-dbc81adbc507	a1702786-37ad-4d3b-8209-0c87fb29e861	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
9ec9bdd7-125c-4df7-9ba3-ce082b7ee8bd	40e0490a-8dfc-451a-bdf9-7fb71c2d74b6	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
398bd274-b802-4500-95e3-27576285c31a	0ac2abf9-c48b-488b-a802-2c0fc6f29e9d	a951e63f-324a-485c-adfe-563160f38f89	active	user	admin
\.


--
-- Data for Name: package; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.package (id, name, title, version, url, notes, author, author_email, maintainer, maintainer_email, state, license_id, type, owner_org, private, metadata_modified, creator_user_id, metadata_created, plugin_data, extras) FROM stdin;
05a26e77-1db6-4b7f-ba46-b71d07022d15	test-data	testdataset			this is test					active	other-at	dataset	bcb39b27-e4ce-4147-8863-e8b3eb21fcd9	t	2025-03-06 09:30:12.309523	a951e63f-324a-485c-adfe-563160f38f89	2025-03-06 09:29:33.316833	\N	{}
89d898b1-6ccb-49d6-a765-7b73ee82d763	asdf	asdf			asdf					active	other-at	dataset	8a97f8fc-878a-4fb7-b7ba-164f8e18c1b5	t	2025-03-06 14:45:34.896149	a951e63f-324a-485c-adfe-563160f38f89	2025-03-06 14:45:24.402901	\N	{}
5035c79e-bf6d-41e7-81fd-ae8304e5cc9c	denemeset	denemeset			deneme123					active	other-open	dataset	8a97f8fc-878a-4fb7-b7ba-164f8e18c1b5	t	2025-03-07 07:14:26.630798	04ba30ac-9099-42ee-8d69-63fbbd69d3dd	2025-03-07 07:13:54.781801	\N	{}
9876f98d-28e7-4b05-a0e5-c18b050d4519	base-of-lava-flow	base of lava flow		https://admin.opendatani.gov.uk/dataset/base-of-lava-flow	geo dataset					active	Creative Commons - Al─▒nt─▒ (CC BY)	dataset	bcb39b27-e4ce-4147-8863-e8b3eb21fcd9	f	2025-03-07 08:47:19.359205	a951e63f-324a-485c-adfe-563160f38f89	2025-03-06 11:06:13.722428	\N	{}
f00647ea-cf39-4c4b-b7d2-96d707771f7d	qw	qwe			qwe					active	Creative Commons - Al─▒nt─▒ (CC BY)	dataset	8a97f8fc-878a-4fb7-b7ba-164f8e18c1b5	t	2025-03-07 09:26:42.152471	a951e63f-324a-485c-adfe-563160f38f89	2025-03-06 14:57:25.442608	\N	{}
\.


--
-- Data for Name: package_member; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.package_member (package_id, user_id, capacity, modified) FROM stdin;
\.


--
-- Data for Name: package_relationship; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.package_relationship (id, subject_package_id, object_package_id, type, comment, state) FROM stdin;
\.


--
-- Data for Name: package_tag; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.package_tag (id, state, package_id, tag_id) FROM stdin;
0f1a0566-43f8-46af-82c2-0a10d86a6520	active	05a26e77-1db6-4b7f-ba46-b71d07022d15	859fdc39-086e-418a-b5e3-ea050571bbd3
06e13784-1f10-44f1-8e06-10e2fe038f2f	active	9876f98d-28e7-4b05-a0e5-c18b050d4519	49ee40d6-4028-4960-9623-72d5ddba5a44
3c673003-3106-4171-8da5-950aa43d116c	active	9876f98d-28e7-4b05-a0e5-c18b050d4519	53d5104e-3bf9-4c30-bbc8-fddc8d166de6
588b1b67-c7a7-4cc9-a5d6-dec48e69ef9e	active	9876f98d-28e7-4b05-a0e5-c18b050d4519	eb51d7ca-96c7-4e5a-b593-7cf5b61bada6
f02d87aa-007d-4262-94e1-7db189bf9dd9	active	9876f98d-28e7-4b05-a0e5-c18b050d4519	7322d5da-c99e-4274-add0-76ef762dae57
e20e20a4-71b3-4f8e-a5ed-2e74132f94ad	active	89d898b1-6ccb-49d6-a765-7b73ee82d763	4d55f5a9-e09f-487f-80f5-daf75acfd59b
d857dd6c-a164-4d50-b427-5bd36b9750e1	active	f00647ea-cf39-4c4b-b7d2-96d707771f7d	11a9dceb-a593-45b1-8a9c-257f12359184
f9933e47-9ea3-46c8-bb23-018072612142	active	5035c79e-bf6d-41e7-81fd-ae8304e5cc9c	7a3df297-a4c8-4fcf-aa4b-51e1bf85b47e
e7b224e7-0491-4ccb-8b83-0032a7da0696	active	9876f98d-28e7-4b05-a0e5-c18b050d4519	6bb05ab2-0082-4672-a545-5f8f7ce6c235
\.


--
-- Data for Name: resource; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.resource (id, url, format, description, "position", hash, state, extras, name, resource_type, mimetype, mimetype_inner, size, last_modified, cache_url, cache_last_updated, created, url_type, package_id, metadata_modified) FROM stdin;
33484dea-ab12-43d7-b200-c899bc0828e3	breast-cancer.csv	CSV	breast cancer	0		active	\N	breast-cancer.csv	\N	application/vnd.ms-excel	\N	338738	2025-03-06 09:30:12.288522	\N	\N	2025-03-06 09:30:12.304523	upload	05a26e77-1db6-4b7f-ba46-b71d07022d15	2025-03-06 09:30:12.298522
529bf25a-c622-42ca-ac25-7d373129e6dc	https://admin.opendatani.gov.uk/dataset/base-of-lava-flow	GeoJSON	lava flow datas	0		active	\N	open-data-flow	\N	\N	\N	\N	\N	\N	\N	2025-03-06 11:06:43.341474		9876f98d-28e7-4b05-a0e5-c18b050d4519	2025-03-06 11:06:43.333473
8fd412b4-a079-4ed7-b612-2f457d44a3a7		CSV	asdf	0		active	\N	asdf	\N	\N	\N	\N	\N	\N	\N	2025-03-06 14:45:34.892148		89d898b1-6ccb-49d6-a765-7b73ee82d763	2025-03-06 14:45:34.888148
81ca91ca-7c98-4c06-ae38-37c66fb9d260	on-street-parking-to-q4-2024.csv	CSV	asdqwesdq	0		active	\N	qweqwe	\N	application/vnd.ms-excel	\N	253684	2025-03-06 14:57:37.310605	\N	\N	2025-03-06 14:57:37.335605	upload	f00647ea-cf39-4c4b-b7d2-96d707771f7d	2025-03-06 14:57:37.325607
c503a13c-f510-4beb-b720-b8fe6aa9bfd6	on-street-parking-to-q4-2024.csv	XLS	sreet park─▒ng	0		active	\N	on-street-parking-to-q4-2024.csv	\N	application/vnd.ms-excel	\N	253684	2025-03-07 07:14:25.945692	\N	\N	2025-03-07 07:14:25.980694	upload	5035c79e-bf6d-41e7-81fd-ae8304e5cc9c	2025-03-07 07:14:25.963694
\.


--
-- Data for Name: resource_view; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.resource_view (id, resource_id, title, description, view_type, "order", config) FROM stdin;
cd4671ee-2b73-4ffb-b29c-8412b0448dfe	529bf25a-c622-42ca-ac25-7d373129e6dc	edit	test	image_view	0	{"image_url": "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.nps.gov%2Farticles%2F000%2Flava-flow-surface-features.htm&psig=AOvVaw2N1l-NuKApnj-lUl3BshGL&ust=1741345718188000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCMi_m7yo9YsDFQAAAAAdAAAAABAE"}
\.


--
-- Data for Name: system_info; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.system_info (id, key, value, state) FROM stdin;
\.


--
-- Data for Name: tag; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.tag (id, name, vocabulary_id) FROM stdin;
859fdc39-086e-418a-b5e3-ea050571bbd3	test	\N
49ee40d6-4028-4960-9623-72d5ddba5a44	lava	\N
53d5104e-3bf9-4c30-bbc8-fddc8d166de6	base	\N
eb51d7ca-96c7-4e5a-b593-7cf5b61bada6	flow	\N
7322d5da-c99e-4274-add0-76ef762dae57	geoJson	\N
4d55f5a9-e09f-487f-80f5-daf75acfd59b	asdf	\N
11a9dceb-a593-45b1-8a9c-257f12359184	qwe	\N
7a3df297-a4c8-4fcf-aa4b-51e1bf85b47e	deneme	\N
6bb05ab2-0082-4672-a545-5f8f7ce6c235	CBS	\N
\.


--
-- Data for Name: task_status; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.task_status (id, entity_id, entity_type, task_type, key, value, state, error, last_updated) FROM stdin;
\.


--
-- Data for Name: term_translation; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.term_translation (term, term_translation, lang_code) FROM stdin;
\.


--
-- Data for Name: tracking_raw; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.tracking_raw (user_key, url, tracking_type, access_timestamp) FROM stdin;
\.


--
-- Data for Name: tracking_summary; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.tracking_summary (url, package_id, tracking_type, count, running_total, recent_views, tracking_date) FROM stdin;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public."user" (id, name, apikey, created, about, password, fullname, email, reset_key, sysadmin, activity_streams_email_notifications, state, plugin_extras, image_url, last_active) FROM stdin;
0914d4ba-8d7b-4cd9-a25e-5d102cb6a1eb	random	\N	2025-03-06 15:24:33.247263	\N	$pbkdf2-sha512$25000$0Po/B.AcI6QUImRMKUWoNQ$P2247aym2O4LN4x2Y2NfRp3yc7oCUj91rcpSHYDbCBZCJgWL/MXUn9WCvpLJMDRsFY98r0qSAqOtwDirRSZFlA	random uye1	random@sampas.com.tr	\N	f	f	active	\N		2025-03-07 06:39:54.720431
04ba30ac-9099-42ee-8d69-63fbbd69d3dd	belediyeyoneticisi	\N	2025-03-06 16:09:15.705897	\N	$pbkdf2-sha512$25000$lBJiTAnBuBfi3LtXqhVCyA$FGuyITubp61KeZ5.0/l/t5lCywY2cwgRAizBba9tMZ5uvENabc1CqNFHx5YqxxRCaZd2NfmmJu2nF65HNFOp1w	belediye yonetici	yonetici@belediye.com.tr	\N	f	f	active	\N		2025-03-07 07:48:24.666265
6933a809-675a-49d2-850e-34056f8e6886	default	1deaee80-c9d1-4611-98d0-3203e26425d9	2025-03-06 12:25:07.170593	\N	$pbkdf2-sha512$25000$W0tpDYGQcu699/7/3/u/Vw$ddjxPUQP4xch3mdjZFEnpoynPmK8.mO39EraX5b3mGdFzMQ.umC06O/SQ6xN2CZuTCHpc3QsKEA/8hyIf50QQA	\N	\N	\N	f	f	active	\N	\N	\N
a951e63f-324a-485c-adfe-563160f38f89	admin	\N	2025-03-06 12:25:07.361592	\N	$pbkdf2-sha512$25000$dO6ds7aWUso559yb8z5nrA$obW5oS9EPdAdzUI0DPp6Lo2ghPWul3A2pof2GQrtZOZNpJcYivojyyUgM8ov.0lrtp/CPu4PL9XdhHf.SWqFdg	\N	admin@admin.com	\N	t	f	active	\N	\N	2025-03-07 10:06:23.842018
\.


--
-- Data for Name: user_following_dataset; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.user_following_dataset (follower_id, object_id, datetime) FROM stdin;
a951e63f-324a-485c-adfe-563160f38f89	05a26e77-1db6-4b7f-ba46-b71d07022d15	2025-03-06 09:30:54.063068
\.


--
-- Data for Name: user_following_group; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.user_following_group (follower_id, object_id, datetime) FROM stdin;
a951e63f-324a-485c-adfe-563160f38f89	bcb39b27-e4ce-4147-8863-e8b3eb21fcd9	2025-03-06 09:31:01.483637
\.


--
-- Data for Name: user_following_user; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.user_following_user (follower_id, object_id, datetime) FROM stdin;
\.


--
-- Data for Name: vocabulary; Type: TABLE DATA; Schema: public; Owner: ckan_default
--

COPY public.vocabulary (id, name) FROM stdin;
\.


--
-- Name: system_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: ckan_default
--

SELECT pg_catalog.setval('public.system_info_id_seq', 1, false);


--
-- Name: activity_detail activity_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.activity_detail
    ADD CONSTRAINT activity_detail_pkey PRIMARY KEY (id);


--
-- Name: activity activity_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.activity
    ADD CONSTRAINT activity_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: api_token api_token_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.api_token
    ADD CONSTRAINT api_token_pkey PRIMARY KEY (id);


--
-- Name: dashboard dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT dashboard_pkey PRIMARY KEY (user_id);


--
-- Name: group group_name_key; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_name_key UNIQUE (name);


--
-- Name: group group_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_pkey PRIMARY KEY (id);


--
-- Name: member member_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_pkey PRIMARY KEY (id);


--
-- Name: package_member package_member_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.package_member
    ADD CONSTRAINT package_member_pkey PRIMARY KEY (package_id, user_id);


--
-- Name: package package_name_key; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.package
    ADD CONSTRAINT package_name_key UNIQUE (name);


--
-- Name: package package_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.package
    ADD CONSTRAINT package_pkey PRIMARY KEY (id);


--
-- Name: package_relationship package_relationship_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.package_relationship
    ADD CONSTRAINT package_relationship_pkey PRIMARY KEY (id);


--
-- Name: package_tag package_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.package_tag
    ADD CONSTRAINT package_tag_pkey PRIMARY KEY (id);


--
-- Name: resource resource_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_pkey PRIMARY KEY (id);


--
-- Name: resource_view resource_view_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.resource_view
    ADD CONSTRAINT resource_view_pkey PRIMARY KEY (id);


--
-- Name: system_info system_info_key_key; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.system_info
    ADD CONSTRAINT system_info_key_key UNIQUE (key);


--
-- Name: system_info system_info_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.system_info
    ADD CONSTRAINT system_info_pkey PRIMARY KEY (id);


--
-- Name: tag tag_name_vocabulary_id_key; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_name_vocabulary_id_key UNIQUE (name, vocabulary_id);


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (id);


--
-- Name: task_status task_status_entity_id_task_type_key_key; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.task_status
    ADD CONSTRAINT task_status_entity_id_task_type_key_key UNIQUE (entity_id, task_type, key);


--
-- Name: task_status task_status_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.task_status
    ADD CONSTRAINT task_status_pkey PRIMARY KEY (id);


--
-- Name: user_following_dataset user_following_dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.user_following_dataset
    ADD CONSTRAINT user_following_dataset_pkey PRIMARY KEY (follower_id, object_id);


--
-- Name: user_following_group user_following_group_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.user_following_group
    ADD CONSTRAINT user_following_group_pkey PRIMARY KEY (follower_id, object_id);


--
-- Name: user_following_user user_following_user_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.user_following_user
    ADD CONSTRAINT user_following_user_pkey PRIMARY KEY (follower_id, object_id);


--
-- Name: user user_name_key; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_name_key UNIQUE (name);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: vocabulary vocabulary_name_key; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.vocabulary
    ADD CONSTRAINT vocabulary_name_key UNIQUE (name);


--
-- Name: vocabulary vocabulary_pkey; Type: CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.vocabulary
    ADD CONSTRAINT vocabulary_pkey PRIMARY KEY (id);


--
-- Name: idx_activity_detail_activity_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_activity_detail_activity_id ON public.activity_detail USING btree (activity_id);


--
-- Name: idx_activity_object_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_activity_object_id ON public.activity USING btree (object_id, "timestamp");


--
-- Name: idx_activity_user_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_activity_user_id ON public.activity USING btree (user_id, "timestamp");


--
-- Name: idx_extra_grp_id_pkg_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_extra_grp_id_pkg_id ON public.member USING btree (group_id, table_id);


--
-- Name: idx_group_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_group_id ON public."group" USING btree (id);


--
-- Name: idx_group_name; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_group_name ON public."group" USING btree (name);


--
-- Name: idx_group_pkg_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_group_pkg_id ON public.member USING btree (table_id);


--
-- Name: idx_only_one_active_email; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE UNIQUE INDEX idx_only_one_active_email ON public."user" USING btree (email, state) WHERE (state = 'active'::text);


--
-- Name: idx_package_creator_user_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_package_creator_user_id ON public.package USING btree (creator_user_id);


--
-- Name: idx_package_group_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_package_group_id ON public.member USING btree (id);


--
-- Name: idx_package_resource_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_package_resource_id ON public.resource USING btree (id);


--
-- Name: idx_package_resource_package_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_package_resource_package_id ON public.resource USING btree (package_id);


--
-- Name: idx_package_resource_url; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_package_resource_url ON public.resource USING btree (url);


--
-- Name: idx_package_tag_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_package_tag_id ON public.package_tag USING btree (id);


--
-- Name: idx_package_tag_pkg_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_package_tag_pkg_id ON public.package_tag USING btree (package_id);


--
-- Name: idx_package_tag_pkg_id_tag_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_package_tag_pkg_id_tag_id ON public.package_tag USING btree (tag_id, package_id);


--
-- Name: idx_pkg_lname; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_pkg_lname ON public.package USING btree (lower((name)::text));


--
-- Name: idx_pkg_sid; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_pkg_sid ON public.package USING btree (id, state);


--
-- Name: idx_pkg_slname; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_pkg_slname ON public.package USING btree (lower((name)::text), state);


--
-- Name: idx_pkg_sname; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_pkg_sname ON public.package USING btree (name, state);


--
-- Name: idx_pkg_stitle; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_pkg_stitle ON public.package USING btree (title, state);


--
-- Name: idx_pkg_suname; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_pkg_suname ON public.package USING btree (upper((name)::text), state);


--
-- Name: idx_pkg_uname; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_pkg_uname ON public.package USING btree (upper((name)::text));


--
-- Name: idx_tag_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_tag_id ON public.tag USING btree (id);


--
-- Name: idx_tag_name; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_tag_name ON public.tag USING btree (name);


--
-- Name: idx_user_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_user_id ON public."user" USING btree (id);


--
-- Name: idx_user_name; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_user_name ON public."user" USING btree (name);


--
-- Name: idx_user_name_index; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_user_name_index ON public."user" USING btree ((
CASE
    WHEN ((fullname IS NULL) OR (fullname = ''::text)) THEN name
    ELSE fullname
END));


--
-- Name: idx_view_resource_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX idx_view_resource_id ON public.resource_view USING btree (resource_id);


--
-- Name: term_lang; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX term_lang ON public.term_translation USING btree (term, lang_code);


--
-- Name: tracking_raw_access_timestamp; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX tracking_raw_access_timestamp ON public.tracking_raw USING btree (access_timestamp);


--
-- Name: tracking_raw_url; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX tracking_raw_url ON public.tracking_raw USING btree (url);


--
-- Name: tracking_raw_user_key; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX tracking_raw_user_key ON public.tracking_raw USING btree (user_key);


--
-- Name: tracking_summary_date; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX tracking_summary_date ON public.tracking_summary USING btree (tracking_date);


--
-- Name: tracking_summary_package_id; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX tracking_summary_package_id ON public.tracking_summary USING btree (package_id);


--
-- Name: tracking_summary_url; Type: INDEX; Schema: public; Owner: ckan_default
--

CREATE INDEX tracking_summary_url ON public.tracking_summary USING btree (url);


--
-- Name: activity_detail activity_detail_activity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.activity_detail
    ADD CONSTRAINT activity_detail_activity_id_fkey FOREIGN KEY (activity_id) REFERENCES public.activity(id);


--
-- Name: api_token api_token_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.api_token
    ADD CONSTRAINT api_token_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: dashboard dashboard_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.dashboard
    ADD CONSTRAINT dashboard_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: member member_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_group_id_fkey FOREIGN KEY (group_id) REFERENCES public."group"(id);


--
-- Name: package_member package_member_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.package_member
    ADD CONSTRAINT package_member_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.package(id);


--
-- Name: package_member package_member_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.package_member
    ADD CONSTRAINT package_member_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: package_relationship package_relationship_object_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.package_relationship
    ADD CONSTRAINT package_relationship_object_package_id_fkey FOREIGN KEY (object_package_id) REFERENCES public.package(id);


--
-- Name: package_relationship package_relationship_subject_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.package_relationship
    ADD CONSTRAINT package_relationship_subject_package_id_fkey FOREIGN KEY (subject_package_id) REFERENCES public.package(id);


--
-- Name: package_tag package_tag_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.package_tag
    ADD CONSTRAINT package_tag_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.package(id);


--
-- Name: package_tag package_tag_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.package_tag
    ADD CONSTRAINT package_tag_tag_id_fkey FOREIGN KEY (tag_id) REFERENCES public.tag(id);


--
-- Name: resource resource_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.resource
    ADD CONSTRAINT resource_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.package(id);


--
-- Name: resource_view resource_view_resource_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.resource_view
    ADD CONSTRAINT resource_view_resource_id_fkey FOREIGN KEY (resource_id) REFERENCES public.resource(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tag tag_vocabulary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.tag
    ADD CONSTRAINT tag_vocabulary_id_fkey FOREIGN KEY (vocabulary_id) REFERENCES public.vocabulary(id);


--
-- Name: user_following_dataset user_following_dataset_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.user_following_dataset
    ADD CONSTRAINT user_following_dataset_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_following_dataset user_following_dataset_object_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.user_following_dataset
    ADD CONSTRAINT user_following_dataset_object_id_fkey FOREIGN KEY (object_id) REFERENCES public.package(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_following_group user_following_group_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.user_following_group
    ADD CONSTRAINT user_following_group_group_id_fkey FOREIGN KEY (object_id) REFERENCES public."group"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_following_group user_following_group_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.user_following_group
    ADD CONSTRAINT user_following_group_user_id_fkey FOREIGN KEY (follower_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_following_user user_following_user_follower_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.user_following_user
    ADD CONSTRAINT user_following_user_follower_id_fkey FOREIGN KEY (follower_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_following_user user_following_user_object_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: ckan_default
--

ALTER TABLE ONLY public.user_following_user
    ADD CONSTRAINT user_following_user_object_id_fkey FOREIGN KEY (object_id) REFERENCES public."user"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

