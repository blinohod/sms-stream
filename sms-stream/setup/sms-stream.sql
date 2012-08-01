CREATE SCHEMA stream;
COMMENT ON SCHEMA stream IS 'SMS Stream - Bulk SMS server';

CREATE TYPE stream.t_msg_status AS ENUM (
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

COMMENT ON TYPE stream.t_msg_status IS 'Message processing status.';


-- ====================================================================================

CREATE TABLE stream.apps (
	id serial NOT NULL,
	name character varying(64), -- mnemonic application name
	descr character varying(512), -- description of application
	CONSTRAINT apps_pkey PRIMARY KEY (id ),
	CONSTRAINT apps_name_key UNIQUE (name )
);

COMMENT ON TABLE stream.apps IS 'Application descriptors for inter-component routing';
COMMENT ON COLUMN stream.apps.name IS 'mnemonic application name';
COMMENT ON COLUMN stream.apps.descr IS 'description of application';

CREATE TABLE stream.smsc (
	id serial NOT NULL,
	name character varying(32) NOT NULL, -- SMSC ID in Kannel
	active boolean NOT NULL DEFAULT true, -- is SMSC available for sending messages
	descr character varying(1024), -- text description of SMSC
	bandwidth integer NOT NULL DEFAULT 100, -- allowed bandwidth on SMSC in SM/sec
	CONSTRAINT smsc_pkey PRIMARY KEY (id ),
	CONSTRAINT smsc_name_key UNIQUE (name )
);

COMMENT ON TABLE stream.smsc IS 'SMSC connections';
COMMENT ON COLUMN stream.smsc.name IS 'SMSC ID in Kannel';
COMMENT ON COLUMN stream.smsc.active IS 'is SMSC available for sending messages';
COMMENT ON COLUMN stream.smsc.descr IS 'text description of SMSC';
COMMENT ON COLUMN stream.smsc.bandwidth IS 'allowed bandwidth on SMSC in SM/sec';

-- ====================================================================================

CREATE TABLE stream.countries (
	id serial NOT NULL,
	name character varying(128), -- country name
	CONSTRAINT countries_pkey PRIMARY KEY (id ),
	CONSTRAINT countries_name_key UNIQUE (name )
);

COMMENT ON TABLE stream.countries IS 'Countries';
COMMENT ON COLUMN stream.countries.name IS 'country name';

CREATE TABLE stream.mno (
	id serial NOT NULL,
	name character varying(256),
	country_id integer,
	CONSTRAINT mno_pkey PRIMARY KEY (id ),
	CONSTRAINT mno_country_id_fkey FOREIGN KEY (country_id)
	REFERENCES stream.countries (id) MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE stream.mno IS 'Mobile network operators';

CREATE TABLE stream.directions (
	id serial NOT NULL,
	prefix character varying(12), -- Prefix of target MSISDN
	mno_id integer, -- identifier of target MNO
	use_hlr boolean NOT NULL DEFAULT true, -- is HLR lookup needed for this direction
	CONSTRAINT directions_pkey PRIMARY KEY (id )
);

COMMENT ON TABLE stream.directions IS 'Prefix based directions';
COMMENT ON COLUMN stream.directions.prefix IS 'Prefix of target MSISDN';
COMMENT ON COLUMN stream.directions.mno_id IS 'identifier of target MNO';
COMMENT ON COLUMN stream.directions.use_hlr IS 'is HLR lookup needed for this direction';

CREATE INDEX directions_prefix_idx ON stream.directions (prefix );

CREATE TABLE stream.networks (
	id serial NOT NULL,
	mcc integer NOT NULL, -- Mobile Country Code
	mnc integer NOT NULL, -- Mobile Network Code
	mno_id integer, -- mobile carrier ID
	CONSTRAINT networks_pkey PRIMARY KEY (id ),
	CONSTRAINT networks_mcc_key UNIQUE (mcc , mnc ),
	CONSTRAINT networks_mcc_key1 UNIQUE (mcc )
);

COMMENT ON TABLE stream.networks IS 'Mobile networks';
COMMENT ON COLUMN stream.networks.mcc IS 'Mobile Country Code';
COMMENT ON COLUMN stream.networks.mnc IS 'Mobile Network Code';
COMMENT ON COLUMN stream.networks.mno_id IS 'mobile carrier ID';

CREATE TABLE stream.rules (
	id serial NOT NULL,
	mno_id integer,
	smsc_id integer,
	CONSTRAINT rules_pkey PRIMARY KEY (id ),
	CONSTRAINT rules_mno_id_fkey FOREIGN KEY (mno_id)
	REFERENCES stream.mno (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
	CONSTRAINT rules_smsc_id_fkey FOREIGN KEY (smsc_id)
	REFERENCES stream.smsc (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);

COMMENT ON TABLE stream.rules IS 'Processing rules - routing, etc';

CREATE TABLE stream.hlr_cache (
	id bigserial NOT NULL,
	msisdn character varying(16) NOT NULL, -- subscriber's phone number
	updated timestamp(0) with time zone NOT NULL DEFAULT now(), -- last update time for MSISDN
	expire timestamp(0) with time zone NOT NULL DEFAULT (now() + '1 mon'::interval), -- record expiration time
	mno_id integer, -- MNO identifier
	valid boolean NOT NULL DEFAULT true,
	mcc integer,
	mnc integer,
	imsi character varying(32),
	CONSTRAINT hlr_cache_pkey PRIMARY KEY (id ),
	CONSTRAINT hlr_cache_msisdn_key UNIQUE (msisdn )
);

COMMENT ON TABLE stream.hlr_cache IS 'HLR lookup cache';
COMMENT ON COLUMN stream.hlr_cache.msisdn IS 'subscriber''s phone number';
COMMENT ON COLUMN stream.hlr_cache.updated IS 'last update time for MSISDN';
COMMENT ON COLUMN stream.hlr_cache.expire IS 'record expiration time';
COMMENT ON COLUMN stream.hlr_cache.mno_id IS 'MNO identifier';

CREATE UNIQUE INDEX hlr_cache_msisdn_idx ON stream.hlr_cache (msisdn );

CREATE TABLE stream.managers (
	id serial NOT NULL,
	login character varying(64),
	password character varying(64),
	CONSTRAINT managers_pkey PRIMARY KEY (id )
);

COMMENT ON TABLE stream.managers IS 'Service managers';

CREATE TABLE stream.customers (
	id serial NOT NULL,
	manager_id integer NOT NULL, -- manager responsible for this customer
	name character varying(512), -- customer name (text description)
	login character varying(32) NOT NULL, -- customer login (system-id)
	password character varying(64), -- password
	active boolean NOT NULL DEFAULT true,
	bandwidth integer NOT NULL DEFAULT 10, -- outgoing bandwidth for customer (SM/sec)
	allowed_ip character varying(512) NOT NULL DEFAULT ''::character varying,
	CONSTRAINT customers_pkey PRIMARY KEY (id ),
	CONSTRAINT customers_manager_id_fkey FOREIGN KEY (manager_id)
	REFERENCES stream.managers (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION,
	CONSTRAINT customers_login_key UNIQUE (login )
);

COMMENT ON TABLE stream.customers IS 'Customer accounts';
COMMENT ON COLUMN stream.customers.manager_id IS 'manager responsible for this customer';
COMMENT ON COLUMN stream.customers.name IS 'customer name (text description)';
COMMENT ON COLUMN stream.customers.login IS 'customer login (system-id)';
COMMENT ON COLUMN stream.customers.password IS 'password';
COMMENT ON COLUMN stream.customers.bandwidth IS 'outgoing bandwidth for customer (SM/sec)';

CREATE INDEX customers_login_idx ON stream.customers (login );


CREATE TABLE stream.rates (
	id serial NOT NULL,
	mno_id integer, -- mobile operator
	price numeric(10,4), -- cost of message in unified currency
	customer_id integer, -- customer for customer specific rates
	CONSTRAINT rates_pkey PRIMARY KEY (id )
);

COMMENT ON TABLE stream.rates IS 'Rates for target MNO';
COMMENT ON COLUMN stream.rates.mno_id IS 'mobile operator';
COMMENT ON COLUMN stream.rates.price IS 'cost of message in unified currency';
COMMENT ON COLUMN stream.rates.customer_id IS 'customer for customer specific rates';

CREATE TABLE stream.campaigns (
	id bigserial NOT NULL,
	customer_id integer,
	created timestamp(0) with time zone DEFAULT now(),
	updated timestamp(0) with time zone,
	status character varying(32) NOT NULL DEFAULT 'NEW'::character varying,
	send_time timestamp(0) with time zone,
	bandwidth integer DEFAULT 0,
	mclass smallint,
	coding smallint NOT NULL DEFAULT 0,
	body character varying(1024) NOT NULL DEFAULT ''::character varying,
	CONSTRAINT campaigns_pkey PRIMARY KEY (id )
);

COMMENT ON TABLE stream.campaigns IS 'Bulk campaigns';


CREATE OR REPLACE FUNCTION stream.update_msg_timestamp() RETURNS trigger AS $$
declare
begin
	NEW.updated := now();
	return NEW;
end;
$$ LANGUAGE plpgsql;

CREATE TABLE stream.queue (
	id bigserial NOT NULL,
	customer_id integer NOT NULL, -- customer that sent message
	status stream.t_msg_status NOT NULL DEFAULT 'NEW'::stream.t_msg_status, -- current message status
	src_app_id integer, -- originating application
	src_addr character varying(32), -- source address
	dst_app_id integer, -- destination application
	dst_addr character varying(32), -- destination address
	created timestamp(0) with time zone NOT NULL DEFAULT now(), -- when message was created
	updated timestamp(0) with time zone NOT NULL DEFAULT now(), -- when message was updated last time
	expire timestamp(0) with time zone NOT NULL DEFAULT (now() + '5 days'::interval),
	coding smallint NOT NULL DEFAULT 0,
	mclass smallint,
	udh character varying(280),
	body character varying(280) NOT NULL DEFAULT ''::character varying,
	dir character varying(3),
	smsc_id integer,
	mno_id integer,
	cost numeric(10,4) NOT NULL DEFAULT 0,
	ref_id bigint,
	orig_pdu text,
	prio smallint NOT NULL DEFAULT 0,
	reg_dlr smallint NOT NULL DEFAULT 0,
	CONSTRAINT queue_pkey PRIMARY KEY (id ),
	CONSTRAINT queue_customer_id_fkey FOREIGN KEY (customer_id)
	REFERENCES stream.customers (id) MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION
);

COMMENT ON TABLE stream.queue IS 'Message queue';
COMMENT ON COLUMN stream.queue.customer_id IS 'customer that sent message';
COMMENT ON COLUMN stream.queue.status IS 'current message status';
COMMENT ON COLUMN stream.queue.src_app_id IS 'originating application';
COMMENT ON COLUMN stream.queue.src_addr IS 'source address';
COMMENT ON COLUMN stream.queue.dst_app_id IS 'destination application';
COMMENT ON COLUMN stream.queue.dst_addr IS 'destination address';
COMMENT ON COLUMN stream.queue.created IS 'when message was created';
COMMENT ON COLUMN stream.queue.updated IS 'when message was updated last time';

CREATE INDEX queue_customer_id_idx ON stream.queue (customer_id );
CREATE INDEX queue_smsc_id_idx ON stream.queue (smsc_id );
CREATE INDEX queue_status_idx ON stream.queue (status );

CREATE TRIGGER trg_queue_updated BEFORE INSERT OR UPDATE ON stream.queue FOR EACH ROW
	EXECUTE PROCEDURE stream.update_msg_timestamp();
COMMENT ON TRIGGER trg_queue_updated ON stream.queue IS 'Update timestamp on message when changed';




CREATE OR REPLACE FUNCTION stream.mno_by_mccmnc(mcc integer, mnc integer) RETURNS integer AS
	'select mno_id from stream.networks where (mcc=$1 and mnc=$2) or (mcc=0 and mnc=0) order by mno_id desc limit 1'
LANGUAGE sql;

COMMENT ON FUNCTION stream.mno_by_mccmnc(integer, integer) IS 'Lookup MNO ID by MCC and MNC pair. In case of MNO is not found returns 0 (unknown MNO).';

