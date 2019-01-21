--users

CREATE TABLE users (
username VARCHAR(100) NOT NULL,
password VARCHAR(100) NOT NULL,
name VARCHAR(100) NOT NULL,
CONSTRAINT pk_users_username PRIMARY KEY (username)
);

--individuals

CREATE TABLE individuals (
username VARCHAR(100) NOT NULL,
job_title VARCHAR(100) NOT NULL,
hire_date DATE NOT NULL,
CONSTRAINT pk_individuals_username PRIMARY KEY (username),
CONSTRAINT fk_individuals_username FOREIGN KEY (username)
REFERENCES users (username)
);

--municipalities

CREATE TABLE municipalities (
username VARCHAR(100) NOT NULL,
category VARCHAR(100) NOT NULL,
CONSTRAINT pk_municipalities_username PRIMARY KEY (username),
CONSTRAINT fk_municipalities_username FOREIGN KEY (username)
REFERENCES `users` (username)
);

--government_agencies

CREATE TABLE government_agencies (
username VARCHAR(100) NOT NULL,
agency_name_local_office VARCHAR(100) NOT NULL,
CONSTRAINT pk_government_agencies_username PRIMARY KEY (username),
CONSTRAINT fk_government_agencies_username FOREIGN KEY (username)
REFERENCES `users` (username)
);

--companies

CREATE TABLE companies (
username VARCHAR(100) NOT NULL,
hq_location VARCHAR(100) NOT NULL,
num_employees INT NOT NULL,
CONSTRAINT pk_companies_username PRIMARY KEY (username),
CONSTRAINT fk_companies_username FOREIGN KEY (username)
REFERENCES `users` (username)
);

--cost_pers

CREATE TABLE cost_pers (
cost_per VARCHAR(100) NOT NULL,
CONSTRAINT pk_cost_pers_cost_per PRIMARY KEY (cost_per)
);

--esfs

CREATE TABLE esfs (
esf_id INT NOT NULL,
description VARCHAR(100) NOT NULL,
CONSTRAINT pk_esfs_esf_id PRIMARY KEY (esf_id)
);

--resources

CREATE TABLE resources (
resource_id INT NOT NULL AUTO_INCREMENT,
owner VARCHAR(100) NOT NULL,
name VARCHAR(100) NOT NULL,
availability_status VARCHAR(100) NOT NULL DEFAULT 'Available',
latitude DECIMAL(8,6) NOT NULL,
longitude DECIMAL(9,6) NOT NULL,
model VARCHAR(250) DEFAULT NULL,
cost DECIMAL(10,2) NOT NULL,
cost_per VARCHAR(100) NOT NULL,
maximum_distance DECIMAL(10,2) DEFAULT NULL,
primary_esf_id INT NOT NULL,
CONSTRAINT ck_resources_status CHECK (availability_status IN ('Available', 'In Use')),
CONSTRAINT pk_resources_resource_id PRIMARY KEY (resource_id),
CONSTRAINT fk_resources_primary_esf FOREIGN KEY (primary_esf_id)
REFERENCES esfs (esf_id),
CONSTRAINT fk_resources_cost_per FOREIGN KEY (cost_per)
REFERENCES cost_pers (cost_per),
CONSTRAINT fk_resources_username FOREIGN KEY (owner)
        REFERENCES users (username)
);

--resource_secondary_esfs

CREATE TABLE resource_secondary_esfs (
resource_id INT NOT NULL,
esf_id INT NOT NULL,
CONSTRAINT pk_resource_secondary_esfs_resource_id_esf_id PRIMARY KEY (resource_id, esf_id),
CONSTRAINT fk_resource_secondary_esfs_esf_id FOREIGN KEY (esf_id)
REFERENCES esfs (esf_id),
CONSTRAINT fk_resource_secondary_esfs_resource_id FOREIGN KEY (resource_id)
        REFERENCES resources (resource_id)
);

--resource_capabilities

CREATE TABLE resource_capabilities(
resource_id INT NOT NULL,
capability VARCHAR(100) NOT NULL,
CONSTRAINT pk_resource_capabilities_resource_id_capability PRIMARY KEY (resource_id , capability ),
CONSTRAINT fk_resource_capabilities_resource_id FOREIGN KEY (resource_id)
        REFERENCES resources (resource_id)
);

--incident_types

CREATE TABLE incident_types (
abbreviation VARCHAR(100) NOT NULL,
description VARCHAR(100) NOT NULL,
CONSTRAINT pk_incident_types_abbreviation PRIMARY KEY (abbreviation)
);

--incidents

CREATE TABLE incidents (
abbreviation VARCHAR(100) NOT NULL,
incident_id INT NOT NULL,
owner VARCHAR(100) NOT NULL,
incident_date DATE NOT NULL,
description VARCHAR(100) NOT NULL,
latitude DECIMAL(8,6) NOT NULL,
longitude DECIMAL(9,6) NOT NULL,
CONSTRAINT pk_incidents_abbreviation_incident_id PRIMARY KEY (abbreviation, incident_id),
CONSTRAINT fk_incidents_abbreviation FOREIGN KEY (abbreviation)
        REFERENCES incident_types (abbreviation),
CONSTRAINT fk_incidents_owner FOREIGN KEY (owner)
        REFERENCES users (username)
);

--resource_requests

CREATE TABLE resource_requests(
request_id INT NOT NULL AUTO_INCREMENT,
resource_id INT NOT NULL,
abbreviation varchar(100) NOT NULL,
incident_id INT NOT NULL,
requested_start_date DATE NOT NULL,
expected_return_date DATE NOT NULL,
request_accepted_deploy_date DATE DEFAULT NULL,
request_status VARCHAR(100) NOT NULL DEFAULT  'Pending',
PRIMARY KEY pk_resource_requests_request_id (request_id),
CONSTRAINT ck_resource_requests_start_return_date CHECK (requested_start_date <= expected_return_date),
CONSTRAINT ck_resource_requests_request_status CHECK (request_status IN ('Pending', 'Deployed', 'Rejected', 'Canceled', 'Completed')),
CONSTRAINT fk_resource_requests_resource_id FOREIGN KEY (resource_id)
        REFERENCES resources (resource_id),
CONSTRAINT fk_resource_requests_abbreviation_incident_id FOREIGN KEY (abbreviation, incident_id)
        REFERENCES incidents (abbreviation, incident_id)
);

--Trigger To Ensure Subtypes Don't Have the Same Username

--companies

DELIMITER |
create trigger companies_check_distinct_usernames
        before insert on companies
for each row
BEGIN
        if new.username in
                (select username from government_agencies union select username from municipalities union select username from individuals)
        THEN SIGNAL SQLSTATE '45000' set MESSAGE_TEXT = 'Username already exists in another subclass of the user superclass'; END IF;
END |
DELIMITER;

--government_agencies

DELIMITER |
create trigger government_agencies_check_distinct_usernames
        before insert on government_agencies
for each row
BEGIN
        if new.username in
                (select username from companies union select username from municipalities union select username from individuals)
        THEN SIGNAL SQLSTATE '45000' set MESSAGE_TEXT = 'Username already exists in another subclass of the user superclass'; END IF;
END |
DELIMITER;

--individuals

DELIMITER |
create trigger individuals_check_distinct_usernames
        before insert on individuals
for each row
BEGIN
        if new.username in
                (select username from government_agencies union select username from companies union select username from municipalities)
        THEN SIGNAL SQLSTATE '45000' set MESSAGE_TEXT = 'Username already exists in another subclass of the user superclass'; END IF;
END |
DELIMITER;

--municipalities

DELIMITER |
create trigger municipalities_check_distinct_usernames
        before insert on municipalities
for each row
BEGIN
        if new.username in
                (select username from government_agencies union select username from companies union select username from individuals)
        THEN SIGNAL SQLSTATE '45000' set MESSAGE_TEXT = 'Username already exists in another subclass of the user superclass'; END IF;
END |
DELIMITER;