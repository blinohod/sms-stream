--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: stream; Type: COMMENT; Schema: -; Owner: misha
--

COMMENT ON DATABASE stream IS 'SMS Stream DB';


--
-- Name: stream; Type: SCHEMA; Schema: -; Owner: misha
--

CREATE SCHEMA stream;


ALTER SCHEMA stream OWNER TO misha;

--
-- Name: SCHEMA stream; Type: COMMENT; Schema: -; Owner: misha
--

COMMENT ON SCHEMA stream IS 'SMS Stream';


SET search_path = stream, pg_catalog;

--
-- Name: t_msg_status; Type: TYPE; Schema: stream; Owner: misha
--

CREATE TYPE t_msg_status AS ENUM (
    'NEW',
    'ROUTED',
    'PROCESSING',
    'PROCESSED',
    'SENT',
    'DELIVERED',
    'UNDELIVERABLE',
    'EXPIRED',
    'REJECTED',
    'FAILED',
    'UNKNOWN'
);


ALTER TYPE stream.t_msg_status OWNER TO misha;

--
-- Name: TYPE t_msg_status; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TYPE t_msg_status IS 'Message processing status.';


SET search_path = public, pg_catalog;

--
-- Name: uuid_generate_v1(); Type: FUNCTION; Schema: public; Owner: misha
--

CREATE FUNCTION uuid_generate_v1() RETURNS uuid
    LANGUAGE c STRICT
    AS '/usr/lib64/pgsql/uuid-ossp', 'uuid_generate_v1';


ALTER FUNCTION public.uuid_generate_v1() OWNER TO misha;

--
-- Name: uuid_generate_v1mc(); Type: FUNCTION; Schema: public; Owner: misha
--

CREATE FUNCTION uuid_generate_v1mc() RETURNS uuid
    LANGUAGE c STRICT
    AS '/usr/lib64/pgsql/uuid-ossp', 'uuid_generate_v1mc';


ALTER FUNCTION public.uuid_generate_v1mc() OWNER TO misha;

--
-- Name: uuid_generate_v3(uuid, text); Type: FUNCTION; Schema: public; Owner: misha
--

CREATE FUNCTION uuid_generate_v3(namespace uuid, name text) RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '/usr/lib64/pgsql/uuid-ossp', 'uuid_generate_v3';


ALTER FUNCTION public.uuid_generate_v3(namespace uuid, name text) OWNER TO misha;

--
-- Name: uuid_generate_v4(); Type: FUNCTION; Schema: public; Owner: misha
--

CREATE FUNCTION uuid_generate_v4() RETURNS uuid
    LANGUAGE c STRICT
    AS '/usr/lib64/pgsql/uuid-ossp', 'uuid_generate_v4';


ALTER FUNCTION public.uuid_generate_v4() OWNER TO misha;

--
-- Name: uuid_generate_v5(uuid, text); Type: FUNCTION; Schema: public; Owner: misha
--

CREATE FUNCTION uuid_generate_v5(namespace uuid, name text) RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '/usr/lib64/pgsql/uuid-ossp', 'uuid_generate_v5';


ALTER FUNCTION public.uuid_generate_v5(namespace uuid, name text) OWNER TO misha;

--
-- Name: uuid_nil(); Type: FUNCTION; Schema: public; Owner: misha
--

CREATE FUNCTION uuid_nil() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '/usr/lib64/pgsql/uuid-ossp', 'uuid_nil';


ALTER FUNCTION public.uuid_nil() OWNER TO misha;

--
-- Name: uuid_ns_dns(); Type: FUNCTION; Schema: public; Owner: misha
--

CREATE FUNCTION uuid_ns_dns() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '/usr/lib64/pgsql/uuid-ossp', 'uuid_ns_dns';


ALTER FUNCTION public.uuid_ns_dns() OWNER TO misha;

--
-- Name: uuid_ns_oid(); Type: FUNCTION; Schema: public; Owner: misha
--

CREATE FUNCTION uuid_ns_oid() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '/usr/lib64/pgsql/uuid-ossp', 'uuid_ns_oid';


ALTER FUNCTION public.uuid_ns_oid() OWNER TO misha;

--
-- Name: uuid_ns_url(); Type: FUNCTION; Schema: public; Owner: misha
--

CREATE FUNCTION uuid_ns_url() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '/usr/lib64/pgsql/uuid-ossp', 'uuid_ns_url';


ALTER FUNCTION public.uuid_ns_url() OWNER TO misha;

--
-- Name: uuid_ns_x500(); Type: FUNCTION; Schema: public; Owner: misha
--

CREATE FUNCTION uuid_ns_x500() RETURNS uuid
    LANGUAGE c IMMUTABLE STRICT
    AS '/usr/lib64/pgsql/uuid-ossp', 'uuid_ns_x500';


ALTER FUNCTION public.uuid_ns_x500() OWNER TO misha;

SET search_path = stream, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: apps; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE apps (
    id integer NOT NULL,
    name character varying(64),
    descr character varying(512)
);


ALTER TABLE stream.apps OWNER TO misha;

--
-- Name: TABLE apps; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE apps IS 'Application descriptors for inter-component routing';


--
-- Name: COLUMN apps.name; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN apps.name IS 'mnemonic application name';


--
-- Name: COLUMN apps.descr; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN apps.descr IS 'description of application';


--
-- Name: apps_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.apps_id_seq OWNER TO misha;

--
-- Name: apps_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE apps_id_seq OWNED BY apps.id;


--
-- Name: apps_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('apps_id_seq', 3, true);


--
-- Name: campaigns; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE campaigns (
    id bigint NOT NULL
);


ALTER TABLE stream.campaigns OWNER TO misha;

--
-- Name: TABLE campaigns; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE campaigns IS 'Bulk campaigns';


--
-- Name: campaigns_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE campaigns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.campaigns_id_seq OWNER TO misha;

--
-- Name: campaigns_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE campaigns_id_seq OWNED BY campaigns.id;


--
-- Name: campaigns_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('campaigns_id_seq', 1, false);


--
-- Name: countries; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE countries (
    id integer NOT NULL,
    name character varying(128)
);


ALTER TABLE stream.countries OWNER TO misha;

--
-- Name: TABLE countries; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE countries IS 'Countries';


--
-- Name: COLUMN countries.name; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN countries.name IS 'country name';


--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.countries_id_seq OWNER TO misha;

--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: countries_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('countries_id_seq', 201, true);


--
-- Name: customers; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE customers (
    id integer NOT NULL,
    manager_id integer NOT NULL,
    name character varying(512),
    login character varying(32) NOT NULL,
    password character varying(64),
    active boolean DEFAULT true NOT NULL,
    bandwidth integer DEFAULT 10 NOT NULL,
    allowed_ip character varying(512) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE stream.customers OWNER TO misha;

--
-- Name: TABLE customers; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE customers IS 'Customer accounts';


--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.customers_id_seq OWNER TO misha;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE customers_id_seq OWNED BY customers.id;


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('customers_id_seq', 3, true);


--
-- Name: directions; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE directions (
    id integer NOT NULL,
    prefix character varying(12),
    mno_id integer,
    use_hlr boolean DEFAULT true NOT NULL
);


ALTER TABLE stream.directions OWNER TO misha;

--
-- Name: TABLE directions; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE directions IS 'Prefix based directions';


--
-- Name: COLUMN directions.prefix; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN directions.prefix IS 'Prefix of target MSISDN';


--
-- Name: directions_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE directions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.directions_id_seq OWNER TO misha;

--
-- Name: directions_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE directions_id_seq OWNED BY directions.id;


--
-- Name: directions_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('directions_id_seq', 2, true);


--
-- Name: hlr_cache; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE hlr_cache (
    id bigint NOT NULL,
    msisdn character varying(16) NOT NULL,
    updated timestamp(0) with time zone DEFAULT now() NOT NULL,
    expire timestamp(0) with time zone DEFAULT (now() + '1 mon'::interval) NOT NULL,
    network_id integer
);


ALTER TABLE stream.hlr_cache OWNER TO misha;

--
-- Name: TABLE hlr_cache; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE hlr_cache IS 'HLR lookup cache';


--
-- Name: hlr_cache_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE hlr_cache_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.hlr_cache_id_seq OWNER TO misha;

--
-- Name: hlr_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE hlr_cache_id_seq OWNED BY hlr_cache.id;


--
-- Name: hlr_cache_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('hlr_cache_id_seq', 1, false);


--
-- Name: managers; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE managers (
    id integer NOT NULL,
    login character varying(64)
);


ALTER TABLE stream.managers OWNER TO misha;

--
-- Name: TABLE managers; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE managers IS 'Service managers';


--
-- Name: managers_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE managers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.managers_id_seq OWNER TO misha;

--
-- Name: managers_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE managers_id_seq OWNED BY managers.id;


--
-- Name: managers_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('managers_id_seq', 1, true);


--
-- Name: mno; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE mno (
    id integer NOT NULL,
    name character varying(256),
    country_id integer
);


ALTER TABLE stream.mno OWNER TO misha;

--
-- Name: TABLE mno; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE mno IS 'Mobile network operators';


--
-- Name: mno_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE mno_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.mno_id_seq OWNER TO misha;

--
-- Name: mno_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE mno_id_seq OWNED BY mno.id;


--
-- Name: mno_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('mno_id_seq', 1264, true);


--
-- Name: networks; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE networks (
    id integer NOT NULL,
    mcc integer NOT NULL,
    mnc integer NOT NULL,
    mno_id integer
);


ALTER TABLE stream.networks OWNER TO misha;

--
-- Name: TABLE networks; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE networks IS 'Mobile networks';


--
-- Name: networks_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE networks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.networks_id_seq OWNER TO misha;

--
-- Name: networks_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE networks_id_seq OWNED BY networks.id;


--
-- Name: networks_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('networks_id_seq', 8725, true);


--
-- Name: queue; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE queue (
    id bigint NOT NULL,
    customer_id integer NOT NULL,
    status t_msg_status DEFAULT 'NEW'::t_msg_status NOT NULL,
    src_app_id integer,
    src_addr character varying(32),
    dst_app_id integer,
    dst_addr character varying(32),
    created timestamp(0) with time zone DEFAULT now() NOT NULL,
    updated timestamp(0) with time zone DEFAULT now() NOT NULL,
    expire timestamp(0) with time zone DEFAULT (now() + '5 days'::interval) NOT NULL,
    coding smallint DEFAULT 0 NOT NULL,
    mclass smallint,
    udh character varying(280),
    body character varying(200) DEFAULT ''::character varying NOT NULL,
    dir character varying(3),
    smsc_id integer,
    mno_id integer,
    cost numeric(10,4) DEFAULT 0 NOT NULL,
    ref_id bigint,
    orig_pdu text,
    prio smallint DEFAULT 0 NOT NULL,
    reg_dlr smallint DEFAULT 0 NOT NULL
);


ALTER TABLE stream.queue OWNER TO misha;

--
-- Name: TABLE queue; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE queue IS 'Message queue';


--
-- Name: COLUMN queue.customer_id; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN queue.customer_id IS 'customer that sent message';


--
-- Name: COLUMN queue.status; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN queue.status IS 'current message status';


--
-- Name: COLUMN queue.src_app_id; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN queue.src_app_id IS 'originating application';


--
-- Name: COLUMN queue.src_addr; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN queue.src_addr IS 'source address';


--
-- Name: COLUMN queue.dst_app_id; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN queue.dst_app_id IS 'destination application';


--
-- Name: COLUMN queue.dst_addr; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN queue.dst_addr IS 'destination address';


--
-- Name: COLUMN queue.created; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN queue.created IS 'when message was created';


--
-- Name: COLUMN queue.updated; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN queue.updated IS 'when message was updated last time';


--
-- Name: queue_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.queue_id_seq OWNER TO misha;

--
-- Name: queue_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE queue_id_seq OWNED BY queue.id;


--
-- Name: queue_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('queue_id_seq', 28, true);


--
-- Name: rates; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE rates (
    id integer NOT NULL,
    mno_id integer,
    price numeric(10,4)
);


ALTER TABLE stream.rates OWNER TO misha;

--
-- Name: TABLE rates; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE rates IS 'Rates for target MNO';


--
-- Name: rates_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE rates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.rates_id_seq OWNER TO misha;

--
-- Name: rates_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE rates_id_seq OWNED BY rates.id;


--
-- Name: rates_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('rates_id_seq', 1, false);


--
-- Name: rules; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE rules (
    id integer NOT NULL,
    mno_id integer,
    smsc_id integer
);


ALTER TABLE stream.rules OWNER TO misha;

--
-- Name: TABLE rules; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE rules IS 'Processing rules - routing, etc';


--
-- Name: rules_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.rules_id_seq OWNER TO misha;

--
-- Name: rules_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE rules_id_seq OWNED BY rules.id;


--
-- Name: rules_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('rules_id_seq', 1, false);


--
-- Name: smsc; Type: TABLE; Schema: stream; Owner: misha; Tablespace: 
--

CREATE TABLE smsc (
    id integer NOT NULL,
    name character varying(32) NOT NULL,
    active boolean DEFAULT true NOT NULL,
    descr character varying(1024),
    bandwidth integer DEFAULT 100 NOT NULL
);


ALTER TABLE stream.smsc OWNER TO misha;

--
-- Name: TABLE smsc; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON TABLE smsc IS 'SMSC connections';


--
-- Name: COLUMN smsc.name; Type: COMMENT; Schema: stream; Owner: misha
--

COMMENT ON COLUMN smsc.name IS 'SMSC ID in Kannel';


--
-- Name: smsc_id_seq; Type: SEQUENCE; Schema: stream; Owner: misha
--

CREATE SEQUENCE smsc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stream.smsc_id_seq OWNER TO misha;

--
-- Name: smsc_id_seq; Type: SEQUENCE OWNED BY; Schema: stream; Owner: misha
--

ALTER SEQUENCE smsc_id_seq OWNED BY smsc.id;


--
-- Name: smsc_id_seq; Type: SEQUENCE SET; Schema: stream; Owner: misha
--

SELECT pg_catalog.setval('smsc_id_seq', 1, false);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY apps ALTER COLUMN id SET DEFAULT nextval('apps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY campaigns ALTER COLUMN id SET DEFAULT nextval('campaigns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY customers ALTER COLUMN id SET DEFAULT nextval('customers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY directions ALTER COLUMN id SET DEFAULT nextval('directions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY hlr_cache ALTER COLUMN id SET DEFAULT nextval('hlr_cache_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY managers ALTER COLUMN id SET DEFAULT nextval('managers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY mno ALTER COLUMN id SET DEFAULT nextval('mno_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY networks ALTER COLUMN id SET DEFAULT nextval('networks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY queue ALTER COLUMN id SET DEFAULT nextval('queue_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY rates ALTER COLUMN id SET DEFAULT nextval('rates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY rules ALTER COLUMN id SET DEFAULT nextval('rules_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY smsc ALTER COLUMN id SET DEFAULT nextval('smsc_id_seq'::regclass);


--
-- Data for Name: apps; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY apps (id, name, descr) FROM stdin;
1	app_smppd	SMPP server
2	app_hlr	HLR Lookup
3	app_kannel	Kannel Connector
\.


--
-- Data for Name: campaigns; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY campaigns (id) FROM stdin;
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY countries (id, name) FROM stdin;
2	Afghanistan
3	Albania
4	Algeria
5	Andorra
6	Angola
7	Anguilla
8	Antigua and Barbuda
9	Argentina
10	Aruba
11	Australia
12	Austria
13	Azerbaijan
14	Bahrain
15	Bangladesh
16	Barbados
17	Belarus
18	Belgium
19	Belize
20	Benin
21	Bhutan
22	Bolivia (Plurinational State of)
23	Bosnia and Herzegovina
24	Botswana
25	Brazil
26	British Virgin Islands
27	Brunei Darussalam
28	Bulgaria
29	Burkina Faso
30	Burundi
31	Cambodia
32	Cameroon
33	Canada
34	Cape Verde
35	Cayman Islands
36	Central African Rep.
37	Chad
38	Chile
39	China
40	Colombia
41	Comoros
42	Congo
43	Cook Islands
44	Costa Rica
45	Côte d'Ivoire
46	Croatia
47	Cuba
48	Curaçao
49	Cyprus
50	Czech Rep.
51	Dem. Rep. of the Congo
52	Denmark
53	Djibouti
54	Dominican Rep.
55	Ecuador
56	Egypt
57	El Salvador
58	Equatorial Guinea
59	Estonia
60	Ethiopia
61	Falkland Islands (Malvinas)
62	Faroe Islands
63	Fiji
64	Finland
65	France
66	French Departments and Territories in the Indian Ocean
67	French Guiana
68	French Polynesia
69	Gabon
70	Gambia
71	Georgia
72	Germany
73	Ghana
74	Gibraltar
75	Greece
76	Greenland
77	Guadeloupe
78	Guatemala
79	Guinea
80	Guinea-Bissau
81	Guyana
82	Haiti
83	Honduras
84	Hong Kong, China
85	Hungary
86	Iceland
87	India
88	Indonesia
89	International Mobile, shared code
90	Iran (Islamic Republic of)
91	Iraq
92	Ireland
93	Israel
94	Italy
95	Jamaica
96	Japan
97	Jordan
98	Kazakhstan
99	Kenya
100	Korea (Rep. of)
101	Kuwait
102	Kyrgyzstan
103	Lao P.D.R.
104	Latvia
105	Lebanon
106	Lesotho
107	Liberia
108	Liechtenstein
109	Lithuania
110	Luxembourg
111	Macao, China
112	Madagascar
113	Malawi
114	Malaysia
115	Maldives
116	Mali
117	Malta
118	Martinique
119	Mauritania
120	Mauritius
121	Mexico
122	Micronesia
123	Moldova (Republic of)
124	Mongolia
125	Montenegro
126	Morocco
127	Mozambique
128	Myanmar
129	Namibia
130	Nauru
131	Nepal
132	Netherlands
133	New Caledonia
134	New Zealand
135	Nicaragua
136	Niger
137	Nigeria
138	Niue
139	Norway
140	Oman
141	Pakistan
142	Palau
143	Panama
144	Papua New Guinea
145	Paraguay
146	Peru
147	Philippines
148	Poland
149	Portugal
150	Qatar
151	Romania
152	Russian Federation
153	Rwanda
154	Saint Pierre and Miquelon
155	Samoa
156	San Marino
157	Sao Tome and Principe
158	Saudi Arabia
159	Senegal
160	Serbia
161	Seychelles
162	Sierra Leone
163	Singapore
164	Slovakia
165	Slovenia
166	Solomon Islands
167	Somalia
168	South Africa
169	Spain
170	Sri Lanka
171	Sudan
172	Suriname
173	Swaziland
174	Sweden
175	Switzerland
176	Syrian Arab Republic
177	Tajikistan
178	Tanzania
179	Thailand
180	The Former Yugoslav Republic of Macedonia
181	Togo
182	Tonga
183	Trinidad and Tobago
184	Tunisia
185	Turkey
186	Turkmenistan
187	Turks and Caicos Islands
188	Tuvalu
189	Uganda
190	Ukraine
191	United Arab Emirates
192	United Kingdom
193	United States
194	Uruguay
195	Uzbekistan
196	Vanuatu
197	Venezuela (Bolivarian Republic of)
198	Viet Nam
199	Yemen
200	Zambia
201	Zimbabwe
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY customers (id, manager_id, name, login, password, active, bandwidth, allowed_ip) FROM stdin;
3	1	tester	test	123	t	10	
\.


--
-- Data for Name: directions; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY directions (id, prefix, mno_id, use_hlr) FROM stdin;
1	38067	1	f
2	38097	1	f
\.


--
-- Data for Name: hlr_cache; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY hlr_cache (id, msisdn, updated, expire, network_id) FROM stdin;
\.


--
-- Data for Name: managers; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY managers (id, login) FROM stdin;
1	admin
\.


--
-- Data for Name: mno; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY mno (id, name, country_id) FROM stdin;
2	Afghan Telecom	2
3	Areeba Afghanistan	2
4	AWCC	2
5	New1	2
6	Roshan	2
7	Albanian Mobile Communications (AMC)	3
8	Eagle Mobile	3
9	Mobile 4 AL	3
10	Vodafone Albania	3
11	Algérie Telecom	4
12	Orascom Telecom Algérie	4
13	Mobiland	5
14	Movicel	6
15	Unitel	6
16	Weblinks Limited	7
17	APUA PCS	8
18	AT&T Wireless (Antigua)	8
19	Cable & Wireless (Antigua)	8
20	Compañia de Radiocomunicaciones Moviles S.A.	9
21	Compañia de Telefonos del Interior Norte S.A.	9
22	Compañia de Telefonos del Interior S.A.	9
23	CTI PCS S.A.	9
24	Nextel Argentina srl	9
25	Telecom Personal S.A.	9
26	Telefónica Comunicaciones Personales S.A.	9
27	Setar GSM	10
28	3GIS Pty Ltd. (Telstra & Hutchison 3G)	11
29	AAPT Ltd.	11
30	Advanced Communications Technologies Pty. Ltd.	11
31	Airnet Commercial Australia Ltd.	11
32	Ausgrid Corporation	11
33	Department of Defence	11
34	Hutchison 3G Australia Pty. Ltd.	11
35	Hutchison Telecommunications (Australia) Pty. Ltd.	11
36	Localstar Holding Pty. Ltd.	11
37	Lycamobile Pty Ltd	11
38	NBNCo Ltd	11
39	Norfolk Telecom	11
40	One.Tel GSM 1800 Pty. Ltd.	11
41	Optus Ltd.	11
42	Optus Mobile Pty. Ltd.	11
43	Pactel International Pty Ltd	11
44	Queensland Rail Limited	11
45	Railcorp	11
46	Telstra Corporation Ltd.	11
47	The Ozitel Network Pty. Ltd.	11
48	Victorian Rail Track	11
49	Vivid Wireless Pty Ltd	11
50	Vodafone Network Pty. Ltd.	11
51	Barablu Mobile Austria Ltd	12
52	Hutchison 3G Austria GmbH	12
53	Mobilkom Austria Aktiengesellschaft	12
54	OBB - Infrastruktur Bau AG	12
55	Orange Austria Telecommunication GmbH	12
56	T-Mobile Austria GmbH	12
57	Azercell Limited Liability Joint Venture	13
58	Azerphone LLC	13
59	Bakcell Limited Liability Company	13
60	Catel JV	13
61	BATELCO	14
62	Civil Aviation Authority	14
63	Royal Court	14
64	STC Bahrain	14
65	Zain Bahrain	14
66	Aktel	15
67	GramenPhone	15
68	Mobile 2000	15
69	Cable & Wireless (Barbados) Ltd.	16
70	Sunbeach Communications	16
71	BelCel Joint Venture	17
72	Closed JSC Belarussian Telecommunication network	17
73	MDC Velcom	17
74	MTS	17
75	Republican Unitary Telecommunication Enterprise Beltelecom	17
76	YotaBel Foreign Ltd Liability Company	17
77	Base	18
78	Mobistar	18
79	Proximus	18
80	Belize Telecommunications Ltd., GSM 1900	19
81	International Telecommunications Ltd. (INTELCO)	19
82	Libercom	20
83	Spacetel Benin	20
84	Telecel	20
85	Bhutan Telecom Ltd	21
86	B-Mobile of Bhutan Telecom	21
87	ENTEL S.A.	22
88	Nuevatel S.A.	22
89	Telecel S.A.	22
90	Eronet Mobile Communications Ltd.	23
91	GSMBIH	23
92	MOBI'S (Mobilina Srpske)	23
93	Botswana Telecommunications Corporation (BTC)	24
94	Mascom Wireless (Pty) Ltd.	24
95	Orange Botswana (Pty) Ltd.	24
96	Americel	25
97	ATL Algar	25
98	BCP	25
99	BSE	25
100	Ceterp Cel	25
101	CRT Cellular	25
102	CTBC Cel	25
103	CTMR Cel	25
104	Global Telecom	25
105	Maxitel BA	25
106	Maxitel MG	25
107	Norte Brasil Tel	25
108	Sercontel Cel	25
109	Telaima Cel	25
110	Telasa Cel	25
111	Teleacre Cel	25
112	Teleamapa Cel	25
113	Teleamazon Cel	25
114	Telebahia Cel	25
115	Telebrasilia Cel	25
116	Teleceara Cel	25
117	Telegoias Cel	25
118	Telemat Cel	25
119	Telemig Cel	25
120	Telems Cel	25
121	Telepara Cel	25
122	Telepar Cel	25
123	Telepisa Cel	25
124	Telergipe Cel	25
125	Telerj Cel	25
126	Telern Cel	25
127	Teleron Cel	25
128	Telesc Cel	25
129	Telesp Cel	25
130	Telest Cel	25
131	Telet	25
132	Telma Cel	25
133	Telpa Cel	25
134	Telpe Cel	25
135	Tess	25
136	BVI Cable TV Ltd	26
137	Cable & Wireless (BVI) Ltd	26
138	Caribbean Cellular Telephone Ltd.	26
139	Digicel (BVI) Ltd	26
140	DST Com	27
141	Globul	28
142	M-Tel GSM BG	28
143	Celtel	29
144	Telecel	29
145	AFRICELL	30
146	ECONET	30
147	HITS TELECOM	30
148	LACELL	30
149	ONAMOB	30
150	U.COM	30
151	Cadcomms	31
152	Hello	31
153	Mfone	31
154	Mobitel (Cam GSM)	31
155	Smart	31
156	Starcell	31
157	S Telecom (CDMA)	31
158	Viettel	31
159	Mobile Telephone Networks Cameroon	32
160	Orange Cameroun	32
161	Aliant Mobility	33
162	Bell Mobility	33
163	CityTel Mobility	33
164	Clearnet	33
165	Globalstar	33
166	Ice Wireless	33
167	Microcell	33
168	MTS Mobility	33
169	Rogers Wireless	33
170	Sask Tel Mobility	33
171	Tbay Mobility	33
172	Telus Mobility	33
173	Cabo Verde Telecom	34
174	T+Telecomunicaçôes	34
175	Cable & Wireless (Cayman)	35
176	Celca (Socatel)	36
177	Centrafrique Telecom Plus (CTP)	36
178	Telecel Centrafrique (TC)	36
179	Celtel	37
180	Tchad Mobile	37
181	Blue Two Chile SA	38
182	Celupago S.A.	38
183	Centennial Cayman Corp. Chile S.A.	38
184	Entel	38
185	Entel Telefónica Móvil	38
186	Multikom S.A.	38
187	Smartcom	38
188	Telefónica Móvil	38
189	Telefónica Móviles Chile S.A.	38
190	Telestar Móvil S.A.	38
191	VTR Móvil S.A.	38
192	China Mobile	39
193	China Satellite Global Star Network	39
194	China Unicom	39
195	China Unicom CDMA	39
196	Avantel	40
197	Bellsouth Colombia S.A.	40
198	Colombia Móvil S.A.	40
199	Colombia Telecomunicaciones S.A. - Telecom	40
200	Comcel S.A. Occel S.A./Celcaribe	40
201	Edatel S.A.	40
202	Emcali	40
203	Emtelsa	40
204	Telefónica Móviles Colombia S.A.	40
205	HURI - SNPT	41
206	Celtel	42
207	Libertis Telecom	42
208	Telecom Cook	43
209	Azules y Platas S.A.	44
210	Claro CR Telecomuniocaciones S.A.	44
211	Instituto Costarricense de Electricidad - ICE	44
212	Virtualis	44
213	Aircomm Côte d'Ivoire	45
214	Atlantique Cellulaire	45
215	Comium Côte d'Ivoire	45
216	Loteny Telecom	45
217	Orange Côte d'Ivoire	45
218	Oricel Côte d'Ivoire	45
219	Tele2/Tele2 d.o.o.	46
220	T-Mobile Hrvatska d.o.o./T-Mobile Croatia LLC	46
221	VIPnet/VIPnet d.o.o.	46
222	ETECSA	47
223	CT GSM	48
224	SETEL GSM	48
225	TELCELL GSM	48
226	CYTA	49
227	Lemontel Ltd	49
228	Primetel PLC	49
229	Scancom (Cyprus) Ltd.	49
230	Mobilkom a.s.	50
231	Sprava Zeleznicni Dopravni Cesty	50
232	Telefónica O2 Czech Republic a.s.	50
233	T-Mobile Czech Republic a.s.	50
234	Travel Telekommunikation, sro	50
235	Vodafone Czech Republic a.s.	50
236	Vodafone Czech Republic a.s. R&D Centre	50
237	Airtel sprl	51
238	Congo-Chine Telecom s.a.r.l.	51
239	Oasis sprl	51
240	Supercell Sprl	51
241	Vodacom Congo RDC sprl	51
242	Yozma Timerus sprl	51
243	Barablu Mobile Ltd.	52
244	Hi3G	52
245	Lycamobile Denmark	52
246	MIGway A/S	52
247	Sonofon	52
248	TDC Mobil	52
249	Tele2	52
250	Telia	52
251	Telia Mobile	52
252	Evatis	53
253	CentennialDominicana	54
254	Orange Dominicana, S.A.	54
255	Tricom S.A.	54
256	Verizon Dominicana S.A.	54
257	Otecel S.A. - Bellsouth	55
258	Porta GSM	55
259	Telecsa S.A.	55
260	Etisalat	56
261	Mobinil	56
262	Vodafone	56
263	CTE Telecom Personal, S.A. de C.V.	57
264	Digicel, S.A. de C.V.	57
265	Telemóvil El Salvador, S.A.	57
266	Guinea Ecuatorial de Telecomunicaciones Sociedad Anónima	58
267	AS Bravocom Mobiil	59
268	EMT GSM	59
269	OY Top Connect	59
270	ProGroup Holding OY	59
271	RLE	59
272	Siseministeerium (Ministry of Interior)	59
273	Tele2	59
274	Televõrgu AS	59
275	ETH MTN	60
276	Touch	61
277	Edge Mobile Sp/F	62
278	Faroese Telecom - GSM	62
279	Kall GSM	62
280	P/F Kall	62
281	Digicel (Fiji) Ltd	63
282	Telecom Fiji Ltd (CDMA)	63
283	Vodafone (Fiji) Ltd	63
284	Alands Mobiltelefon AB	64
285	DNA Oy	64
286	Elisa Oy	64
287	Nokia Siemens Networks Oy	64
288	Saunalahti Group Oyj	64
289	SCNL Truphone	64
290	TDC Oy Finland	64
291	TeliaSonera Finland Oyj	64
292	Bouygues Telecom	65
293	Bouygues Telecom (Zones Blanches)	65
294	Globalstar Europe	65
295	Orange France	65
296	S.F.R.	65
297	S.F.R. (UMTS)	65
298	SFR (Zones Blanches)	65
299	Transatel	65
300	Orange La Réunion	66
301	Outremer Telecom	66
302	Société Réunionnaise du Radiotéléphone	66
303	Guyane Téléphone Mobile	67
304	Digicel Tahiti	68
305	Mara Telecom	68
306	Tikiphone	68
307	Celtel Gabon S.A.	69
308	Libertis S.A.	69
309	Telecel Gabon S.A.	69
310	USAN Gabon	69
311	Africell	70
312	Comium Services Ltd	70
313	Gamcel	70
314	Geocell Ltd.	71
315	Iberiatel Ltd.	71
316	Magti GSM Ltd.	71
317	Mobitel Ltd.	71
318	Silknet JSC	71
319	Airdata AG	72
320	Arcor AG & Co.	72
321	Dolphin Telecom (Deutschland) GmbH	72
322	E-Plus Mobilfunk GmbH & Co. KG	72
323	Group 3G UMTS GmbH (Quam)	72
324	Mobilcom Multimedia GmbH	72
325	O2 (Germany) GmbH & Co. OHG	72
326	Siemens AG, ICMNPGUSTA	72
327	T-Mobile Deutschland GmbH	72
328	Vodafone D2 GmbH	72
329	Ghana Telecom Mobile	73
330	Kasapa Telecom Ltd.	73
331	Mobitel	73
332	Netafriques Dot Com Ltd	73
333	Spacefon	73
334	CTS	74
335	Eazi Telecom Ltd	74
336	Gibtelecom GSM	74
337	AMD TELECOM	75
338	COSMOLINE	75
339	Cosmote	75
340	COSMOTE	75
341	EDISY	75
342	OTE	75
343	Vodafone - Panafon	75
344	WIND	75
345	Tele Greenland	76
346	Bouygues Telecom Caraïbe	77
347	Dauphin Telecom	77
348	Guadeloupe Téléphone Mobile	77
349	Orange Caraïbe Mobiles	77
350	Outremer Telecom	77
351	Saint Martin et Saint Barthelemy Telcell Sarl	77
352	Comunicaciones Celulares S.A.	78
353	Servicios de Comunicaciones Personales Inalámbricas, S.A.	78
354	Telefónica Centroamérica Guatemala S.A.	78
355	Cellcom Guinée SA	79
356	Orange Guinée	79
357	Sotelgui	79
358	Guinétel S.A.	80
359	Spacetel Guiné-Bissau S.A.	80
360	Cel*Star (Guyana) Inc.	81
361	Comcel	82
362	Digicel	82
363	Rectel	82
364	Celtel	83
365	Digicel Honduras	83
366	Megatel	83
367	3G Radio System/HKCSL3G	84
368	3G Radio System/Hutchison 3G	84
369	3G Radio System/SMT3G	84
370	3G Radio System/Sunday3G	84
371	CDMA/Hutchison	84
372	GSM1800/Mandarin Communications Ltd.	84
373	GSM1800New World PCS Ltd.	84
374	GSM1800/Peoples Telephone Company Ltd.	84
375	GSM7800/Hong Kong CSL Ltd.	84
376	GSM900/GSM1800/Hutchison	84
377	GSM900/HKCSL	84
378	GSM900/SmarTone	84
379	MVNO/China Motion Telecom (HK) Ltd.	84
380	MVNO/China Unicom International Ltd.	84
381	MVNO/CHKTL	84
382	MVNO/CITIC	84
383	MVNO/Trident	84
384	Pannon GSM	85
385	Vodafone	85
386	Westel Mobile	85
387	IceCell ehf	86
388	Iceland Telecom Ltd.	86
389	IMC Islande ehf	86
390	Og fjarskipti hf (Vodafone Iceland)	86
391	Aditya Birla Telecom Ltd, Bihar	87
392	Aircell Cellular Ltd, Chennai	87
393	Aircell Digilink India Ltd., Haryana	87
394	Aircell Digilink India Ltd., Rajasthan	87
395	Aircell Digilink India Ltd., UP (East)	87
396	Aircell Ltd, Andhra Pradesh	87
397	Aircell Ltd, Delhi	87
398	Aircell Ltd, Gujarat	87
399	Aircell Ltd, Karnataka	87
400	Aircell Ltd, Maharashtra	87
401	Aircell Ltd, Mumbai	87
402	Aircell Ltd, Rajasthan	87
403	Aircel Ltd., Tamil Nadu	87
404	Bharti Airtel Ltd., Andra Pradesh	87
405	Bharti Airtel Ltd, Assam	87
406	Bharti Airtel Ltd, Bihar	87
407	Bharti Airtel Ltd., Chennai	87
408	Bharti Airtel Ltd., Delhi	87
409	Bharti Airtel Ltd., Gujarat	87
410	Bharti Airtel Ltd., Haryana	87
411	Bharti Airtel Ltd., H.P.	87
412	Bharti Airtel Ltd, J&K	87
413	Bharti Airtel Ltd., Karnataka	87
414	Bharti Airtel Ltd., Kerala	87
415	Bharti Airtel Ltd., Kolkata	87
416	Bharti Airtel Ltd., Madhya Pradesh	87
417	Bharti Airtel Ltd., Maharashtra	87
418	Bharti Airtel Ltd., Mumbai	87
419	Bharti Airtel Ltd, North East	87
420	Bharti Airtel Ltd, Orissa	87
421	Bharti Airtel Ltd., Punjab	87
422	Bharti Airtel Ltd., Tamil Nadu	87
423	Bharti Airtel Ltd, UP (East)	87
424	Bharti Airtel Ltd., UP (West)	87
425	Bharti Hexacom Ltd, Rajasthan	87
426	BPL Mobile Communications Ltd., Mumbai	87
427	BSNL, Andaman & Nicobar	87
428	BSNL, Andhra Pradesh	87
429	BSNL, Assam	87
430	BSNL, Bihar	87
431	BSNL, Chennai	87
432	BSNL, Gujarat	87
433	BSNL, Haryana	87
434	BSNL, H.P.	87
435	BSNL, J&K	87
436	BSNL, Karnataka	87
437	BSNL, Kerala	87
438	BSNL, Kolkata	87
439	BSNL, Madhya Pradesh	87
440	BSNL, Maharashtra	87
441	BSNL, North East	87
442	BSNL, Orissa	87
443	BSNL, Punjab	87
444	BSNL, Rajasthan	87
445	BSNL, Tamil Nadu	87
446	BSNL, UP (East)	87
447	BSNL, UP (West)	87
448	BSNL, West Bengal	87
449	BTA Cellcom Ltd., Madhya Pradesh	87
450	Dishnet Wireless Ltd, Assam	87
451	Dishnet Wireless Ltd, Bihar	87
452	Dishnet Wireless Ltd, Haryana	87
453	Dishnet Wireless Ltd, Himachal Pradesh	87
454	Dishnet Wireless Ltd, J&K	87
455	Dishnet Wireless Ltd, Kerala	87
456	Dishnet Wireless Ltd, Kolkata	87
457	Dishnet Wireless Ltd, Madhya Pradesh	87
458	Dishnet Wireless Ltd, North East	87
459	Dishnet Wireless Ltd, Punjab	87
460	Dishnet Wireless Ltd, UP (East)	87
461	Dishnet Wireless Ltd, UP (West)	87
462	Dishnet Wireless Ltd, West Bengal	87
463	Essar Spacetel Ltd, Assam	87
464	Essar Spacetel Ltd, Bihar	87
465	Essar Spacetel Ltd, Himachal Pradesh	87
466	Essar Spacetel Ltd, J&K	87
467	Essar Spacetel Ltd, Maharashtra	87
468	Essar Spacetel Ltd, North East	87
469	Essar Spacetel Ltd, Orissa	87
470	Fascel Ltd., Gujarat	87
471	Hutchinson Essar Ltd, Mumbai	87
472	Hutchinson Essar South Ltd., Andhra Pradesh	87
473	Hutchinson Essar South Ltd., Chennai	87
474	Hutchinson Essar South Ltd., Karnataka	87
475	Hutchison Essar Cellular Ltd., Kerala	87
476	Hutchison Essar Cellular Ltd., Maharashtra	87
477	Hutchison Essar Cellular Ltd., Tamil Nadu	87
478	Hutchison Essar Mobile Services Ltd, Delhi	87
479	Hutchison Essar South Ltd, Orissa	87
480	Hutchison Essar South Ltd, Punjab	87
481	Hutchison Essar South Ltd, UP (West)	87
482	Hutchison Telecom East Ltd, Kolkata	87
483	Idea Cellular Ltd., Andhra Pradesh	87
484	Idea Cellular Ltd., Delhi	87
485	Idea Cellular Ltd., Gujarat	87
486	Idea Cellular Ltd, Maharashtra	87
487	Idea Cellular Ltd., Maharashtra	87
488	Idea Mobile Communications Ltd., Haryana	87
489	Idea Mobile Communications Ltd., Kerala	87
490	Idea Mobile Communications Ltd., UP (West)	87
491	Idea Telecommunications Ltd, H.P.	87
492	Idea Telecommunications Ltd, Rajasthan	87
493	Idea Telecommunications Ltd, UP (East)	87
494	MTNL, Delhi	87
495	MTNL, Mumbai	87
496	Reliable Internet Services Ltd., Kolkata	87
497	Reliance Infocomm Ltd, Andhra Pradesh	87
498	Reliance Infocomm Ltd, Bihar	87
499	Reliance Infocomm Ltd, Chennai	87
500	Reliance Infocomm Ltd, Delhi	87
501	Reliance Infocomm Ltd, Gujarat	87
502	Reliance Infocomm Ltd, Haryana	87
503	Reliance Infocomm Ltd, Himachal Pradesh	87
504	Reliance Infocomm Ltd, J&K	87
505	Reliance Infocomm Ltd, Karnataka	87
506	Reliance Infocomm Ltd, Kerala	87
507	Reliance Infocomm Ltd, Kolkata	87
508	Reliance Infocomm Ltd, Madhya Pradesh	87
509	Reliance Infocomm Ltd, Maharashtra	87
510	Reliance Infocomm Ltd, Mumbai	87
511	Reliance Infocomm Ltd, Orissa	87
512	Reliance Infocomm Ltd, Punjab	87
513	Reliance Infocomm Ltd, Tamilnadu	87
514	Reliance Infocomm Ltd, UP (East)	87
515	Reliance Infocomm Ltd, UP (West)	87
516	Reliance Infocomm Ltd, West bengal	87
517	Reliance Telecom Ltd., Assam	87
518	Reliance Telecom Ltd., Bihar	87
519	Reliance Telecom Ltd., H.P.	87
520	Reliance Telecom Ltd., Madhya Pradesh	87
521	Reliance Telecom Ltd., North East	87
522	Reliance TelecomLtd., Orissa	87
523	Reliance Telecom Ltd., W.B. & A.N.	87
524	Shyam Telelink Ltd, Rajasthan	87
525	Spice Communications PVT Ltd., Karnataka	87
526	Spice Communications PVT Ltd., Punjab	87
527	Tata Teleservices Ltd, Andhra Pradesh	87
528	Tata Teleservices Ltd, Bihar	87
529	Tata Teleservices Ltd, Chennai	87
530	Tata Teleservices Ltd, Delhi	87
531	Tata Teleservices Ltd, Gujarat	87
532	Tata Teleservices Ltd, Haryana	87
533	Tata Teleservices Ltd, Himachal Pradesh	87
534	Tata Teleservices Ltd, Karnataka	87
535	Tata Teleservices Ltd, Kerala	87
536	Tata Teleservices Ltd, Kolkata	87
537	Tata Teleservices Ltd, Madhya Pradesh	87
538	Tata Teleservices Ltd, Maharashtra	87
539	Tata Teleservices Ltd, Mumbai	87
540	Tata Teleservices Ltd, Orissa	87
541	Tata Teleservices Ltd, Punjab	87
542	Tata Teleservices Ltd, Rajasthan	87
543	Tata Teleservices Ltd, Tamilnadu	87
544	Tata Teleservices Ltd, UP (East)	87
545	Tata Teleservices Ltd, UP (West)	87
546	Tata Teleservices Ltd, West Bengal	87
547	Vodaphone/Hutchison, Madhya Pradesh	87
548	Excelcomindo	88
549	Indosat - M3	88
550	Komselindo	88
551	Natrindo (Lippo Telecom)	88
552	PSN	88
553	Satelindo	88
554	Telkomsel	88
555	Asia Cellular Satellite (AceS)	89
556	BebbiCell AG	89
557	Beeline	89
558	Cingular Wireless	89
559	France Telecom Orange	89
560	ICO Global Communications	89
561	Inmarsat Ltd.	89
562	Intermatica	89
563	Iridium Communications Inc	89
564	Jasper Wireless, Inc	89
565	Jersey Telecom	89
566	Maritime Communications Partner AS (MCP network)	89
567	MediaLincc Ltd	89
568	Megafon	89
569	Onair	89
570	OnAir	89
571	Seanet Maritime Communications AB	89
572	Smart Communications, Inc	89
573	Telecom Italia	89
574	Telenor	89
575	Telenor Connexion AB	89
576	Thuraya RMSS Network	89
577	Thuraya Satellite Telecommunications Company	89
578	UN Office for the Coordination of Humanitarian Affairs (OCHA)	89
579	Vodafone Group	89
580	Vodafone Malta (Vodafone Group)	89
581	Voxbone SA	89
582	Telecommunication Company of Iran (TCI)	90
583	Telecommunication Company of Iran (TCI) - Isfahan Celcom	90
584	Telecommunication Kish Co. (KIFZO)	90
585	Asia Cell	91
586	Iraq Central Cooperative Association for Communication and Transportation	91
587	Iraqi Telecommunications & Post Company (ITPC)	91
588	Iraqtel	91
589	ITC Fanoos	91
590	Itisaluna	91
591	ITPC (Al-Mazaya)	91
592	ITPC (Al Nakheel)	91
593	ITPC (Al-Seraj)	91
594	ITPC (Al-Shams)	91
595	ITPC (Anwar Yagotat Alkhalee)	91
596	ITPC (Belad Babel)	91
597	ITPC (Eaamar Albasrah)	91
598	ITPC (Furatfone)	91
599	ITPC (High Link)	91
600	ITPC (Iraqcell)	91
601	ITPC (Sader Al-Iraq)	91
602	ITPC (Shaly)	91
603	Kalimat	91
604	Korek Telecom	91
605	Zain Iraq (previously Atheer)	91
606	Zain Iraq (previously Iraqna)	91
607	Clever Communications Ltd.	92
608	Digifone mm02 Ltd.	92
609	Eircom	92
610	Meteor Mobile Communications Ltd.	92
611	Vodafone Ireland Plc	92
612	365 Telecom (MVNO)	93
613	Alon Cellular Ltd	93
614	Cellcom Israel Ltd.	93
615	Free Telecom (MVNO)	93
616	Gale Phone (MVNO)	93
617	Globalsim Ltd	93
618	Golan Telecom Ltd	93
619	Home Cellular (MVNO)	93
620	Ituran Cellular Communications	93
621	Mirs Ltd	93
622	Partner Communications Co. Ltd.	93
623	Pelephone Communications Ltd.	93
624	Rami Levi (MVNO)	93
625	Wataniya	93
626	Blu	94
627	Elsacom	94
628	H3G	94
629	IPSE 2000	94
630	Omnitel Pronto Italia (OPI)	94
631	Telecom Italia Mobile (TIM)	94
632	Wind	94
633	Cable & Wireless Jamaica Ltd.	95
634	Mossel (Jamaica) Ltd.	95
635	KDDI Corporation	96
636	NTT DoCoMo Chugoku Inc.	96
637	NTT DoCoMo Hokkaido	96
638	NTT DoCoMo Hokkaido Inc.	96
639	NTT DoCoMo Hokuriku Inc.	96
640	NTT DoCoMo Hokuriku, Inc.	96
641	NTT DoCoMo Inc.	96
642	NTT DoCoMo, Inc.	96
643	NTT DoCoMo Kansai Inc.	96
644	NTT DoCoMo Kansai, Inc.	96
645	NTT DoCoMo Kyushu Inc.	96
646	NTT DoCoMo Shikoku Inc.	96
647	NTT DoCoMo Tohoku Inc.	96
648	NTT DoCoMoTohoku Inc.	96
649	NTT DoCoMo Tokai Inc.	96
650	Okinawa Cellular Telephone	96
651	TU-KA Cellular Tokai Inc.	96
652	TU-KA Cellular Tokyo Inc.	96
653	TU-KA Phone Kansai Inc.	96
654	Vodafone	96
655	Fastlink	97
656	Mobilecom	97
657	Umniah	97
658	Xpress	97
659	Kar-Tel llc	98
660	TSC Kazak Telecom	98
661	Kencell Communications Ltd.	99
662	Safaricom Ltd.	99
663	KT Freetel	100
664	SK Telecom	100
665	Mobile Telecommunications Company	101
666	Viva	101
667	Wataniya Telecom	101
668	Bitel GSM	102
669	ETL Mobile	103
670	Lao Telecommunications	103
671	Millicom	103
672	Beta Telecom	104
673	Bite Mobile	104
674	IZZI	104
675	Latvijas Mobilais Telefons SIA	104
676	Master Telecom	104
677	Rigatta	104
678	Tele2	104
679	Telekom Baltija	104
680	Cellis	105
681	Libancell	105
682	Ogero Telecom	105
683	Econet Ezin-cel	106
684	Vodacom Lesotho (pty) Ltd.	106
685	Comium Liberia	107
686	Mobilkom (Liechstein) AG	108
687	Tele2 AG	108
688	Telecom FL AG	108
689	Viag Europlatform AG	108
690	Bité GSM	109
691	Omnitel	109
692	Tele2	109
693	P&T Luxembourg	110
694	Tango	110
695	Voxmobile S.A.	110
696	CTM GSM	111
697	Hutchison Telecom	111
698	Smartone Mobile Communications (Macao) Ltd.	111
699	Celtel Madagascar (Zain), GSM	112
700	Madamobil, CDMA 2000	112
701	Orange Madagascar, GSM	112
702	Telecom Malagasy Mobile, GSM	112
703	Celtel ltd.	113
704	Telekom Network Ltd.	113
705	Celcom (Malaysia) Berhad	114
706	CelCom (Malaysia) Berhad	114
707	DIGI Telecommunications	114
708	Electcoms Wireless Sdn Bhd	114
709	Malaysian Mobile Services Sdn Bhd	114
710	Telekom Malaysia Berhad	114
711	U Mobile Sdn. Bhd.	114
712	DhiMobile	115
713	Malitel	116
714	3G Telecommunications Ltd	117
715	go mobile	117
716	Vodafone Malta	117
717	Martinique Téléphone Mobile	118
718	Chinguitel S.A.	119
719	Mattel S.A.	119
720	Mauritel Mobiles	119
721	Cellplus	120
722	Emtel	120
723	Mahanagar Telephone (Mauritius) Ltd	120
724	Mahanagar Telephone (Mauritius) Ltd.	120
725	Telcel	121
726	FSM Telecom	122
727	Eventis Mobile GSM	123
728	JSC Moldtelecom	123
729	JSC Moldtelecom/3G UMTS (W-CDMA)	123
730	Moldcell GSM	123
731	Orange Moldova GSM	123
732	Mobicom	124
733	MTEL d.o.o. Podgorica	125
734	Ittissalat Al Maghrid	126
735	Méditélécom (GSM)	126
736	T.D.M. GSM	127
737	VM Sarl	127
738	Myanmar Post and Telecommunication	128
739	Mobile Telecommunications Ltd.	129
740	Powercom Pty Ltd	129
741	Telecom Namibia	129
742	Digicel (Fiji) Ltd	130
743	Nepal Telecommunications	131
744	Barablu Mobile Benelux Ltd	132
745	Blyk N.V.	132
746	Elephant Talk Comm. Premium Rate Serv. Neth. B.V.	132
747	INMO B.V.	132
748	KPN B.V.	132
749	KPN Mobile The Netherlands B.V.	132
750	Orange Nederland N.V.	132
751	ProRail B.V.	132
752	Tele2 (Netherlands) B.V.	132
753	Teleena holding B.V.	132
754	Telfort B.V.	132
755	T-Mobile Netherlands B.V.	132
756	Vodafone Libertel N.V.	132
757	OPT Mobilis	133
758	NZ Communications - UMTS Network	134
759	Reserved for AMPS MIN based IMSI's	134
760	Telecom New Zealand - UMTS Ntework	134
761	Teleom New Zealand CDMA Network	134
762	TelstraClear - GSM Network	134
763	Vodafone New Zealand GSM Network	134
764	Woosh Wireless - CDMA Network	134
765	Empresa Nicaragüense de Telecomunicaciones, S.A. (ENITEL)	135
766	Servicios de Comunicaciones, S.A. (SERCOM)	135
767	Celtel	136
768	Sahel.Com	136
769	Telecel	136
770	Econet Wireless Nigeria Ltd.	137
771	EMTS	137
772	Globacom	137
773	MTEL	137
774	MTN Nigeria Communications	137
775	Telecom Niue	138
776	ICE Norge AS	139
777	Jernbaneverket	139
778	Lycamobile Norway Ltd	139
779	Mobile Norway AS	139
780	Mundio Mobile Norway Ltd	139
781	Netcom AS	139
782	Network Norway AS	139
783	Post-og Teletilsynet	139
784	Systemnet AS	139
785	TDC AS	139
786	Tele2 Norge AS	139
787	Telenor Norge AS	139
788	Teletopia Gruppen AS	139
789	Ventelo Bedrift AS	139
790	Oman Mobile Telecommunications Company (Oman Mobile)	140
791	Oman Qatari Telecommunications Company (Nawras)	140
792	Oman Telecommunications Company (Omantel)	140
793	CMPak	141
794	Mobilink	141
795	PAK Telecom Mobile Ltd. (UFONE)	141
796	Telenor Pakistan	141
797	Warid Telecom	141
798	Palau National Communications Corp. (a.k.a. PNCC)	142
799	BSC de Panama S.A.	143
800	Cable & Wireless Panama S.A.	143
801	Claro Panamá, S.A.	143
802	Digicel (Panamá), S.A.	143
803	Telefónica Móviles Panamá S.A.	143
804	Bmobile	144
805	Digicel Ltd	144
806	Greencom	144
807	Compañia Privada de Comunicaciones S.A.	145
808	Hola Paraguay S.A.	145
809	Hutchison Telecom S.A.	145
810	TIM Peru	146
811	Digitel	147
812	Globe Telecom	147
813	Islacom	147
814	Smart Communications	147
815	ERA GSM (Polska Telefonia Cyfrowa Sp. Z.o.o.)	148
816	E-Telko	148
817	Idea (Polska Telefonia Komórkowa Centertel Sp. Z.o.o)	148
818	IDEA (UMTS)/PTK Centertel sp. Z.o.o.	148
819	Netia Mobile	148
820	Plus GSM (Polkomtel S.A.)	148
821	Premium internet	148
822	Tele2 Polska (Tele2 Polska Sp. Z.o.o.)	148
823	Telefony Opalenickie	148
824	Telekomunikacja Kolejowa (GSM-R)	148
825	Oniway - Inforcomunicaçôes, S.A.	149
826	Optimus - Telecomunicaçôes, S.A.	149
827	TMN - Telecomunicaçôes Movéis Nacionais, S.A.	149
828	Vodafone Telecel - Comunicaçôes Pessoais, S.A.	149
829	QATARNET	150
830	Cosmorom	151
831	Orange Romania	151
832	Romtelecom (CDMA)	151
833	Vodafone Romania SA	151
834	Baykal Westcom	152
835	Beeline	152
836	BM Telecom	152
837	Don Telecom	152
838	ECC	152
839	Ermak RMS	152
840	Extel	152
841	Kuban GSM	152
842	Megafon	152
843	Mobile Comms System	152
844	Mobile Telesystems	152
845	New Telephone Company	152
846	Nizhegorodskaya Cellular Communications	152
847	Orensot	152
848	Printelefone	152
849	Sibchallenge	152
850	Stuvtelesot	152
851	Telecom XXI	152
852	Uralsvyazinform	152
853	Volgograd Mobile	152
854	MTN Rwandacell	153
855	St. Pierre-et-Miquelon Télécom	154
856	GoMobile SamoaTel Ltd	155
857	Telecom Samoa Cellular Ltd.	155
858	Prima San Marino/San Marino Telecom	156
859	Companhia Santomese de Telecomunicações	157
860	Etihad Etisalat Company (Mobily)	158
861	Saudi Telecom	158
862	Expresso Senegal	159
863	Sentel GSM	159
864	Sonatel	159
865	Telekom Srbija a.d.	160
866	Telenor d.o.o.	160
867	Vip mobile d.o.o.	160
868	Cable & Wireless (Seychelles) Ltd.	161
869	Mediatech International Ltd.	161
870	Telecom (Seychelles) Ltd.	161
871	Africell	162
872	Celtel	162
873	Comium (Sierra Leone) Ltd.	162
874	Datatel (SL) Ltd CDMA	162
875	Datatel (SL) Ltd GSM	162
876	Lintel (Sierra Leone) Ltd.	162
877	Millicom	162
878	Mobitel	162
879	Digital Trunked Radio Network	163
880	MobileOne	163
881	SingTel ST GSM1800	163
882	SingTel ST GSM900	163
883	Starhub	163
884	Eurotel, GSM & NMT	164
885	Eurotel, UMTS	164
886	Orange, GSM	164
887	Orange, UMTS	164
888	Mobitel	165
889	SI Mobil	165
890	T-2 d.o.o.	165
891	Tusmobil d.o.o.	165
892	Bemobile (Bmobile (SI)) Ltd	166
893	Golis Telecommunications Company	167
894	Onkod Telecom Ltd	167
895	Amatole Telecommunication Pty Ltd	168
896	Bokamoso Consortium Pty Ltd	168
897	Bokone Telecoms Pty Ltd	168
898	Cape Town Metropolitan Council	168
899	Cell C (Pty) Ltd.	168
900	Ilizwi Telecommunications Pty Ltd	168
901	Karabo Telecoms (Pty) Ltd.	168
902	Kingdom Communications Pty Ltd	168
903	Mobile Telephone Networks (MTN) Pty Ltd	168
904	Neotel Pty Ltd	168
905	SAPS Gauteng	168
906	Sentech (Pty) Ltd.	168
907	Telkom SA Ltd	168
908	Thinta Thinta Telecommunications Pty Ltd	168
909	Vodacom (Pty) Ltd.	168
910	Barablu Móvil España, SLU	169
911	Best Spain Telecom, SL	169
912	BT España Compañia de Servicios Globales de	169
913	Cableuropa, SAU	169
914	E-Plus Móviles, SL	169
915	Euskaltel, SA	169
916	Fonyou Telecom, SL	169
917	France Telecom España, SA	169
918	Jazz Telecom, SAU	169
919	Lleida Networks Serveis Telemátics, SL	169
920	Lycamobile, SL	169
921	R Cable y Telecomunicaciones Galicia, SA	169
922	Telecable de Asturias, SAU	169
923	Telefónica Móviles España, SAU	169
924	Vizzavi España, SL	169
925	Vodafone España, SAU	169
926	Xfera Móviles, SA	169
927	Celtel Lanka Ltd.	170
928	MTN Network Ltd.	170
929	Areeba-Sudan	171
930	MTN Sudan	171
931	Network of the World Ltd (NOW)	171
932	SD Mobitel	171
933	Zain Sudan	171
934	Digicel	172
935	Intelsur	172
936	Telesur	172
937	Telesur (CDMA)	172
938	SPTC	173
939	Swazi MTN	173
940	3G Infrastructure Services AB	174
941	42IT AB	174
942	AINMT Sverige AB	174
943	Banverket	174
944	Barablu Mobile Scandinavia Ltd	174
945	Beepsend AB	174
946	Compatel Ltd	174
947	CoolTEL Aps A.B.	174
948	Digitel Mobile srl	174
949	Djuice Mobile Sweden, filial till Telenor Mobile Sweden AS	174
950	EuTel AB	174
951	Generic Mobile Systems Sweden AB	174
952	Götalandsnätet AB	174
953	H3G Access AB	174
954	iMEZ AB	174
955	Infobip Ltd	174
956	Linholmen Science Park AB	174
957	Mercury International Carrier Services	174
958	Mobile Arts AB	174
959	Mobimax AB	174
960	Mundio Mobile Sweden Ltd	174
961	MyIndian AB	174
962	Net4Mobility HB	174
963	NextGen Mobile Ltd	174
964	ReWiCom Scandinavia AB	174
965	Spring Mobil AB	174
966	Svenska UMTS-Nät AB	174
967	TDC Mobil A/S	174
968	Tele2 Sverige AB	174
969	Telenor Sverige AB	174
970	Telia Sonera Sverige AB	174
971	Tigo Ltd	174
972	Ventelo Sverige AB	174
973	Wireless Maingate Nordic AB	174
974	Bebbicell AG	175
975	Comfone AG	175
976	IN&Phone SA	175
977	Orange Communications SA	175
978	SBB AG	175
979	Swisscom Mobile AG	175
980	TDC Switzerland AG	175
981	Tele2 Telecommunications AG	175
982	Spacetel Syria	176
983	Syrian Telecom	176
984	Syriatel	176
985	CJSC Indigo Tajikistan	177
986	CTJTHSC Tajik-tel	177
987	JC Somoncom	177
988	Josa Babilon-T	177
989	TT mobile	177
990	Celtel (T) Ltd.	178
991	MIC (T) Ltd.	178
992	Vodacom (T) Ltd.	178
993	Zantel	178
994	ACT Mobile	179
995	AIS GSM	179
996	CAT CDMA	179
997	Cosmofon	180
998	Mobik Telekomunikacii dooel	180
999	Nov Operator	180
1000	T-Mobile	180
1001	WTI Macedonia	180
1002	Togo Telecom	181
1003	Digicel	182
1004	Digicel (Tonga) Ltd	182
1005	Tonga Communications Corporation	182
1006	Digicel Trinidad and Tobago Ltd.	183
1007	LaqTel Ltd.	183
1008	TSTT Mobile	183
1009	Orascom Telecom	184
1010	Tunisie Telecom	184
1011	Aria	185
1012	Aycell	185
1013	Telsim GSM	185
1014	Turkcell	185
1015	Barash Communication Technologies (BCTI)	186
1016	TM-Cell	186
1017	IslandCom Communication Ltd	187
1018	IslandCom Communications Ltd.	187
1019	Tuvalu Telecommunications Corporation	188
1020	Anupam Global Soft Uganda Ltd	189
1021	Celtel Uganda	189
1022	House of Integrated Technology and Systems Uganda Ltd	189
1023	i-Tel Ltd	189
1024	MTN Uganda Ltd.	189
1025	Smile Communications Uganda Ltd	189
1026	Sure Telecom Uganda Ltd	189
1027	Uganda Telecom Ltd.	189
1028	Warid Telecom Uganda Ltd.	189
1029	Astelit	190
1030	CJSC - Telesystems of Ukraine	190
1031	Golden Telecom	190
1032	International Telecommunications Ltd.	190
1033	Kyivstar GSM	190
1034	Ukrainian Mobile Communication, UMC	190
1035	Ukranian Radio Systems, URS	190
1036	Ukrtelecom	190
1037	Etisalat	191
1038	Airwave mmO2 Ltd	192
1039	(aq) Limited T/A aql	192
1040	British Telecom	192
1041	Cable and Wireless Guensey Ltd	192
1042	Cable and Wireless UK	192
1043	Cloud9	192
1044	Colt Mobile Telecommunications Ltd	192
1045	Flextel Ltd	192
1046	FMS Solutions Ltd	192
1047	Hay Systems Ltd	192
1048	Hutchison 3G UK Ltd	192
1049	Hutchison 3G UK Ltd.	192
1050	Internet Computer Bureau Ltd	192
1051	Jersey Airtel Ltd	192
1052	Jersey Telecom	192
1053	LogicStar Ltd	192
1054	Lycamobile UK Ltd	192
1055	Manx Telecom	192
1056	Mapesbury Communications Ltd.	192
1057	Marathon Telecom Ltd	192
1058	Mundio Mobile Ltd	192
1059	Network Rail Infrastructure Ltd	192
1060	Ntework Rail Infrastructure Ltd	192
1061	O2 UK Ltd.	192
1062	OnePhone (UK) Ltd	192
1063	Opal Telecom Ltd	192
1064	Orange	192
1065	Routo Telecommunications Ltd	192
1066	Software Cellular Network Ltd	192
1067	Stour Marine Ltd	192
1068	Teleena UK Ltd	192
1069	Teleware plc	192
1070	Tismi BV	192
1071	T-Mobile UK	192
1072	Vectone Network Ltd	192
1073	Vodafone Ltd	192
1074	Vodafone Ltd.	192
1075	Advantage Cellular Systems, Inc.	193
1076	Aeris Communications, Inc.	193
1077	Agri-Valley Broadband Inc	193
1078	Airadigm Communications	193
1079	Alaska Communications	193
1080	Alaska Digitel LLC	193
1081	Alaska Wireless Communications LLC	193
1202	Stelera Wireless LLC	193
1082	Arctic Slope Telephone Association Cooperative	193
1083	ARINC	193
1084	AT&T Mobility Vanguard Services	193
1085	AWCC	193
1086	Bend Cable Communications LLC	193
1087	Blanca Telephone Company	193
1088	Bluegrass Cellular LLC	193
1089	Bug Tussel Wireless LLC	193
1090	Cable & Communications Corporation dba Mid-Rivers Wireless	193
1091	Cablevision Systems Corporation	193
1092	California RSA No3 Ltd Partnership dba Golden State Cellular	193
1093	Caprock Cellular Ltd. Partnership	193
1094	Carolina West Wireless	193
1095	Cellular Network Partnership dba Pioneer Cellular	193
1096	Cellular Properties Inc.	193
1097	Cellular South Inc	193
1098	Centennial Communications	193
1099	Chariton Valley Communications Corp., Inc.	193
1100	Choice Phone LLC	193
1101	Cincinnati Bell Wireless LLC	193
1102	Cingular Wireless	193
1103	Cingular Wireless, Licensee Pacific Telesis Mobile Services, LLC	193
1104	Commnet Midwest LLC	193
1105	Commnet Wireless LLC	193
1106	Commnet Wireless, LLC	193
1107	Connect Net Inc	193
1108	Consolidated Telcom	193
1109	Contennial Puerto Rio License Corp.	193
1110	Convey Communications Inc	193
1111	Copper Valley Wireless	193
1112	Cordova Wireless Communications Inc	193
1113	Corr Wireless Communications	193
1114	Corr Wireless Communications LLC	193
1115	Cox TMI Wireless LLC	193
1116	Cricket Communications	193
1117	Criket Communications LLC	193
1118	Cross Telephone Company	193
1119	Cross Valiant Cellular Partnership	193
1120	CTC Telecom Inc	193
1121	East Kentucky Network LLC dba Appalachian Wireless	193
1122	Edigen Inc	193
1123	Elkhart Telephone Co. Inc. dba Epic Touch Co.	193
1124	Emery-Telecom Wireless Inc	193
1125	ETEX Communications dba ETEX Wireless	193
1126	Fisher Wireless Services Inc	193
1127	GCI Communications Corp.	193
1128	Geneseo Communications Services Inc	193
1129	Gigsky Inc	193
1130	Globalstar USA	193
1131	Globecomm Network Services Corporation	193
1132	GreenFly LLC	193
1133	GTA Wireless LLC	193
1134	Guamcell Cellular and Paging	193
1135	High Plains Midwest LLC, dba Wetlink Communications	193
1136	Illinois Valley Cellular	193
1137	Indigo Wireless, Inc.	193
1138	Inland Cellular Telephone Company	193
1139	Iowa RSA No.2 Ltd Partnership	193
1140	Iowa Wireless Services LLC	193
1141	Iowa Wireless Services LLC dba I Wireless	193
1142	Iris Wireless LLC	193
1143	James Valley Wireless LLC	193
1144	Jasper Wireless Inc.	193
1145	Kaplan Telephone Company Inc.	193
1146	Keystane Wireless LLC	193
1147	Kineto Wireless Inc	193
1148	LCFR LLC	193
1149	Leaco Rural Telephone Company Inc	193
1150	LightSquared LP	193
1151	LongLines Wireless	193
1152	Lynch 3G Communications Corporation	193
1153	Maine PCS LLC	193
1154	Metro PCS Wireless Inc	193
1155	Mid-Tex Cellular Ltd.	193
1156	Missouri RSA No. 5 Partnership	193
1157	Missouri RSA No 5 Partnership dba Chariton Valley Wireless	193
1158	Mohave Cellular L.P.	193
1159	MTA Communications dba MTA Wireless	193
1160	MTPCS LLC	193
1161	Nep Cellcorp Inc.	193
1162	NetAmerica Alliance LLC	193
1163	New Cell Inc. dba Cellcom	193
1164	New Cingular Wireless PCS, LLC	193
1165	New Dimension Wireless Ltd	193
1166	New Mexico RSA 4 East Ltd. Partnership	193
1167	Nex-Tech Wireless LLC	193
1168	Nextel Communications Inc	193
1169	Nexus Communications Inc	193
1170	North Dakota Network Co.	193
1171	North East Cellular Inc.	193
1172	Northeast Wireless Networks LLC	193
1173	North Sight Communications Inc	193
1174	Northwest Missouri Cellular Limited Partnership	193
1175	Nsight Spectrum LLC	193
1176	Nsighttel Wireless LLC	193
1177	nTELOS Communications Inc (Virginia PCS Alliance LC)	193
1178	Numerex Corp	193
1179	Oklahoma Western Telephone Company	193
1180	OTZ Communications Inc	193
1181	Pacific Telecom Inc	193
1182	Panhandle Telecommunication Systems Inc.	193
1183	PetroCom LLC	193
1184	Pine Belt Cellular Inc dba Pine Belt Wireless	193
1185	Pine Telephone Company dba Pine Cellular	193
1186	PinPoint Communications Inc.	193
1187	Pinpoint Wireless Inc.	193
1188	Proximiti Mobility Inc	193
1189	Public Service Cellular, Inc.	193
1190	RSA 1 Limited Partnership dba Cellular 29 Plus	193
1191	Rural Cellular Corporation	193
1192	Sagebrush Cellular Inc dba Nemont	193
1193	SLO Cellular Inc. dba CellularOne of San Luis Obispo	193
1194	Sl Wireless LLC	193
1195	Smith Bagley Inc, dba Cellular One	193
1196	South Canaan Cellular Communications Co. LP	193
1197	Southern Communications Services Inc.	193
1198	Space Data Corporation	193
1199	Sprintcom	193
1200	Sprintcom Inc	193
1201	Standing Rock Telecommunications	193
1203	Telalaska Cellular	193
1204	TeleBeeper of New Mexico Inc	193
1205	Telecom North America Mobile Inc	193
1206	Terrestar Networks Inc	193
1207	Texas RSA 1 dba XIT Wireless	193
1208	Texas RSA 7B3 dba Peoples Wireless Services	193
1209	Thumb Cellular Limited Partnership	193
1210	Thumb Cellular LLC	193
1211	T-Mobile USA	193
1212	TMP Corporation	193
1213	TotalSolutions Telecom LLC	193
1214	Transactions Network Services	193
1215	TX-11 Acquistion LLC	193
1216	TX RSA 15B2, LP dba Five Star Wireless	193
1217	UBET Wireless	193
1218	Uintah Basin Electronic Telecommunications	193
1219	Union Telephone Company	193
1220	United States Cellular	193
1221	United Wireless Inc	193
1222	US Cellular	193
1223	Verizon Wireless	193
1224	Vitelcom Cellular Inc dba Innovative Wireless	193
1225	Wave Runner LLC	193
1226	West Central Wireless	193
1227	Wilkes Cellular Inc.	193
1228	Wireless Communications Venture	193
1229	Wireless Solutions International	193
1230	Wireless Solutions International Inc.	193
1231	Wisconsin RSA#7 Ltd Patnership	193
1232	Worldcall Interconnect	193
1233	Ancel	194
1234	Ancel - GSM	194
1235	Ancel - TDMA	194
1236	CTI Móvil	194
1237	Movistar	194
1238	Buztel	195
1239	Coscom	195
1240	Daewoo Unitel	195
1241	Uzdunrobita	195
1242	Uzmacom	195
1243	Digicel Vanuatu	196
1244	SMILE	196
1245	Corporación Digitel	197
1246	Digicel	197
1247	Infonet	197
1248	Telcel, C.A.	197
1249	Telecomunicaciones Movilnet, C.A.	197
1250	Beeline VN/GTEL Mobile JSC	198
1251	EVNTelecom	198
1252	EVNTelecom/ 3G	198
1253	Mobifone	198
1254	S Telecom (CDMA)	198
1255	Viettel	198
1256	Vinaphone	198
1257	Spacetel Yemen	199
1258	Yemen Mobile Phone Company	199
1259	Celtel Zambia Ltd.	200
1260	Telecel Zambia Ltd.	200
1261	Zamtel	200
1262	Econet	201
1263	Net One	201
1264	Telecel	201
\.


--
-- Data for Name: networks; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY networks (id, mcc, mnc, mno_id) FROM stdin;
7236	412	1	4
7237	412	20	6
7238	412	30	5
7239	412	40	3
7240	412	88	2
7241	276	1	7
7242	276	2	10
7243	276	3	8
7244	276	4	9
7245	603	1	11
7246	603	2	12
7247	213	3	13
7248	631	2	15
7249	631	4	14
7250	365	10	16
7251	344	30	17
7252	344	920	19
7253	344	930	18
7254	722	10	20
7255	722	20	24
7256	722	70	26
7257	722	310	23
7258	722	320	21
7259	722	330	22
7260	722	341	25
7261	363	1	27
7262	505	1	46
7263	505	2	42
7264	505	3	50
7265	505	4	33
7266	505	5	47
7267	505	6	34
7268	505	7	50
7269	505	8	40
7270	505	9	31
7271	505	10	39
7272	505	11	46
7273	505	12	35
7274	505	13	45
7275	505	14	29
7276	505	15	28
7277	505	16	48
7278	505	17	49
7279	505	18	43
7280	505	19	37
7281	505	20	32
7282	505	21	44
7283	505	24	30
7284	505	62	38
7285	505	68	38
7286	505	71	46
7287	505	72	46
7288	505	88	36
7289	505	90	41
7290	505	99	40
7291	232	1	53
7292	232	2	53
7293	232	3	56
7294	232	4	56
7295	232	5	55
7296	232	6	55
7297	232	7	56
7298	232	9	53
7299	232	10	52
7300	232	11	53
7301	232	12	55
7302	232	14	52
7303	232	15	51
7304	232	91	54
7305	400	1	57
7306	400	2	59
7307	400	3	60
7308	400	4	58
7309	426	1	61
7310	426	2	65
7311	426	3	62
7312	426	4	64
7313	426	5	63
7314	470	1	67
7315	470	2	66
7316	470	3	68
7317	342	600	69
7318	342	820	70
7319	257	1	73
7320	257	2	74
7321	257	3	71
7322	257	4	72
7323	257	5	75
7324	257	6	76
7325	206	1	79
7326	206	10	78
7327	206	20	77
7328	702	67	80
7329	702	68	81
7330	616	1	82
7331	616	2	84
7332	616	3	83
7333	402	11	85
7334	402	17	86
7335	736	1	88
7336	736	2	87
7337	736	3	89
7338	218	3	90
7339	218	5	92
7340	218	90	91
7341	652	1	94
7342	652	2	95
7343	652	4	93
7344	724	0	131
7345	724	1	101
7346	724	2	104
7347	724	3	103
7348	724	4	98
7349	724	5	128
7350	724	6	135
7351	724	7	108
7352	724	8	106
7353	724	9	122
7354	724	10	97
7355	724	11	120
7356	724	12	96
7357	724	13	129
7358	724	14	105
7359	724	15	102
7360	724	16	99
7361	724	17	100
7362	724	18	107
7363	724	19	119
7364	724	21	125
7365	724	23	130
7366	724	25	115
7367	724	27	117
7368	724	29	118
7369	724	31	111
7370	724	33	127
7371	724	35	114
7372	724	37	124
7373	724	39	110
7374	724	41	134
7375	724	43	123
7376	724	45	133
7377	724	47	126
7378	724	48	116
7379	724	51	132
7380	724	53	121
7381	724	55	113
7382	724	57	112
7383	724	59	109
7384	348	170	137
7385	348	370	136
7386	348	570	138
7387	348	770	139
7388	528	11	140
7389	284	1	142
7390	284	5	141
7391	613	2	143
7392	613	3	144
7393	642	1	146
7394	642	2	145
7395	642	3	149
7396	642	7	148
7397	642	8	147
7398	642	82	150
7399	456	1	154
7400	456	2	152
7401	456	3	157
7402	456	4	151
7403	456	5	156
7404	456	6	155
7405	456	8	158
7406	456	18	153
7407	624	1	159
7408	624	2	160
7409	302	36	164
7410	302	37	167
7411	302	62	166
7412	302	63	161
7413	302	64	162
7414	302	656	171
7415	302	66	168
7416	302	67	163
7417	302	68	170
7418	302	71	165
7419	302	72	169
7420	302	86	172
7421	625	1	173
7422	625	2	174
7423	346	140	175
7424	623	1	177
7425	623	2	178
7426	623	3	176
7427	622	1	179
7428	622	2	180
7429	730	1	185
7430	730	2	188
7431	730	3	187
7432	730	4	183
7433	730	5	186
7434	730	6	181
7435	730	7	189
7436	730	8	191
7437	730	9	183
7438	730	10	184
7439	730	11	182
7440	730	12	190
7441	460	0	192
7442	460	1	194
7443	460	3	195
7444	460	4	193
7445	732	1	199
7446	732	2	201
7447	732	20	203
7448	732	99	202
7449	732	101	200
7450	732	102	197
7451	732	103	198
7452	732	111	198
7453	732	123	204
7454	732	130	196
7455	654	1	205
7456	629	1	206
7457	629	10	207
7458	548	1	208
7459	712	1	211
7460	712	2	211
7461	712	3	210
7462	712	4	209
7463	712	20	212
7464	612	2	214
7465	612	3	217
7466	612	4	215
7467	612	5	216
7468	612	6	218
7469	612	7	213
7470	219	1	220
7471	219	2	219
7472	219	10	221
7473	368	1	222
7474	362	51	225
7475	362	69	223
7476	362	91	224
7477	280	1	226
7478	280	10	229
7479	280	20	228
7480	280	22	227
7481	230	1	233
7482	230	2	232
7483	230	3	235
7484	230	4	230
7485	230	5	234
7486	230	98	231
7487	230	99	236
7488	630	1	241
7489	630	2	237
7490	630	5	240
7491	630	86	238
7492	630	88	242
7493	630	89	239
7494	238	1	248
7495	238	2	247
7496	238	3	246
7497	238	6	244
7498	238	7	243
7499	238	10	248
7500	238	12	245
7501	238	20	250
7502	238	30	251
7503	238	77	249
7504	638	1	252
7505	370	1	254
7506	370	2	256
7507	370	3	255
7508	370	4	253
7509	740	0	257
7510	740	1	258
7511	740	2	259
7512	602	1	261
7513	602	2	262
7514	602	3	260
7515	706	1	263
7516	706	2	264
7517	706	3	265
7518	627	1	266
7519	248	1	268
7520	248	2	271
7521	248	3	273
7522	248	4	269
7523	248	5	267
7524	248	6	270
7525	248	7	274
7526	248	71	272
7527	636	1	275
7528	750	1	276
7529	274	2	280
7530	288	1	278
7531	288	2	279
7532	288	3	277
7533	542	1	283
7534	542	2	281
7535	542	3	282
7536	244	3	285
7537	244	4	285
7538	244	5	286
7539	244	9	287
7540	244	10	290
7541	244	12	285
7542	244	13	285
7543	244	14	284
7544	244	21	288
7545	244	29	289
7546	244	91	291
7547	208	1	295
7548	208	2	295
7549	208	5	294
7550	208	6	294
7551	208	7	294
7552	208	10	296
7553	208	11	297
7554	208	13	298
7555	208	20	292
7556	208	21	292
7557	208	22	299
7558	208	88	293
7559	647	0	300
7560	647	2	301
7561	647	10	302
7562	340	11	303
7563	547	2	304
7564	547	10	305
7565	547	20	306
7566	628	1	308
7567	628	2	309
7568	628	3	307
7569	628	4	310
7570	607	1	313
7571	607	2	311
7572	607	3	312
7573	282	1	314
7574	282	2	316
7575	282	3	315
7576	282	4	317
7577	282	5	318
7578	262	1	327
7579	262	2	328
7580	262	3	322
7581	262	4	328
7582	262	5	322
7583	262	6	327
7584	262	7	325
7585	262	8	325
7586	262	9	328
7587	262	10	320
7588	262	11	325
7589	262	12	321
7590	262	13	324
7591	262	14	323
7592	262	15	319
7593	262	76	326
7594	262	77	322
7595	620	1	333
7596	620	2	329
7597	620	3	331
7598	620	4	330
7599	620	11	332
7600	266	1	336
7601	266	6	334
7602	266	9	335
7603	202	1	339
7604	202	2	340
7605	202	3	342
7606	202	4	341
7607	202	5	343
7608	202	6	338
7609	202	7	337
7610	202	9	344
7611	202	10	344
7612	290	1	345
7613	340	1	349
7614	340	2	350
7615	340	3	351
7616	340	8	347
7617	340	10	348
7618	340	20	346
7619	704	1	353
7620	704	2	352
7621	704	3	354
7622	611	1	356
7623	611	2	357
7624	611	5	355
7625	632	1	358
7626	632	2	359
7627	738	1	360
7628	372	1	361
7629	372	2	362
7630	372	3	363
7631	708	1	366
7632	708	2	364
7633	708	40	365
7634	454	0	377
7635	454	1	382
7636	454	2	367
7637	454	3	368
7638	454	4	376
7639	454	5	371
7640	454	6	378
7641	454	7	380
7642	454	8	383
7643	454	9	379
7644	454	10	373
7645	454	11	381
7646	454	12	374
7647	454	15	369
7648	454	16	372
7649	454	18	375
7650	454	19	370
7651	216	1	384
7652	216	30	386
7653	216	70	385
7654	274	1	388
7655	274	2	390
7656	274	3	390
7657	274	4	389
7658	274	7	387
7659	404	0	457
7660	404	1	393
7661	404	2	421
7662	404	3	411
7663	404	4	484
7664	404	5	470
7665	404	6	413
7666	404	7	483
7667	404	9	517
7668	404	10	408
7669	404	11	478
7670	404	12	488
7671	404	13	472
7672	404	14	526
7673	404	15	395
7674	404	16	419
7675	404	17	462
7676	404	18	519
7677	404	19	489
7678	404	20	471
7679	404	21	426
7680	404	22	487
7681	404	23	486
7682	404	24	485
7683	404	25	451
7992	440	94	654
7684	404	27	476
7685	404	29	450
7686	404	30	482
7687	404	31	415
7688	404	33	458
7689	404	34	433
7690	404	35	453
7691	404	36	518
7692	404	37	454
7693	404	38	429
7694	404	40	407
7695	404	41	392
7696	404	42	403
7697	404	43	477
7698	404	44	525
7699	404	46	475
7700	404	48	461
7701	404	49	404
7702	404	50	521
7703	404	51	434
7704	404	52	522
7705	404	53	443
7706	404	54	447
7707	404	55	446
7708	404	56	490
7709	404	57	432
7710	404	58	439
7711	404	59	444
7712	404	60	394
7713	404	61	459
7714	404	62	435
7715	404	63	452
7716	404	64	431
7717	404	65	460
7718	404	66	440
7719	404	67	520
7720	404	68	494
7721	404	69	495
7722	404	70	425
7723	404	71	436
7724	404	72	437
7725	404	73	428
7726	404	74	448
7727	404	75	430
7728	404	76	442
7729	404	77	441
7730	404	78	449
7731	404	79	427
7732	404	80	445
7733	404	81	438
7734	404	82	491
7735	404	83	496
7736	404	84	473
7737	404	85	523
7738	404	86	474
7739	404	87	492
7740	404	88	480
7741	404	89	493
7742	404	90	417
7743	404	91	456
7744	404	92	418
7745	404	93	416
7746	404	94	422
7747	404	95	414
7748	404	96	410
7749	404	97	424
7750	404	98	409
7751	404	99	455
7752	405	0	524
7753	405	1	497
7754	405	3	498
7755	405	4	499
7756	405	5	500
7757	405	6	501
7758	405	7	502
7759	405	8	503
7760	405	9	504
7761	405	10	505
7762	405	11	506
7763	405	12	507
7764	405	13	509
7765	405	14	508
7766	405	15	510
7767	405	17	511
7768	405	18	512
7769	405	20	513
7770	405	21	514
7771	405	22	515
7772	405	23	516
7773	405	25	527
7774	405	27	528
7775	405	28	529
7776	405	29	530
7777	405	30	531
7778	405	31	532
7779	405	32	533
7780	405	34	534
7781	405	35	535
7782	405	36	536
7783	405	37	538
7784	405	38	537
7785	405	39	539
7886	425	8	618
7786	405	41	540
7787	405	42	541
7788	405	43	542
7789	405	44	543
7790	405	45	544
7791	405	46	545
7792	405	47	546
7793	405	52	406
7794	405	53	420
7795	405	54	423
7796	405	55	412
7797	405	56	405
7798	405	66	481
7799	405	67	479
7800	405	68	547
7801	405	70	391
7802	405	71	465
7803	405	72	468
7804	405	73	463
7805	405	74	466
7806	405	75	464
7807	405	76	469
7808	405	77	467
7809	405	80	399
7810	405	81	397
7811	405	82	396
7812	405	83	398
7813	405	84	400
7814	405	85	401
7815	405	86	402
7816	510	0	552
7817	510	1	553
7818	510	8	551
7819	510	10	554
7820	510	11	548
7821	510	21	549
7822	510	28	550
7823	901	1	560
7824	901	3	563
7825	901	5	576
7826	901	6	577
7827	901	10	555
7828	901	11	561
7829	901	12	566
7830	901	13	556
7831	901	14	574
7832	901	15	570
7833	901	16	564
7834	901	17	565
7835	901	18	558
7836	901	19	580
7837	901	20	562
7838	901	21	571
7839	901	22	567
7840	901	23	557
7841	901	24	581
7842	901	26	573
7843	901	27	569
7844	901	28	579
7845	901	29	575
7846	901	31	559
7847	901	32	568
7848	901	33	572
7849	901	88	578
7850	432	11	582
7851	432	14	584
7852	432	19	583
7853	418	5	585
7854	418	20	605
7855	418	30	606
7856	418	40	604
7857	418	47	586
7858	418	48	589
7859	418	49	588
7860	418	62	590
7861	418	70	603
7862	418	80	587
7863	418	81	591
7864	418	83	601
7865	418	84	597
7866	418	85	595
7867	418	86	598
7868	418	87	593
7869	418	88	599
7870	418	89	594
7871	418	91	596
7872	418	92	592
7873	418	93	600
7874	418	94	602
7875	272	1	611
7993	440	95	654
7876	272	2	608
7877	272	3	610
7878	272	7	609
7879	272	9	607
7880	425	1	622
7881	425	2	614
7882	425	3	623
7883	425	4	617
7884	425	6	625
7885	425	7	621
7887	425	11	612
7888	425	12	615
7889	425	13	620
7890	425	14	613
7891	425	15	619
7892	425	16	624
7893	425	17	616
7894	222	1	631
7895	222	2	627
7896	222	10	630
7897	222	77	629
7898	222	88	632
7899	222	98	626
7900	222	99	628
7901	338	20	633
7902	338	50	634
7903	440	1	642
7904	440	2	644
7905	440	3	640
7906	440	4	654
7907	440	6	654
7908	440	7	635
7909	440	8	635
7910	440	9	643
7911	440	10	643
7912	440	11	649
7913	440	12	641
7914	440	13	641
7915	440	14	647
7916	440	15	641
7917	440	16	641
7918	440	17	641
7919	440	18	649
7920	440	19	637
7921	440	20	639
7922	440	21	641
7923	440	22	643
7924	440	23	649
7925	440	24	636
7926	440	25	638
7927	440	26	645
7928	440	27	648
7929	440	28	646
7930	440	29	641
7931	440	30	641
7932	440	31	643
7933	440	32	641
7934	440	33	649
7935	440	34	645
7936	440	35	643
7937	440	36	641
7938	440	37	641
7939	440	38	641
7940	440	39	641
7941	440	40	654
7942	440	41	654
7943	440	42	654
7944	440	43	654
7945	440	44	654
7946	440	45	654
7947	440	46	654
7948	440	47	654
7949	440	48	654
7950	440	49	641
7951	440	50	635
7952	440	51	635
7953	440	52	635
7954	440	53	635
7955	440	54	635
7956	440	55	635
7957	440	56	635
7958	440	58	643
7959	440	60	643
7960	440	61	636
7961	440	62	645
7962	440	63	641
7963	440	64	641
7964	440	65	646
7965	440	66	641
7966	440	67	647
7967	440	68	645
7968	440	69	641
7969	440	70	635
7970	440	71	635
7971	440	72	635
7972	440	73	635
7973	440	74	635
7974	440	75	635
7975	440	76	635
7976	440	77	635
7977	440	78	650
7978	440	79	635
7979	440	80	652
7980	440	81	652
7981	440	82	653
7982	440	83	651
7983	440	84	653
7984	440	85	651
7985	440	86	652
7986	440	87	636
7987	440	88	635
7988	440	89	635
7989	440	90	654
7990	440	92	654
7991	440	93	654
7994	440	96	654
7995	440	97	654
7996	440	98	654
7997	440	99	641
7998	441	40	641
7999	441	41	641
8000	441	42	641
8001	441	43	643
8002	441	44	636
8003	441	45	646
8004	441	50	652
8005	441	51	653
8006	441	61	654
8007	441	62	654
8008	441	63	654
8009	441	64	654
8010	441	65	654
8011	441	70	635
8012	441	90	641
8013	441	91	641
8014	441	92	641
8015	441	93	638
8016	441	94	647
8017	441	98	645
8018	441	99	645
8019	416	1	655
8020	416	2	658
8021	416	3	657
8022	416	77	656
8023	401	1	659
8024	401	2	660
8025	639	2	662
8026	639	3	661
8027	450	2	663
8028	450	3	664
8029	419	2	665
8030	419	3	667
8031	419	4	666
8032	437	1	668
8033	457	1	670
8034	457	2	669
8035	457	8	671
8036	247	1	675
8037	247	2	678
8038	247	3	679
8039	247	4	672
8040	247	5	673
8041	247	6	677
8042	247	7	676
8043	247	8	674
8044	415	5	682
8045	415	32	680
8046	415	33	680
8047	415	34	680
8048	415	35	680
8049	415	36	681
8050	415	37	681
8051	415	38	681
8052	415	39	681
8053	651	1	684
8054	651	2	683
8055	618	4	685
8056	295	1	688
8057	295	2	689
8058	295	5	686
8059	295	77	687
8060	246	1	691
8061	246	2	690
8062	246	3	692
8063	270	1	693
8064	270	77	694
8065	270	99	695
8066	455	0	698
8067	455	1	696
8068	455	3	697
8069	646	1	699
8070	646	2	701
8071	646	3	700
8072	646	4	702
8073	650	1	704
8074	650	10	703
8075	502	10	707
8076	502	12	709
8077	502	13	705
8078	502	14	710
8079	502	16	707
8080	502	17	709
8081	502	18	711
8082	502	19	706
8083	502	20	708
8084	472	1	712
8085	610	1	713
8086	278	1	716
8087	278	21	715
8088	278	77	714
8089	340	12	717
8090	609	1	719
8091	609	2	718
8092	609	10	720
8093	617	1	721
8094	617	2	724
8095	617	3	723
8096	617	10	722
8097	334	20	725
8098	550	1	726
8099	259	1	731
8100	259	2	730
8101	259	4	727
8102	259	5	729
8103	259	99	728
8104	428	99	732
8105	297	3	733
8106	604	0	735
8107	604	1	734
8108	643	1	736
8109	643	4	737
8110	414	1	738
8111	649	1	739
8112	649	2	741
8113	649	3	740
8114	542	2	742
8115	429	1	743
8116	204	2	752
8117	204	3	745
8118	204	4	756
8119	204	5	746
8338	240	17	952
8120	204	6	744
8121	204	7	753
8122	204	8	749
8123	204	10	748
8124	204	12	754
8125	204	14	747
8126	204	16	755
8127	204	18	754
8128	204	20	750
8129	204	21	751
8130	204	60	748
8131	204	69	749
8132	546	1	757
8133	530	0	759
8134	530	1	763
8135	530	2	761
8136	530	3	764
8137	530	4	762
8138	530	5	760
8139	530	24	758
8140	710	21	765
8141	710	73	766
8142	614	1	768
8143	614	2	767
8144	614	3	769
8145	621	20	770
8146	621	30	774
8147	621	40	773
8148	621	50	772
8149	621	60	771
8150	555	1	775
8151	242	1	787
8152	242	2	781
8153	242	3	788
8154	242	4	786
8155	242	5	782
8156	242	6	776
8157	242	7	789
8158	242	8	785
8159	242	9	780
8160	242	10	783
8161	242	11	784
8162	242	12	787
8163	242	20	777
8164	242	21	777
8165	242	22	782
8166	242	23	778
8167	242	24	779
8168	422	2	790
8169	422	3	791
8170	422	4	792
8171	410	1	794
8172	410	3	795
8173	410	4	793
8174	410	6	796
8175	410	7	797
8176	552	1	798
8177	714	1	800
8178	714	2	799
8179	714	20	803
8180	714	3	801
8181	714	4	802
8182	537	1	804
8183	537	2	806
8184	537	3	805
8185	744	1	808
8186	744	2	809
8187	744	3	807
8188	716	10	810
8189	515	1	813
8190	515	2	812
8191	515	3	814
8192	515	5	811
8193	260	1	820
8194	260	2	815
8195	260	3	817
8196	260	4	822
8197	260	5	818
8198	260	6	819
8199	260	7	821
8200	260	8	816
8201	260	9	824
8202	260	10	823
8203	268	1	828
8204	268	3	826
8205	268	5	825
8206	268	6	827
8207	427	1	829
8208	226	1	833
8209	226	2	832
8210	226	3	830
8211	226	10	831
8212	250	1	844
8213	250	2	842
8214	250	3	846
8215	250	4	849
8216	250	5	843
8217	250	7	836
8218	250	10	837
8219	250	11	847
8220	250	12	834
8221	250	13	841
8222	250	16	845
8223	250	17	839
8224	250	19	853
8225	250	20	838
8226	250	28	840
8227	250	39	852
8228	250	44	850
8229	250	92	848
8230	250	93	851
8231	250	99	835
8232	635	10	854
8233	308	1	855
8234	549	1	857
8235	549	27	856
8236	292	1	858
8237	626	1	859
8238	420	1	861
8239	420	3	860
8240	608	1	864
8241	608	2	863
8242	608	3	862
8243	220	1	866
8244	220	3	865
8245	220	5	867
8246	633	1	868
8247	633	2	869
8248	633	10	870
8249	619	1	872
8250	619	2	877
8251	619	3	871
8252	619	4	873
8253	619	5	876
8254	619	25	878
8255	619	40	875
8256	619	50	874
8257	525	1	882
8258	525	2	881
8259	525	3	880
8260	525	5	883
8261	525	12	879
8262	231	1	886
8263	231	2	884
8264	231	4	885
8265	231	5	887
8266	293	40	889
8267	293	41	888
8268	293	64	890
8269	293	70	891
8270	540	2	892
8271	637	30	893
8272	637	70	894
8273	655	1	909
8274	655	2	907
8275	655	6	906
8276	655	7	899
8277	655	10	903
8278	655	11	905
8279	655	12	903
8280	655	13	904
8281	655	21	898
8282	655	30	896
8283	655	31	901
8284	655	32	900
8285	655	33	908
8286	655	34	897
8287	655	35	902
8288	655	36	895
8289	214	1	925
8290	214	3	917
8291	214	4	926
8292	214	5	923
8293	214	6	925
8294	214	7	923
8295	214	8	915
8296	214	9	917
8297	214	15	912
8298	214	16	922
8299	214	17	921
8300	214	18	913
8301	214	19	914
8302	214	20	916
8303	214	21	918
8304	214	22	911
8305	214	23	910
8306	214	24	924
8307	214	25	920
8308	214	26	919
8309	413	2	928
8310	413	3	927
8311	634	1	932
8312	634	2	929
8313	634	5	931
8314	634	6	933
8315	634	99	930
8316	746	2	936
8317	746	3	934
8318	746	4	935
8319	746	5	937
8320	653	1	938
8321	653	10	939
8322	240	1	970
8323	240	2	953
8324	240	3	942
8325	240	4	940
8326	240	5	966
8327	240	6	969
8328	240	7	968
8329	240	8	969
8330	240	9	949
8331	240	10	965
8332	240	11	956
8333	240	12	944
8334	240	13	972
8335	240	14	967
8336	240	15	973
8337	240	16	941
8339	240	18	951
8340	240	19	960
8341	240	20	954
8342	240	21	943
8343	240	22	950
8344	240	23	955
8345	240	24	962
8346	240	25	948
8347	240	26	945
8348	240	27	961
8349	240	28	947
8350	240	29	957
8351	240	30	963
8352	240	31	959
8353	240	32	946
8354	240	33	958
8355	240	34	971
8356	240	40	964
8357	228	1	979
8358	228	2	980
8359	228	3	977
8360	228	5	975
8361	228	6	978
8362	228	7	976
8363	228	8	981
8364	228	12	980
8365	228	51	974
8366	417	1	984
8367	417	2	982
8368	417	9	983
8369	436	1	987
8370	436	2	985
8371	436	3	989
8372	436	4	988
8373	436	5	986
8374	640	2	991
8375	640	3	993
8376	640	4	992
8377	640	5	990
8378	520	0	996
8379	520	1	995
8380	520	15	994
8381	294	1	1000
8382	294	2	997
8383	294	3	999
8384	294	10	1001
8385	294	11	998
8386	615	1	1002
8387	539	1	1005
8388	539	43	1003
8389	539	88	1004
8390	374	12	1008
8391	374	130	1006
8392	374	140	1007
8393	605	2	1010
8394	605	3	1009
8395	286	1	1014
8396	286	2	1013
8397	286	3	1011
8398	286	4	1012
8399	438	1	1015
8400	438	2	1016
8401	376	352	1018
8402	376	360	1017
8403	553	1	1019
8404	641	1	1021
8405	641	10	1024
8406	641	11	1027
8407	641	14	1022
8408	641	18	1026
8409	641	22	1028
8410	641	30	1020
8411	641	33	1025
8412	641	66	1023
8413	255	1	1034
8414	255	2	1035
8415	255	3	1033
8416	255	4	1032
8417	255	5	1031
8418	255	6	1029
8419	255	7	1036
8420	255	21	1030
8421	424	2	1037
8422	234	0	1040
8423	234	1	1056
8424	234	2	1061
8425	234	3	1051
8426	234	4	1046
8427	234	5	1044
8428	234	6	1050
8429	234	7	1042
8430	234	8	1062
8431	234	9	1070
8432	234	10	1061
8433	234	11	1061
8434	234	12	1060
8435	234	13	1060
8436	234	14	1047
8437	234	15	1074
8438	234	16	1063
8439	234	17	1045
8440	234	18	1043
8441	234	19	1069
8442	234	20	1049
8443	234	21	1053
8444	234	22	1065
8445	234	23	1072
8446	234	24	1067
8447	234	25	1066
8448	234	26	1054
8449	234	27	1068
8450	234	28	1057
8451	234	29	1039
8452	234	30	1071
8453	234	31	1071
8454	234	32	1071
8455	234	33	1064
8456	234	34	1064
8457	234	50	1052
8458	234	55	1041
8459	234	58	1055
8460	234	76	1040
8461	234	78	1038
8462	235	0	1058
8463	235	77	1040
8464	235	91	1073
8465	235	92	1042
8466	235	94	1048
8467	235	95	1059
8468	310	10	1223
8469	310	12	1223
8470	310	13	1223
8471	310	16	1116
8472	310	17	1173
8473	310	20	1219
8474	310	30	1098
8475	310	35	1125
8476	310	40	1159
8477	310	50	1079
8478	310	60	1108
8479	310	70	1102
8480	310	80	1114
8481	310	90	1117
8482	310	100	1166
8483	310	110	1181
8484	310	120	1200
8485	310	130	1094
8486	310	140	1133
8487	310	150	1102
8488	310	160	1211
8489	310	170	1102
8490	310	180	1226
8491	310	190	1081
8492	310	200	1211
8493	310	210	1211
8494	310	220	1211
8495	310	230	1211
8496	310	240	1211
8497	310	250	1211
8498	310	260	1211
8499	310	270	1211
8500	310	280	1109
8501	310	290	1161
8502	310	300	1087
8503	310	310	1211
8504	310	320	1195
8505	310	330	1085
8506	310	340	1135
8507	310	350	1158
8508	310	360	1095
8509	310	370	1134
8510	310	380	1164
8511	310	390	1215
8512	310	400	1225
8513	310	410	1102
8514	310	420	1101
8515	310	430	1080
8516	310	440	1178
8517	310	450	1171
8518	310	460	1212
8519	310	470	1177
8520	310	480	1100
8521	310	490	1211
8522	310	500	1189
8523	310	510	1176
8524	310	520	1214
8525	310	530	1140
8526	310	540	1179
8527	310	550	1229
8528	310	560	1102
8529	310	570	1160
8530	310	580	1138
8531	310	590	1223
8532	310	600	1163
8533	310	610	1123
8534	310	620	1176
8535	310	630	1077
8536	310	640	1078
8537	310	650	1144
8538	310	660	1211
8539	310	670	1084
8540	310	680	1102
8541	310	690	1146
8542	310	700	1119
8543	310	710	1082
8544	310	720	1230
8545	310	730	1222
8546	310	740	1110
8547	310	750	1121
8548	310	760	1152
8549	310	770	1141
8550	310	780	1107
8551	310	790	1186
8552	310	800	1211
8553	310	810	1148
8554	310	820	1196
8555	310	830	1093
8556	310	840	1205
8557	310	850	1076
8558	310	860	1216
8559	310	870	1145
8560	310	880	1075
8561	310	890	1191
8562	310	900	1090
8563	310	910	1223
8564	310	920	1143
8565	310	930	1111
8566	310	940	1142
8567	310	950	1207
8568	310	960	1217
8569	310	970	1130
8570	310	980	1208
8571	310	990	1232
8572	311	0	1155
8573	311	10	1099
8574	311	20	1156
8575	311	30	1137
8576	311	40	1106
8577	311	50	1209
8578	311	60	1198
8579	311	70	1231
8580	311	80	1185
8581	311	90	1151
8582	311	100	1167
8583	311	110	1223
8584	311	120	1100
8585	311	130	1150
8586	311	140	1118
8587	311	150	1227
8588	311	160	1150
8589	311	170	1183
8590	311	180	1103
8591	311	190	1096
8592	311	200	1083
8593	311	210	1124
8594	311	220	1220
8595	311	230	1097
8596	311	240	1112
8597	311	250	1225
8598	311	260	1193
8599	311	270	1223
8600	311	271	1223
8601	311	272	1223
8602	311	273	1223
8603	311	274	1223
8604	311	275	1223
8605	311	276	1223
8606	311	277	1223
8607	311	278	1223
8608	311	279	1223
8609	311	280	1223
8610	311	281	1223
8611	311	282	1223
8612	311	283	1223
8613	311	284	1223
8614	311	285	1223
8615	311	286	1223
8616	311	287	1223
8617	311	288	1223
8618	311	289	1223
8619	311	290	1187
8620	311	300	1169
8621	311	310	1149
8622	311	320	1105
8623	311	330	1089
8624	311	340	1136
8625	311	350	1192
8626	311	360	1202
8627	311	370	1127
8628	311	380	1165
8629	311	390	1223
8630	311	410	1139
8631	311	420	1174
8632	311	430	1190
8633	311	440	1088
8634	311	450	1182
8635	311	460	1126
8636	311	470	1224
8637	311	480	1223
8638	311	481	1223
8639	311	482	1223
8640	311	483	1223
8641	311	484	1223
8642	311	485	1223
8643	311	486	1223
8644	311	487	1223
8645	311	488	1223
8646	311	489	1223
8647	311	490	1199
8648	311	500	1120
8649	311	510	1150
8650	311	520	1150
8651	311	530	1228
8652	311	540	1188
8653	311	550	1104
8654	311	560	1180
8655	311	570	1086
8656	311	580	1220
8657	311	590	1092
8658	311	600	1115
8659	311	610	1170
8660	311	620	1206
8661	311	630	1113
8662	311	640	1201
8663	311	650	1221
8664	311	660	1154
8665	311	670	1184
8666	311	680	1132
8667	311	690	1204
8668	311	700	1213
8669	311	710	1172
8670	311	720	1153
8671	311	730	1188
8672	311	740	1203
8673	311	750	1162
8674	311	760	1122
8675	311	770	1128
8676	311	780	1095
8677	311	790	1095
8678	311	800	1088
8679	311	810	1088
8680	311	820	1147
8681	311	830	1210
8682	311	840	1175
8683	311	850	1175
8684	311	860	1218
8685	311	870	1200
8686	311	880	1200
8687	311	890	1131
8688	311	900	1129
8689	311	910	1194
8690	311	920	1157
8691	311	930	1091
8692	316	10	1168
8693	316	11	1197
8694	748	0	1235
8695	748	1	1234
8696	748	3	1233
8697	748	7	1237
8698	748	10	1236
8699	434	1	1238
8700	434	2	1242
8701	434	4	1240
8702	434	5	1239
8703	434	7	1241
8704	541	1	1244
8705	541	5	1243
8706	734	1	1247
8707	734	2	1245
8708	734	3	1246
8709	734	4	1248
8710	734	6	1249
8711	452	1	1253
8712	452	2	1256
8713	452	3	1254
8714	452	4	1255
8715	452	6	1251
8716	452	7	1250
8717	452	8	1252
8718	421	1	1258
8719	421	2	1257
8720	645	1	1259
8721	645	2	1260
8722	645	3	1261
8723	648	1	1263
8724	648	3	1264
8725	648	4	1262
\.


--
-- Data for Name: queue; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY queue (id, customer_id, status, src_app_id, src_addr, dst_app_id, dst_addr, created, updated, expire, coding, mclass, udh, body, dir, smsc_id, mno_id, cost, ref_id, orig_pdu, prio, reg_dlr) FROM stdin;
5	3	NEW	\N	0777101777	\N	077747772777	2012-07-01 23:48:14+04	2012-07-01 23:48:14+04	2012-07-06 23:48:14+04	0	\N	\N		\N	\N	\N	0.0000	\N	\N	0	0
6	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:19:04+04	2012-07-02 00:19:04+04	2012-07-07 00:19:04+04	0	\N	\N		\N	\N	\N	0.0000	\N	\N	0	0
7	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:20:10+04	2012-07-02 00:20:10+04	2012-07-07 00:20:10+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	0	0
8	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:23:33+04	2012-07-02 00:23:33+04	2012-07-07 00:23:33+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	0	0
9	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:24:15+04	2012-07-02 00:24:15+04	2012-07-07 00:24:15+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	0	0
10	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:24:58+04	2012-07-02 00:24:58+04	2012-07-07 00:24:58+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	0	0
11	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:26:52+04	2012-07-02 00:26:52+04	2012-07-07 00:26:52+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	0	0
12	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:33:02+04	2012-07-02 00:33:02+04	2012-07-07 00:33:02+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	0	0
13	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:46:22+04	2012-07-02 00:46:22+04	2012-07-07 00:46:22+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	0	0
14	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:47:10+04	2012-07-02 00:47:10+04	2012-07-07 00:47:10+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	0	1
15	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:47:37+04	2012-07-02 00:47:37+04	2012-07-07 00:47:37+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	0	1
16	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:48:07+04	2012-07-02 00:48:07+04	2012-07-07 00:48:07+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	0	1
17	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:48:24+04	2012-07-02 00:48:24+04	2012-07-07 00:48:24+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	2	1
18	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:50:37+04	2012-07-02 00:50:37+04	2012-07-07 00:50:37+04	0	\N	\N	Hello	MT	\N	\N	0.0000	\N	\N	2	1
19	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:52:20+04	2012-07-02 00:52:20+04	2012-07-07 00:52:20+04	0	3	\N		MT	\N	\N	0.0000	\N	\N	2	1
20	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:56:04+04	2012-07-02 00:56:04+04	2012-07-07 00:56:04+04	0	\N	\N		MT	\N	\N	0.0000	\N	\N	2	1
21	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 00:56:53+04	2012-07-02 00:56:53+04	2012-07-07 00:56:53+04	2	\N	\N		MT	\N	\N	0.0000	\N	\N	2	1
22	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 01:07:37+04	2012-07-02 01:07:37+04	2012-07-07 01:07:37+04	2	\N	\N	Привет	MT	\N	\N	0.0000	\N	\N	2	1
23	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 01:35:54+04	2012-07-02 01:35:54+04	2012-07-07 01:35:54+04	2	\N	\N	Привет	MT	\N	\N	0.0000	\N	\N	2	1
24	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 01:37:27+04	2012-07-02 01:37:27+04	2012-07-07 01:37:27+04	2	\N	\N	Привет	MT	\N	\N	0.0000	\N	\N	2	1
25	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 01:38:14+04	2012-07-02 01:38:14+04	2012-07-07 01:38:14+04	2	\N	\N	Привет	MT	\N	\N	0.0000	\N	\N	2	1
26	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 01:39:12+04	2012-07-02 01:39:12+04	2012-07-07 01:39:12+04	2	\N	\N	Привет	MT	\N	\N	0.0000	\N	\N	2	1
27	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 01:39:33+04	2012-07-02 01:39:33+04	2012-07-07 01:39:33+04	2	\N	\N	Привет	MT	\N	\N	0.0000	\N	\N	2	1
28	3	PROCESSING	1	0777101777	2	077747772777	2012-07-02 02:13:56+04	2012-07-02 02:13:56+04	2012-07-07 02:13:56+04	2	\N	\N	Привет	MT	\N	\N	0.0000	\N	\N	2	1
3	3	PROCESSING	1	Test	2	380672206770	2012-06-29 10:53:43+04	2012-06-29 10:53:43+04	2012-07-04 10:53:43+04	0	\N	\N	Hello	MO	1	1	0.0100	0	\r	0	0
\.


--
-- Data for Name: rates; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY rates (id, mno_id, price) FROM stdin;
\.


--
-- Data for Name: rules; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY rules (id, mno_id, smsc_id) FROM stdin;
\.


--
-- Data for Name: smsc; Type: TABLE DATA; Schema: stream; Owner: misha
--

COPY smsc (id, name, active, descr, bandwidth) FROM stdin;
\.


--
-- Name: apps_name_key; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY apps
    ADD CONSTRAINT apps_name_key UNIQUE (name);


--
-- Name: apps_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (id);


--
-- Name: campaigns_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);


--
-- Name: countries_name_key; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_name_key UNIQUE (name);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: customers_login_key; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_login_key UNIQUE (login);


--
-- Name: customers_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: directions_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY directions
    ADD CONSTRAINT directions_pkey PRIMARY KEY (id);


--
-- Name: hlr_cache_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY hlr_cache
    ADD CONSTRAINT hlr_cache_pkey PRIMARY KEY (id);


--
-- Name: managers_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY managers
    ADD CONSTRAINT managers_pkey PRIMARY KEY (id);


--
-- Name: mno_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY mno
    ADD CONSTRAINT mno_pkey PRIMARY KEY (id);


--
-- Name: networks_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY networks
    ADD CONSTRAINT networks_pkey PRIMARY KEY (id);


--
-- Name: queue_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY queue
    ADD CONSTRAINT queue_pkey PRIMARY KEY (id);


--
-- Name: rates_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY rates
    ADD CONSTRAINT rates_pkey PRIMARY KEY (id);


--
-- Name: rules_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY rules
    ADD CONSTRAINT rules_pkey PRIMARY KEY (id);


--
-- Name: smsc_name_key; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY smsc
    ADD CONSTRAINT smsc_name_key UNIQUE (name);


--
-- Name: smsc_pkey; Type: CONSTRAINT; Schema: stream; Owner: misha; Tablespace: 
--

ALTER TABLE ONLY smsc
    ADD CONSTRAINT smsc_pkey PRIMARY KEY (id);


--
-- Name: customers_manager_id_fkey; Type: FK CONSTRAINT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_manager_id_fkey FOREIGN KEY (manager_id) REFERENCES managers(id);


--
-- Name: mno_country_id_fkey; Type: FK CONSTRAINT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY mno
    ADD CONSTRAINT mno_country_id_fkey FOREIGN KEY (country_id) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: queue_customer_id_fkey; Type: FK CONSTRAINT; Schema: stream; Owner: misha
--

ALTER TABLE ONLY queue
    ADD CONSTRAINT queue_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES customers(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

