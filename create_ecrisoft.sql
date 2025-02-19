-- DROP it like it's hot
/*
DROP SEQUENCE seq_personnesmorales;
DROP SEQUENCE seq_mandats;
DROP SEQUENCE seq_qualifications;
DROP SEQUENCE seq_collaborateurs;

DROP TABLE realisations;
DROP TABLE mandats;
DROP TABLE collaborateurs;
DROP TABLE personnesmorales;
DROP TABLE qualifications;

DROP TRIGGER tri_modif_mandat;
*/

-- sequences
CREATE SEQUENCE seq_personnesmorales;
CREATE SEQUENCE seq_mandats;
CREATE SEQUENCE seq_qualifications;
CREATE SEQUENCE seq_collaborateurs;

-- tables sans FK
CREATE TABLE personnesmorales(
	numero NUMBER(10) DEFAULT seq_personnesmorales.Nextval
		CONSTRAINT pk_personnesmorales PRIMARY KEY,
	raisonsociale VARCHAR2(30) CONSTRAINT nn_pm_raisonsociale NOT NULL,
	ruenumero VARCHAR2(50) CONSTRAINT nn_pm_ruenumero NOT NULL,
	codepostal VARCHAR2(4) CONSTRAINT nn_pm_codepostal NOT NULL,
	localite VARCHAR2(100) CONSTRAINT nn_pm_localite NOT NULL
	);

CREATE TABLE qualifications(
	numero NUMBER(10) DEFAULT seq_qualifications.Nextval
		CONSTRAINT pk_qualifications PRIMARY KEY,
	ordre NUMBER (3) CONSTRAINT nn_qual_ordre NOT NULL,
	libelle VARCHAR2(20) CONSTRAINT nn_qual_libelle NOT NULL,
	tarifhoraire NUMBER(3) CONSTRAINT nn_qual_tarifhoraire NOT NULL,
	CONSTRAINT uk_qual_ordre UNIQUE (ordre),
	CONSTRAINT ch_qual_tarifhoraire CHECK (tarifhoraire > 0)
	);
	
CREATE TABLE collaborateurs (
    numero NUMBER(10) DEFAULT seq_collaborateurs.NEXTVAL 
        CONSTRAINT pk_collaborateurs PRIMARY KEY,
    mnemo VARCHAR2(4) CONSTRAINT nn_collaborateurs_mnemo NOT NULL,
		CONSTRAINT uk_collaborateurs_mnemo UNIQUE (mnemo),
    nom VARCHAR2(40) CONSTRAINT nn_collaborateurs_nom NOT NULL,
    prenom VARCHAR2(20) CONSTRAINT nn_collaborateurs_prenom NOT NULL,
	qual_concerner_numero NUMBER(10) CONSTRAINT nn_collaborateurs_qual_concerner_numero NOT NULL	);

CREATE TABLE realisations ( 
	mand_numero Number(10), 
	col_numero Number(10),
	nbHeures NUMBER(5) DEFAULT 0 CONSTRAINT nn_real_nbheures NOT NULL,
	CONSTRAINT ch_real_nbHeures CHECK (nbHeures > 0),
	CONSTRAINT pk_realisations PRIMARY KEY (mand_numero, col_numero)
	);
	
CREATE TABLE mandats(
    numero NUMBER(10) DEFAULT seq_mandats.NEXTVAL CONSTRAINT pk_mandat PRIMARY KEY,
    pm_client_numero NUMBER(10) CONSTRAINT nn_mandat_clientNum NOT NULL,
    col_mandCom_numero NUMBER(10) CONSTRAINT nn_mandatComNum NOT NULL,
    col_chefProjet_numero NUMBER(10) CONSTRAINT nn_chefProNUM NOT NULL,
    reference VARCHAR2(10) CONSTRAINT nn_mandat_ref NOT NULL,
    description VARCHAR2(30),
    dateSignature DATE CONSTRAINT nn_mandat_dateSign NOT NULL,
    dateDebut DATE CONSTRAINT nn_mandat_dateDebut NOT NULL,
    dateFinPrevue DATE CONSTRAINT nn_mandat_dateFinPrev NOT NULL,
    dateFinReelle DATE,
    nbHeuresChefProjet NUMBER(5) DEFAULT 0 CONSTRAINT nn_mandat_nbHChefPro NOT NULL,
    nbHeuresMandCom NUMBER(5) DEFAULT 0,
    CONSTRAINT uk_mandat_reference UNIQUE (reference),
	CONSTRAINT ch_mandat_nbHChefPro CHECK(nbHeuresChefProjet>=0),
	CONSTRAINT ch_mandat_nbHMandCom CHECK(nbHeuresMandCom>=0)
    );
   
-- contraintes FK

ALTER TABLE Realisations
	ADD (CONSTRAINT fk1_mand_numero
			FOREIGN KEY (mand_numero) REFERENCES Mandats,
        CONSTRAINT fk2_col_numero
			FOREIGN KEY (col_numero) REFERENCES Collaborateurs
	);

ALTER TABLE collaborateurs ADD CONSTRAINT fk_collaborateurs_qualifications_posseder 
        FOREIGN KEY(qual_concerner_numero) REFERENCES qualifications;

ALTER TABLE mandats
	ADD (CONSTRAINT fk1_mandats_pm_client FOREIGN KEY (pm_client_numero)
			REFERENCES personnesmorales,
		CONSTRAINT fk2_mandats_col_mandcom FOREIGN KEY (col_mandcom_numero)
			REFERENCES collaborateurs,
		CONSTRAINT fk3_mandats_col_chefprojet FOREIGN KEY (col_chefprojet_numero)
			REFERENCES collaborateurs
		);

-- Triggers

CREATE OR REPLACE TRIGGER tri_modif_mandat
	BEFORE UPDATE ON mandats
	FOR EACH ROW
	WHEN (NEW.pm_client_numero <> OLD.pm_client_numero)
BEGIN
	RAISE_APPLICATION_ERROR(-20001, 'Modification de PM_CLIENT_NUMERO interdite - Contrainte frozen');
END;


-- Indexes



