-- IF expression THEN
--                 instructions
-- ELSE
--                 instructions
-- END IF
-- EXEMPLE 1 
DELIMITER $$
CREATE OR REPLACE PROCEDURE IF NOT EXISTS `soidePrix`(IN des varchar(20), OUT psolde int)
OPTIONS (strict_mode = TRUE)
BEGIN
    DECLARE p int ;
    SET p = (SELECT
        prix
    FROM `article`
    WHERE
        designation = des);
    IF(p > 2000) THEN 
        SET psolde = p - p * 0.1;
    ELSE
        SET psolde = p;
    END IF;
END$$
DELIMITER ;
-- lllllllllllllllllllllllllllllllllllllllllllllllllll
-- Autre Structure Alternative : case .........When
-- CASE expression
-- WHEN valeurs THEN 
--              instructions
-- [WHEN valeurs THEN
--                instructions]
-- [ELSE
--                instructions]
-- Exemple1:
SELECT
    refart, designation, qtiteStock,
    CASE 
        WHEN qtiteStock < 10 THEN "Rupture stock"
        WHEN qtiteStock = 10 THEN "quantité en stock faible"
        ELSE "quantité suffisante"
    END as "observation"
FROM article;
-- Exemple2:
DELIMITER $$
CREATE PROCEDURE v_note(IN note int, OUT mention varchar(20))
BEGIN
    CASE
        WHEN note >= 16 THEN
            SET mention = 'Félicitation';
        WHEN note >= 14 THEN
            SET mention = 'Encouragement';
        WHEN note >= 12 THEN
            SET mention = 'Assez bien';
        WHEN note >= 10 THEN
            SET mention = 'Passable';
        ELSE
            SET mention = 'Insuffisant';
    END CASE;
END$$
DELIMITER ;
-- lllllllllllllllllllllllllllllllllllllllllllllllllll
-- Structure Répétitive :
-- Syntaxe :
--      WHILE expression DO 
--          instructions
--      END WHILE condition;
-- Exemple1
-- Ecrire une Ps qui calcule le factoriel d'un nombre donné: /* Ecrire une ps qui calcule le factoriel d'un nombre */ drop procedure if exists facte-iel
DELIMITER $$
CREATE PROCEDURE factoriel(IN n int, OUT fac int)
BEGIN
    DECLARE i int;
    SET i = 1;
    SET fac = 1;
    WHILE i <= n DO
        SET fac = fac * i;
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;
-- lllllllllllllllllllllllllllllllllllllllllllllllllll
-- [labele_debut:]LOOP
--     statement_list
-- END LOOP[label_fin]
-- Exemple1
--  Ecrire une PS qui remplit une table par des nombres et leurs carrés inférieur ou égale à 10 et create table test( a int, b int)
DELIMITER $$
CREATE PROCEDURE test()
BEGIN
    DECLARE i int DEFAULT 1;
    Maboucle: LOOP
        INSERT INTO test VALUES (i, i * i);
        SET i = i + 1;
        IF(i > 10) THEN
            LEAVE Maboucle;
        END IF;
    END LOOP Maboucle;
END$$
DELIMITER ;




    
------------------------------------------------------------------------------------------------------------------    
-- L'aéroport international de Casablanca est un des aéroports les plus importants actuellement. Il souhaite informatiser la gestion des vols. L'étude de l'existant a permis d'élaborer le schéma relationnel suivant :
-- Pilote(N°pilote ,nom-pilote, Prénom-pilote,DateNaissance localisation)
-- Vol (N°vol,N°pilote,N°avion,datdépart,datarrivée,villedépart, villearrivée,durée,tarif) 
-- Passagers (N°passager, Nom-passager, adresse, téléphone,type)
-- Avion (N°avion,marque, capacité,etat) 
-- Réservation (N°passager, N°vol,montApayer)
-- Remarque:
-- Le champ "type" prend la valeur "adulte" ou "enfant"
-- Le champ "etat" de la table avion prend la valeur "en vol" ou "disponible"
-- Questions:
-- Procédures Stockées
-- Triggers
-- 1. Créer une PS qui permet l'ajout d'un pilote après vérification de son existence.
-- 2. Créer une PS qui permet de donner le nombre de vol d'un pilote donné. 
-- 3. Créer une PS qui permet de donner le nombre de passager d'un vol donné.
-- 4. Créer une PS qui permet l'ajout d'une réservation et qui met à jour le montant de la réservation lors de l'insertion :
-- Si le passager est adulte le montant est égal au tarif défini dans la table vol sinon le montant est la moitié du tarif.
-- 5. Créer une PS qui permet de supprimer les pilotes dont l'âge est supérieur à 50 ans et de les archiver dans une autre table << AncienPilote » qui a la même structure que la table << Pilote >>.
-- 6. Créer une PS qui permet l'ajout d'un vol, le pilote ne doit pas avoir plus de 3 vols dans un mois donné et l'avion doit être disponible.
-- 7. Créer une PS qui permet l'ajout d'un passager, Le N°passager est affecté automatiquement après avoir vérifié que le numéro affecté n'existe pas déjà dans la table passager.
-- 8. Créer un trigger qui permet d'ajouter une réservation d'un vol que si le nombre de passager est inférieur à 200 sinon afficher un message "places complets pour ce vol"
-- 9. Créer un trigger qui interdit l'ajout d'un vol si la date d'arrivée du vol est inférieure à la date de départ.
-- 10. Créer un trigger qui interdit l'ajout d'un vol si l'avion concerné n'est pas disponible
------------------------------------------------------------------------------------------------
-- 1. Créer une PS qui permet l'ajout d'un pilote après vérification de son existence.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `AjoutPilote`(IN p_NumPilote INT, IN p_NomPilote VARCHAR(50), IN p_PrenomPilote VARCHAR(50), IN p_DateNaissance DATE, IN p_Localisation VARCHAR(50))
[OPTIONS (strict_mode = TRUE|FALSE)]
IF NOT EXISTS (SELECT 1 FROM Pilote WHERE N°pilote = p_NumPilote) THEN
        INSERT INTO Pilote (N°pilote, nom-pilote, Prénom-pilote, DateNaissance, localisation)
        VALUES (p_NumPilote, p_NomPilote, p_PrenomPilote, p_DateNaissance, p_Localisation);
    END IF;
END//
DELIMITER ;
-- 2. Créer une PS qui permet de donner le nombre de vol d'un pilote donné. 
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `NombreVolsPilote`(IN p_NumPilote INT, OUT p_NombreVols INT)
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
    SELECT COUNT(*) INTO p_NombreVols FROM Vol WHERE N°pilote = p_NumPilote;
END//
DELIMITER ;
-- 3. Créer une PS qui permet de donner le nombre de passager d'un vol donné.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `NombrePassagersVol`(IN p_NumVol INT, OUT p_NombrePassagers INT)
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
    SELECT COUNT(*) INTO p_NombrePassagers FROM Reservation WHERE N°vol = p_NumVol;
END//
DELIMITER ;
-- 4. Créer une PS qui permet l'ajout d'une réservation et qui met à jour le montant de la réservation lors de l'insertion : Si le passager est adulte le montant est égal au tarif défini dans la table vol sinon le montant est la moitié du tarif.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `AjoutReservation`(IN p_NumPassager INT, IN p_NumVol INT)
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
     DECLARE v_Tarif DOUBLE;
    DECLARE v_Type VARCHAR(10);

    SELECT type, tarif INTO v_Type, v_Tarif FROM Passagers JOIN Vol ON Passagers.N°passager = p_NumPassager AND Vol.N°vol = p_NumVol;

    IF v_Type = 'adulte' THEN
        INSERT INTO Reservation (N°passager, N°vol, montApayer) VALUES (p_NumPassager, p_NumVol, v_Tarif);
    ELSE
        INSERT INTO Reservation (N°passager, N°vol, montApayer) VALUES (p_NumPassager, p_NumVol, v_Tarif * 0.5);
    END IF;
END//
DELIMITER ;
-- 5. Créer une PS qui permet de supprimer les pilotes dont l'âge est supérieur à 50 ans et de les archiver dans une autre table << AncienPilote » qui a la même structure que la table << Pilote >>.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `SupprimerArchiverPilotes`()
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
  INSERT INTO AncienPilote
  SELECT * FROM Pilote
  WHERE DATE_ADD(DateNaissance, INTERVAL 50 YEAR) < CURDATE();

  DELETE FROM Pilote
  WHERE DATE_ADD(DateNaissance, INTERVAL 50 YEAR) < CURDATE();
END//
DELIMITER ;
-- 6. Créer une PS qui permet l'ajout d'un vol, le pilote ne doit pas avoir plus de 3 vols dans un mois donné et l'avion doit être disponible.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `ajout_vol`( IN N°pilote INT, IN N°avion INT, IN datdepart DATETIME, IN datarrivee DATETIME, IN villedépart VARCHAR(50), IN villearrivee VARCHAR(50), IN duree FLOAT, IN tarif FLOAT)
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
    -- Vérifier que le pilote a moins de 3 vols dans le mois du vol à ajouter
    IF (SELECT COUNT(*) FROM Vol 
        WHERE N°pilote = N°pilote
        AND MONTH(datdépart) = MONTH(datdepart)
        AND YEAR(datdépart) = YEAR(datdepart)
    ) >= 3
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le pilote a déjà atteint le nombre maximal de vols pour ce mois.';
        RETURN;
    END IF;
    
    -- Vérifier que l'avion est disponible
    IF (SELECT etat FROM Avion WHERE N°avion = N°avion) <> 'disponible'
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L''avion est déjà utilisé pour un autre vol.';
        RETURN;
    END IF;
    
    -- Ajouter le vol
    INSERT INTO Vol (N°pilote, N°avion, datdépart, datarrivée, villedépart, villearrivée, durée, tarif)
    VALUES (Nopilote, Noavion, datdepart, datarrivee, villedépart, villearrivee, duree, tarif);
    
END//
DELIMITER ;
-- 7. Créer une PS qui permet l'ajout d'un passager, Le N°passager est affecté automatiquement après avoir vérifié que le numéro affecté n'existe pas déjà dans la table passager.
DELIMITER //
CREATE [OR REPLACE] PROCEDURE [IF NOT EXISTS] `AjoutPassager`(IN p_NomPassager VARCHAR(50), IN p_Adresse VARCHAR(100), IN p_Telephone VARCHAR(20), IN p_Type VARCHAR(10))
[OPTIONS (strict_mode = TRUE|FALSE)]
BEGIN
    -- Vérifier si le numéro de passager existe déjà
 DECLARE v_NumPassager INT;
    SELECT MAX(N°passager) + 1 INTO v_NumPassager FROM Passagers;
    -- Ajouter le passager    
    INSERT INTO Passagers (N°passager, Nom-passager, adresse, téléphone, type)
    VALUES (v_NumPassager, p_NomPassager, p_Adresse, p_Telephone, p_Type);

END//
DELIMITER ;
-- 8. Créer un trigger qui permet d'ajouter une réservation d'un vol que si le nombre de passager est inférieur à 200 sinon afficher un message "places complets pour ce vol"
DELIMITER //
CREATE TRIGGER reservation_before_insert
BEFORE INSERT ON Réservation
FOR EACH ROW
BEGIN
    -- Vérifier que le nombre de passagers est inférieur à 200
    DECLARE nb_passagers INT;
    SELECT COUNT(*) INTO nb_passagers FROM Réservation WHERE N°vol = NEW.N°vol;
    IF nb_passagers >= 200 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Places complètes pour ce vol.';
    END IF;

END//
DELIMITER ;
-- 9. Créer un trigger qui interdit l'ajout d'un vol si la date d'arrivée du vol est inférieure à la date de départ.
DELIMITER //
create TRIGGER VerifierDatesVol
BEFORE INSERT ON Vol
FOR EACH ROW 
BEGIN
 -- Vérifier que la date d'arrivée est supérieure ou égale à la date de départ
    IF NEW.datarrivée < NEW.datdépart THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La date d''arrivée doit être supérieure ou égale à la date de départ.';
    END IF;
END //
DELIMITER;
-- 10. Créer un trigger qui interdit l'ajout d'un vol si l'avion concerné n'est pas disponible
DELIMITER //
create TRIGGER VerifierDisponibiliteAvion
BEFORE INSERT ON Vol
FOR EACH ROW 
BEGIN
 -- Vérifier que l'avion est disponible
    IF (SELECT etat FROM Avion WHERE N°avion = NEW.N°avion) <> 'disponible' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L''avion n''est pas disponible.';
    END IF;
END //
DELIMITER;


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    

-- Soit le schéma relationnel de la base << AcciRoute >> : 
-- Personne (NAS, nom, VilleP)
-- Voiture (Imma, modele, annee,NAS*)
-- Accident (DateAc, NAS*, dommage, villeAc, imma* )
-- Questions:
-- 1. Créer la base de données AcciRoute.
-- 2. Créer la procédure CreateAcciRoute qui permet de construire les tables de données AcciRoute en les supprimant s'ils existent avant leur création.
-- 3. Créer la procédure InsertAcciRoute qui permet d'insérer les données dans AcciRoute en vérifiant l'intégrité référentielle.
-- 4. Créer la procédure GetnumProp qui permet de calculer le nombre de propriétaires impliqués dans un accident entre deux années données.
-- 5. Créer la procédure GetProp qui donne le nom et le nas des propriétaires qui ont fait deux accidents dans un intervalle de 4 mois.
-- 6. Créer la procédure GetDamCity qui calcule le total des dommages d'une ville donnée et affiche << catégorie1 » pour dommage<=5000 et «< catégorie2 » pour dommage entre 5000 et 10000 et << catégorie3 » pour dommage >10000.
-- 7. Créer la procédure GetnumAcci qui permet d'afficher pour chaque ville le nombre total d'accidents enregistrés.
-- 8. Créer la procédure GetNamProp qui permet d'afficher le nom des propriétaires qui résident dans une ville où il y a eu plus de x accidents tel que x un paramètre de la procédure.
-- 9. Créer la procédure GetnumAcciDat qui calcule le nombre d'accidents qui sont survenus à une date donnée.
-- 10.Créer la procédure GetnumAcciHour qui calcule le nombre d'accidents survenus entre deux heures données.
-- 11.Créer la procédure UpdateDam qui permet de diminuer de 5% le dommage à chaque véhicule dont les dommages dépassant les 5000.00.
------------------------------------------------------------------------------------------------
-- 1.Créer la base de données AcciRoute.
create database AcciRoute
-- 2. Créer la procédure CreateAcciRoute qui permet de construire les tables de données AcciRoute en les supprimant s'ils existent avant leur création.
DELIMITER $$
CREATE PROCEDURE CreateAcciRoute()
BEGIN
    DROP TABLE [IF EXISTS] Personne
    DROP TABLE [IF EXISTS] voiture
    DROP TABLE [IF EXISTS] Accident

    create table Personne (
        nas varchar(60) PRIMARY KEY,
        nom varchar(60) ,
        VilleP varchar(60) ,
    );
        create table Voiture (
        Imma varchar(60) PRIMARY KEY,
        modele varchar(60) ,
        annee int ,
        nas varchar(60) Foreign key (nas) references Personne (nas) on delete cascade,
    );
    create table Accident (
        DateAc date,
        NAS varchar(60) ,
        dommage varchar(60) ,
        villeAc varchar(60) ,
        imma varchar(60) ,
        Foreign key (nas) references Personne (nas) on delete cascade,
        Foreign key (imma) references Voiture (imma) on delete cascade, 

    );
END$$
DELIMITER ;
-- 3. Créer la procédure InsertAcciRoute qui permet d'insérer les données dans AcciRoute en vérifiant l'intégrité référentielle.
DELIMITER $$
CREATE PROCEDURE InsertAcciRoute ()
BEGIN
INSERT INTO Personne (NAS, nom, VilleP) VALUES
        ('1234567890', 'John Doe', 'VilleA'),
        ('9876543210', 'Jane Smith', 'VilleB');

    -- Insérer les données dans la table Voiture
    INSERT INTO Voiture (Imma, modele, annee, NAS) VALUES
        ('ABC123', 'ModèleA', 2020, '1234567890'),
        ('XYZ987', 'ModèleB', 2018, '9876543210');

    -- Insérer les données dans la table Accident
    INSERT INTO Accident (DateAc, NAS, dommage, villeAc, imma) VALUES
        ('2023-01-01', '1234567890', 2000.00, 'VilleA', 'ABC123'),
        ('2023-02-01', '9876543210', 3000.00, 'VilleB', 'XYZ987');
END$$
DELIMITER;
-- 4. Créer la procédure GetnumProp qui permet de calculer le nombre de propriétaires impliqués dans un accident entre deux années données.
DELIMITER $$
CREATE PROCEDURE GetnumProp(in startyear int, in endyear int,out numProp int) 
BEGIN
    SELECT
        COUNT(DISTINCT nas) into numProp
    FROM accident
    WHERE
        YEAR(DateAc) BETWEEN startyear AND endyear
END$$
DELIMITER;
-- 5. Créer la procédure GetProp qui donne le nom et le nas des propriétaires qui ont fait deux accidents dans un intervalle de 4 mois.
DELIMITER $$
CREATE PROCEDURE GetProp (in startdate date,in enddate date)
BEGIN
    SELECT
        p.nom ,p.nas
    FROM Personne p
    WHERE
        p.nas in (
            SELECT
                a.nas
            FROM Accident a
            WHERE
                a.DateAc BETWEEN startdate AND enddate
                GROUP BY
                    a.nas 
                    HAVING
                        COUNT(*)>=2
        )
END $$
DELIMITER;
-- 6. Créer la procédure GetDamCity qui calcule le total des dommages d'une ville donnée  et affiche << catégorie1 » pour dommage<=5000 et «< catégorie2 » pour dommage entre 5000 et 10000 et << catégorie3 » pour dommage >10000.
DELIMITER $$
CREATE PROCEDURE  GetDamCity(in city varchar(50))
BEGIN
DECLARE totalDommage int;
SELECT
     sum(dommage) as totalDommage
FROM Accident
WHERE villeAc = city
    condition
        IF totalDommage <= 5000 THEN
            SELECT 'catégorie1' AS categorie;
        ELSEIF totalDommage <= 10000 THEN
            SELECT 'catégorie2' AS categorie;
        ELSE
            SELECT 'catégorie3' AS categorie;
        END IF;        
END$$
DELIMITER;

-- 7. Créer la procédure GetnumAcci qui permet d'afficher pour chaque ville le nombre total d'accidents enregistrés.
DELIMITER $$
CREATE PROCEDURE GetnumAcci()
BEGIN
    SELECT villeAc,
        COUNT(*) as numAccidents
FROM Accident
GROUP BY
    villeAc
END$$
DELIMITER;
-- 8. Créer la procédure GetNamProp qui permet d'afficher le nom des propriétaires qui résident dans une ville où il y a eu plus de x accidents tel que x un paramètre de la procédure.
DELIMITER $$
CREATE PROCEDURE GetNamProp(IN numAccidents INT)
BEGIN
SELECT p.nom
    FROM Personne p
    WHERE p.VilleP IN (
        SELECT villeAc
        FROM Accident
        GROUP BY villeAc
        HAVING COUNT(*) > numAccidents
    );
END$$
DELIMITER;
-- 9. Créer la procédure GetnumAcciDat qui calcule le nombre d'accidents qui sont survenus à une date donnée.
DELIMITER $$
CREATE PROCEDURE GetnumAcciDat(IN accidentDate DATE, OUT numAccidents INT)
BEGIN
SELECT
    count(*) into numAccidents
FROM Accident
WHERE
    DateAc = accidentDate;
END$$
DELIMITER;
-- 10.Créer la procédure GetnumAcciHour qui calcule le nombre d'accidents survenus entre deux heures données.
DELIMITER $$
CREATE PROCEDURE GetnumAcciHour(in startheur date, in endheur date, OUT numAccidents INT)
BEGIN
SELECT
    count(*) INTO numAccidents
FROM accident
WHERE
    TIME(DateAc) BETWEEN startheur AND endheur
END$$
DELIMITER;
-- 11.Créer la procédure UpdateDam qui permet de diminuer de 5% le dommage à chaque véhicule dont les dommages dépassant les 5000.00.
DELIMITER //
CREATE PROCEDURE UpdateDam()
BEGIN
    UPDATE Accident
    SET dommage = dommage * 0.95
    WHERE dommage > 5000.00;
END //
DELIMITER ;
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
-- Partie 1: Questions sur les procédures stockées
-- 1) Afficher les différents pays qui ont participé à la coupe mondiale.
-- 2) Afficher la liste des arbitres
-- 3) Afficher les noms des stades qui ont pu accueillir plus de N spectateurs
-- 4) Afficher pour chaque match le nombre de places vacantes dans le stade.
-- 5) Afficher tous les noms des joueurs marocains qui ont participé à la coupe mondiale. 6) Afficher les noms ordonnés des arbitres des matchs joués par une équipe donnée. 7) Afficher les noms des joueurs qui ont marqué au moins N buts d'un type donné.
-- 8) Afficher pour une équipe donnée le nombre de buts marqués.
-- 9) Afficher le nom du joueur marocain qui a marqué le maximum de buts.
-- 10) Ajouter à tout joueur marocain deux buts.
-- Partie 2: Questions sur les fonctions stockées
-- 1) Ecrire une fonction qui prend en paramètre un numéro stade et qui renvoie une chaine de caractère contenant le nom du stade et le nombre de match joués sur ce stade.
-- 2) Ecrire une fonction qui prend en entrée le nom d'un arbitre et produit une chaine contenant les matchs qu'il a arbitré.
-- Partie 3: Questions sur les triggers
-- 1) Lors de l'ajout d'un individu, on met son nom en majuscule ainsi que la première lettre de son prénom.
-- 2) Lors de l'ajout d'un match on vérifie si le nombre de spectateurs est inferieur ou égale au nombre de places disponibles dans le stade. si oui on l'ajoute sinon on affiche un message d'erreur.
-- 3) Lors de l'insertion d'un but on vérifie si la minute est positive.
-- 4) Lors de la suppression d'un joueur, on supprime aussi les buts qu'il a marqués.
-- 5) Interdire de modifier la date d'un match.
-- 6) Lors de la suppression d'une équipe, on supprime les joueurs.
-- 7) Lors de la suppression d'une équipe on supprime les joueurs et les buts.
-- 8) Lors de l'ajout d'une équipe si on essaie d'insérer dans le champ nationalité
--         'fr' alors on la modifie en : France
--         'Mr' alors on la modifie en: Maroc 
--         'Br' alors on la modifie en : Brésil 
--         'Esp' alors on la modifie en Espagne
------------------------------------------------------------------------------------------------------------------------------
-- Partie 1: Questions sur les procédures stockées
-- 1) Afficher les différents pays qui ont participé à la coupe mondiale.
DELIMITER $$
CREATE PROCEDURE AfficherPaysParticipants( )
BEGIN
    SELECT DISTINCT nationalité
    FROM Equipe
END$$
DELIMITER;
-- 2) Afficher la liste des arbitres
DELIMITER $$
CREATE PROCEDURE AfficherArbitres( )
BEGIN
    SELECT
        Nom,Prenom
    FROM individu
    WHERE
        arbitre=1;
END$$
DELIMITER;
-- 3) Afficher les noms des stades qui ont pu accueillir plus de N spectateurs
DELIMITER $$
CREATE PROCEDURE AfficherStadesCapaciteSup(in n int )
BEGIN
    SELECT
        Nom_de_stades,
    FROM stade
    WHERE
    Nb_de_places  > n;
END$$
DELIMITER;
-- 4) Afficher pour chaque match le nombre de places vacantes dans le stade.
DELIMITER $$
CREATE PROCEDURE AfficherPlacesVacantes( )
BEGIN
    SELECT
        MATCH.Id_de_match, STADE.Nb_de_places -MATCH.Nb_de_spectateurs AS Places_vacantes
    FROM MATCH
        JOIN STADE ON MATCH.jouer_dans = STADE.Code_de_Stade;
END$$
DELIMITER;
-- 5) Afficher tous les noms des joueurs marocains qui ont participé à la coupe mondiale. 
DELIMITER $$
CREATE PROCEDURE AfficherJoueursMarocains( )
BEGIN
    SELECT
        nom, Prenom
    FROM INDIVIDU 
    WHERE
        nationalité='marocain' AND Jouer = 1;
END$$
DELIMITER;
-- 6) Afficher les noms ordonnés des arbitres des matchs joués par une équipe donnée. 
DELIMITER $$
CREATE PROCEDURE AfficherArbitresEquipaDonnee(in codeEquipe varchar(10))
BEGIN
SELECT
    individu.nom,individu.Prenom
FROM individu
JOIN match on individu.No_individu = match.arbitrer
WHERE
    Match.jouer_dans=codeEquipe
    ORDER BY
        INDIVIDU.nom,INDIVIDU.Prenom
END$$
DELIMITER;
-- 7) Afficher les noms des joueurs qui ont marqué au moins N buts d'un type donné.
DELIMITER $$
CREATE PROCEDURE AfficherJoueurbutstypeDonne(in N int,typeBut varchar(39) )
BEGIN
    SELECT
        individu.nom, individu.Prenom
    FROM individu
    JOIN but on individu.No_individu=but.marquer
    WHERE
        but.type_de_But=typeBut
        GROUP BY
            individu.No_individu,INDIVIDU.nom ,INDIVIDU.Prenom
        HAVING count(*)>=N
END$$
DELIMITER;
-- 8) Afficher pour une équipe donnée le nombre de buts marqués.
DELIMITER $$
CREATE PROCEDURE AfficherButsEquipeDonnee(codeEquipe varchar(20))
BEGIN
    SELECT
    count(*)  as buts_marqués
    FROM but
    JOIN Match on but.but =MATCH.Id_de_match
    WHERE
        Match.jouer_dans=codeEquiped;
END$$
DELIMITER;
-- 9) Afficher le nom du joueur marocain qui a marqué le maximum de buts.
DELIMITER $$
CREATE PROCEDURE AfficherJoueursMarocainsplusbuts( )
BEGIN
SELECT
    Nom,Prenom
FROM INDIVIDU
JOIN But on INDIVIDU.No_individu = BUT.Marquer
WHERE
    nationalité="maroc"
    ORDER BY
        count(*) DESC limit 1 ;
END$$
DELIMITER;
--10) Ajouter à tout joueur marocain deux buts :
DELIMITER $$
CREATE PROCEDURE ajoutbutsjoueursmarocains( )
BEGIN
UPDATE but
JOIN individu on but.marque=individu.No_individu
SET but.but=but.but+2
WHERE INDIVIDU.Nationalité = 'Maroc';
END$$
DELIMITER;
-- Partie 2: Questions sur les fonctions stockées   (MA3RAFTCH LIHOOOOOM)
-- 1) Ecrire une fonction qui prend en paramètre un numéro stade et qui renvoie une chaine de caractère contenant le nom du stade et le nombre de match joués sur ce stade.
DELIMITER $$
CREATE FUNCTION  GetStadiumInfo(stadiumId  int)
RETURNS varchar(20)
BEGIN
    DECLARE stadiumName VARCHAR(255);
    DECLARE matchCount INT;

    SELECT nom_stade, COUNT(*) INTO stadiumName, matchCount
    FROM CoupeDuMonde.STADE
    JOIN CoupeDuMonde.MATCH ON CoupeDuMonde.STADE.code_stade = CoupeDuMonde.MATCH.jouer_dans
    WHERE CoupeDuMonde.STADE.code_stade = stadiumId
    GROUP BY CoupeDuMonde.STADE.code_stade;

    RETURN CONCAT('Le stade ', stadiumName, ' a accueilli ', matchCount, ' match(s).');

END$$
DELIMITER;
-- 2) Ecrire une fonction qui prend en entrée le nom d'un arbitre et produit une chaine contenant les matchs qu'il a arbitré.
DELIMITER $$
CREATE FUNCTION  GetMatchesByReferee(refereeName VARCHAR(255))
RETURNS varchar(20)
BEGIN
 DECLARE stadiumName VARCHAR(255);
    DECLARE matches VARCHAR(500);

    SELECT GROUP_CONCAT(CONCAT('Match ID: ', CoupeDuMonde.MATCH.id_match, ', Date: ', CoupeDuMonde.MATCH.date_heure_match)) INTO matches
    FROM CoupeDuMonde.INDIVIDU
    JOIN CoupeDuMonde.ARBITRER ON CoupeDuMonde.INDIVIDU.no_individu = CoupeDuMonde.ARBITRER.arbitrer
    JOIN CoupeDuMonde.MATCH ON CoupeDuMonde.ARBITRER.arbitrer = CoupeDuMonde.MATCH.id_match
    WHERE CoupeDuMonde.INDIVIDU.nom_prenom = refereeName;

    RETURN CONCAT('Les matchs arbitrés par ', refereeName, ' sont : ', matches);

END$$
DELIMITER;
-- Partie 3: Questions sur les triggers
-- 1) Lors de l'ajout d'un individu, on met son nom en majuscule ainsi que la première lettre de son prénom.
create trigger capatilizename
BEFORE INSERT on individu
for EACH ROW
BEGIN
set new.nom=UPPER(new.nom);
set new.Prenom=CONCAT(UPPER(new.Prenom,1),SUBSTRING(new.Prenom,2))
END;
-- 2) Lors de l'ajout d'un match on vérifie si le nombre de spectateurs 
-- est inferieur ou égale au nombre de places disponibles dans le stade.
--  si oui on l'ajoute sinon on affiche un message d'erreur.
create trigger checkAttendance 
BEFORE insert on match
for EACH ROW
BEGIN
DECLARE stadiumCapacity  int;
SELECT
    Nb_de_places into stadiumCapacity 
FROM stade
WHERE
    Code_de_Stade=new.jouer_dans
    if new.Nb_de_spectateurs > stadiumCapacity THEN
    signal SQLSTATE'4500' set MESSAGE_TEXT = 'Le nombre de spectateurs dépasse la capacité du stade.';
END if;
END;
-- 3) Lors de l'insertion d'un but on vérifie si la minute est positive.
create trigger CheckGoalMinute
BEFORE INSERT on but 
for EACH ROW
BEGIN
    if new.minute_but<=0 THEN
    signal SQLSTATE'4500' set MESSAGE_TEXT='La minute du but doit être positive.';
END if;
END;
-- 4) Lors de la suppression d'un joueur, on supprime
--  aussi les buts qu'il a marqués.
create trigger deleteplayergoals()
after delete on individu
for EACH ROW
BEGIN
    delete from but where marque=old.no_individu
END;
-- 5) Interdire de modifier la date d'un match.
create trigger notdatechange
BEFORE UPDATE on match
for EACH ROW
BEGIN
    if old.date_heure_match != new.date_heure_match THEN
    SIGNAL SQLSTATE '4500' set MESSAGE_TEXT="La modification de la date d'un match est interdite.";
END IF;
END;
-- 6) Lors de la suppression d'une équipe, on supprime les joueurs.
create trigger deletetheamePlayers
after delete on Equipe
for EACH ROW
BEGIN
    delete from individu where jouer_dans=old.code_equipe;
END;
-- 7) Lors de la suppression d'une équipe on supprime les joueurs et les buts.
create trigger deletetheamePlayersBut
after delete on Equipe
for EACH ROW
BEGIN
    delete from individu where jouer_dans=old.code_equipe;
    delete from but where marque in(select no_individu from individu where jouer_dans=old.code_equipe)
END;
-- 8) Lors de l'ajout d'une équipe si on essaie d'insérer dans le champ nationalité
--         'fr' alors on la modifie en : France
--         'Mr' alors on la modifie en: Maroc 
--         'Br' alors on la modifie en : Brésil 
--         'Esp' alors on la modifie en Espagne
create trigger modifieNationality 
BEFORE insert on Equipe
for EACH row 
BEGIN
    if new.nationalité='fr' THEN
    set new.nationalité='france';
    elseif new.nationalité='mr' THEN
    set new.nationalité='maroc';
    elseif new.nationalité='br' THEN
    set new.nationalité='bresil';
    elseif new.nationalité='Esp' THEN
    set new.nationalité='espagne';
    endIf;
END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
-- Soit la base de données suivante permettant de gérer un championnat de football.
-- ▪ Stade (idStade, ville, nom, nbPlaces, prixBillet)
-- ▪ Equipe (idEquipe, pays, siteWeb, entraîneur)
-- ▪ Joueur (idJoueur, idEquipe,position, nom, prénom, âge,nombrebut)
-- ▪ Match(idMatch, idStade,dateMatch, idEquipe1, idEquipe2,scoreEquipe1, scoreEquipe2, nbBilletsVendus)
-- ▪ But (idJoueur, idMatch, minute, penalty)
-- 1- Créer la base de données « BotolaPro2022 » 
-- 2- Créer les Tables avec un jeu d’enregistrement tenant compte des contraintes suivantes : 
--             - L’âge de joueur doit être supérieur à 18ans
--             - Nombre de but est par défaut 0
-- 3- Noms des joueurs âgés de plus de 30 ans qui ont marqué un but pour le match dont l’idMatch=2
-- 4- Créer une vue qui affiche le nombre des joueurs ayant marqué par match
-- Partie II – Programmation
-- 1. Créer une fonction qui renvoi la recette d’un match donnée en paramètre
-- 2. Créer une fonction qui renvoi le nombre de billet vendus pour un match et un stade donné 
-- 3- Créer une procédure qui affiche un spectacle donnée le nombre des billets vendus pour chaque catégorie
-- 4- Créer une procédure qui affiche les joueurs jouant à la position « Attaquant » qui n’ont jamais marqué le but.
-- 5- Créer une procédure qui affiche le total des recettes pour un stade
-- 6- Créer une procédure qui affiche pour un stade donné en paramètre la liste des matchs joué ainsi  que le montant d’exploitation (sachant que le montant d’exploitation de stade est de 25% des  recette de match) Utiliser un curseur pour afficher le résultat comme suite : Idstade idMatch RecetteMatch Montant
-- 7. Créer un déclencheur qui permet d’incrémenter le champ nombreBut à chaque que le joueur marque le but.
-- 8. Créer un déclencheur qui empêche l’ajout d’un match au cas ou le nombre de billets vendus dépasse le nombre des places de stade.
------------------------------------------------------------------------------------------------------------------------------
-- 1- Créer la base de données « BotolaPro2022 » 
create database BotolaPro2022
-- 2- Créer les Tables avec un jeu d’enregistrement tenant compte des contraintes suivantes : 
--             - L’âge de joueur doit être supérieur à 18ans
--             - Nombre de but est par défaut 0
-- Table "Stade"
CREATE TABLE Stade (
  idStade INT PRIMARY KEY,
  ville VARCHAR(100),
  nom VARCHAR(100),
  nbPlaces INT,
  prixBillet DECIMAL(10, 2)
);

-- Exemple d'enregistrements pour la table "Stade"
INSERT INTO Stade (idStade, ville, nom, nbPlaces, prixBillet)
VALUES
  (1, 'Casablanca', 'Stade Mohammed V', 50000, 50.00),
  (2, 'Rabat', 'Stade Adrar', 45000, 40.00);

-- Table "Equipe"
CREATE TABLE Equipe (
  idEquipe INT PRIMARY KEY,
  pays VARCHAR(100),
  siteWeb VARCHAR(100),
  entraîneur VARCHAR(100)
);

-- Exemple d'enregistrements pour la table "Equipe"
INSERT INTO Equipe (idEquipe, pays, siteWeb, entraîneur)
VALUES
  (1, 'Maroc', 'http://www.equipe1.com', 'Entraîneur 1'),
  (2, 'Algérie', 'http://www.equipe2.com', 'Entraîneur 2');

-- Table "Joueur"
CREATE TABLE Joueur (
  idJoueur INT PRIMARY KEY,
  idEquipe INT,
  position VARCHAR(100),
  nom VARCHAR(100),
  prénom VARCHAR(100),
  âge INT CHECK (âge > 18),
  nombrebut INT DEFAULT 0,
  FOREIGN KEY (idEquipe) REFERENCES Equipe (idEquipe)
);

-- Exemple d'enregistrements pour la table "Joueur"
INSERT INTO Joueur (idJoueur, idEquipe, position, nom, prénom, âge)
VALUES
  (1, 1, 'Attaquant', 'Joueur 1', 'Prénom 1', 25),
  (2, 1, 'Milieu', 'Joueur 2', 'Prénom 2', 32),
  (3, 2, 'Défenseur', 'Joueur 3', 'Prénom 3', 20);

-- Table "Match"
CREATE TABLE Match (
  idMatch INT PRIMARY KEY,
  idStade INT,
  dateMatch DATE,
  idEquipe1 INT,
  idEquipe2 INT,
  scoreEquipe1 INT,
  scoreEquipe2 INT,
  nbBilletsVendus INT,
  FOREIGN KEY (idStade) REFERENCES Stade (idStade),
  FOREIGN KEY (idEquipe1) REFERENCES Equipe (idEquipe),
  FOREIGN KEY (idEquipe2) REFERENCES Equipe (idEquipe)
);

-- Exemple d'enregistrements pour la table "Match"
INSERT INTO Match (idMatch, idStade, dateMatch, idEquipe1, idEquipe2, scoreEquipe1, scoreEquipe2, nbBilletsVendus)
VALUES
  (1, 1, '2022-01-01', 1, 2, 2, 1, 5000),
  (2, 2, '2022-02-01', 2, 1, 0, 0, 3000,

  -- Table "But"
CREATE TABLE But (
  idJoueur INT,
  idMatch INT,
  minute INT,
  penalty BOOLEAN,
  FOREIGN KEY (idJoueur) REFERENCES Joueur (idJoueur),
  FOREIGN KEY (idMatch) REFERENCES Match (idMatch)
);

-- Exemple d'enregistrements pour la table "But"
INSERT INTO But (idJoueur, idMatch, minute, penalty)
VALUES
  (1, 1, 30, FALSE),
  (2, 2, 60, TRUE);
-- 3- Noms des joueurs âgés de plus de 30 ans qui ont marqué un but pour le match dont l’idMatch=2
select j.noms, J.Prenom from joueur J 
join but b on j.idJoueur=b.idJoueur 
where J.age>30 and b.idMatch=2
-- 4- Créer une vue qui affiche le nombre des joueurs ayant marqué par match
CREATE VIEW Vue_NombreButsParMatch AS
SELECT M.idMatch, COUNT(B.idJoueur) AS nombreButs
FROM Match M
LEFT JOIN But B ON M.idMatch = B.idMatch
GROUP BY M.idMatch;
-- Partie II – Programmation
-- 1. Créer une fonction qui renvoi la recette d’un match donnée en paramètre
CREATE FUNCTION  GetRecetteMatch(idMatch int)
[RETURNS DECIMAL(10,2)]
BEGIN
DECLARE recette DECIMAL(10, 2);
  
  SELECT (scoreEquipe1 + scoreEquipe2) * prixBillet AS recette
  INTO recette
  FROM Match
  JOIN Stade ON Match.idStade = Stade.idStade
  WHERE Match.idMatch = idMatch;
  
  RETURN recette;
END;
-- 2. Créer une fonction qui renvoi le nombre de billet vendus pour un match et un stade donné 
CREATE FUNCTION GetNombreBilletsVendus(idMatchId int,idStade int)
[RETURNS int]
BEGIN
DECLARE nbBilletsVendus int;
    select nbBilletsVendus into nbBilletsVendus from match where idMatchId = idMatch and match.idStade=idStade;
    RETURN nbBilletsVendus;
END;
-- 3- Créer une procédure qui affiche un spectacle donnée le nombre des billets vendus pour chaque catégorie
CREATE PROCEDURE afficheSpectacle(in id_match int)
BEGIN
  DECLARE nbBilletsCat1 INT;
  DECLARE nbBilletsCat2 INT;
  DECLARE nbBilletsCat3 INT;
  
  SELECT SUM(CASE WHEN prixBillet >= 100 THEN nbBilletsVendus ELSE 0 END) AS nbBilletsCat1,
         SUM(CASE WHEN prixBillet >= 50 AND prixBillet < 100 THEN nbBilletsVendus ELSE 0 END) AS nbBilletsCat2,
         SUM(CASE WHEN prixBillet < 50 THEN nbBilletsVendus ELSE 0 END) AS nbBilletsCat3
  INTO nbBilletsCat1, nbBilletsCat2, nbBilletsCat3
  FROM Match
  JOIN Stade ON Match.idStade = Stade.idStade
  WHERE Match.idMatch = idMatch;
  
  SELECT nbBilletsCat1 AS "Nombre de billets catégorie 1",
         nbBilletsCat2 AS "Nombre de billets catégorie 2",
         nbBilletsCat3 AS "Nombre de billets catégorie 3";
END;
-- 4- Créer une procédure qui affiche les joueurs jouant à la position 
-- « Attaquant » qui n’ont jamais marqué le but.
CREATE PROCEDURE AfficherJoueursSansBut()
BEGIN
    select j.nom,j.Prenom from Joueur J
    join But B on j.idJoueur =B.idJoueur 
     where J.position="Attaquant" and B.idJoueur is Null; 
END;
-- 5- Créer une procédure qui affiche le total des recettes pour un stade
CREATE PROCEDURE AfficherTotalRecettesPourStade(in idstade int)
BEGIN
DECLARE  totalRecettes DECIMAL (10,2);
    select sum((scoreEquipe1 + scoreEquipe2) * prixBillet) as totalRecettes)
    into totalRecettes
    from Match
    where stade.idStade=idStade;
    select totalRecettes as "Total des recettes pour le stade";
END;
-- 6- Créer une procédure qui affiche pour un stade donné en paramètre la liste des matchs joué ainsi  que le montant d’exploitation (sachant que le montant d’exploitation de stade est de 25% des  recette de match) Utiliser un curseur pour afficher le résultat comme suite : Idstade idMatch RecetteMatch Montant
CREATE PROCEDURE AfficherMatchsEtMontantExploitation(IN idStade INT)
BEGIN
  DECLARE idMatch INT;
  DECLARE recetteMatch DECIMAL(10, 2);
  DECLARE montantExploitation DECIMAL(10, 2);
  
  DECLARE cur CURSOR FOR
    SELECT Match.idMatch, (scoreEquipe1 + scoreEquipe2) * prixBillet AS recette
    FROM Match
    JOIN Stade ON Match.idStade = Stade.idStade
    WHERE Stade.idStade = idStade;
    
  OPEN cur;
  
  FETCH cur INTO idMatch, recetteMatch;
  
  WHILE @@FETCH_STATUS = 0 DO
    SET montantExploitation = recetteMatch * 0.25;
    
    SELECT idStade, idMatch, recetteMatch, montantExploitation AS "Montant d'exploitation"
    FROM Stade
    WHERE Stade.idStade = idStade;
    
    FETCH cur INTO idMatch, recetteMatch;
  END WHILE;
  
  CLOSE cur;
END;

-- 7. Créer un déclencheur qui permet d’incrémenter le champ nombreBut à chaque que le joueur marque le but.
create trigger IncrementerNombreBut
after INSERT on But
for EACH row
BEGIN
    UPDATE joueur
    SET nombreBut = nombreBut + 1
    WHERE idJoueur=new.idJoueur
END;
-- 8. Créer un déclencheur qui empêche l’ajout d’un match au cas ou le nombre de billets vendus dépasse le nombre des places de stade.
create trigger VerifierNombreBilletsVendus
BEFORE  INSERT on match
for EACH row
BEGIN
    DECLARE  nbPlaces IN;
    DECLARE  nbBilletsVendus IN;
    select nbPlaces INTO nbPlaces from stade where idStade = new.stade
  IF (nbBilletsVendus + 1) > nbPlaces THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Le nombre de billets vendus dépasse le nombre de places du stade.';
  END IF;
END;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    

-- Le schéma de base de données suivant sera utilisé pour l’ensemble du sujet. Il permet de gérer 
-- une plateforme de vente de billets de spectacles en ligne :
-- ▪ Personne(idPersonne, nom, prénom, age)
-- ▪ Salle(idSalle, nom, adresse, nbPlaces)
-- ▪ Artiste(idArtiste, nom, prénom)
-- ▪ Spectacle (idSpectacle, idArtiste, idSalle, dateSpectacle, nbBilletsVendus)
-- ▪ Billet (idBillet, idPersonne, idSpectacle, catégorie, prix)
-- Partie I – LDD
-- 1- Créer la base de données « MegaRama » (0.25pts)
-- 2- Créer les Tables avec un jeu d’enregistrement tenant compte des contraintes suivantes : (2.75pts) - L’âge de la personne doit être supérieur à 12ans - Catégorie de Billet doit être soit : Classe A, Classe b ou Classe C
-- 3- Créer une requête qui compte le nombre de billet par catégorie d’un spectacle (1.5pt)
-- 4- Créer une vue qui affiche le nombre de personne par Spectacle (1.5pt)
-- Partie II – Programmation
-- 1- Créer une fonction qui renvoi la recette d’un spectacle donnée en paramètre
-- 2- Créer une fonction qui renvoi le nombre de billet vendus pour une catégorie et un spectacle donné
-- 3- Créer une procédure qui affiche un spectacle donnée le nombre des billets vendus pour chaque catégorie
-- 4- Créer une procédure qui affiche le total des recettes pour l’année encours
-- 5- Créer une procédure qui affiche pour un artiste donné en paramètre liste des spectacles animés ainsi que le montant de participation (25% des recette de spectacle) Utiliser un curseur pour afficher le résultat comme suite : Id Spectacle Date Recette Spectacle Montant
-- 6- Créer un déclencheur qui permet d’incrémenter le champ nbBilletsVendus à chaque vente de billet
-- 7- Créer un déclencheur qui empêche les ventes de billets une fois le nombre de place de la salle est occupé.
------------------------------------------------------------------------------------------------------------------------
-- Partie I – LDD
-- 1- Créer la base de données « MegaRama » (0.25pts)
create database MegaRama
use MegaRama
-- 2- Créer les Tables avec un jeu d’enregistrement tenant compte des contraintes suivantes : (2.75pts) 
-- - L’âge de la personne doit être supérieur à 12ans 
-- - Catégorie de Billet doit être soit : Classe A, Classe b ou Classe C
CREATE TABLE Personne (
    idPersonne INT PRIMARY KEY,
    nom VARCHAR(50),
    prenom VARCHAR(50),
    age INT CHECK(age > 12)
);

CREATE TABLE Salle (
    idSalle INT PRIMARY KEY,
    nom VARCHAR(50),
    adresse VARCHAR(100),
    nbPlaces INT
);

CREATE TABLE Artiste (
    idArtiste INT PRIMARY KEY,
    nom VARCHAR(50),
    prenom VARCHAR(50)
);

CREATE TABLE Spectacle (
    idSpectacle INT PRIMARY KEY,
    idArtiste INT,
    idSalle INT,
    dateSpectacle DATE,
    nbBilletsVendus INT,
    FOREIGN KEY (idArtiste) REFERENCES Artiste(idArtiste),
    FOREIGN KEY (idSalle) REFERENCES Salle(idSalle)
);

CREATE TABLE Billet (
    idBillet INT PRIMARY KEY,
    idPersonne INT,
    idSpectacle INT,
    categorie VARCHAR(10) CHECK(categorie IN ('Classe A', 'Classe B', 'Classe C')),
    prix DECIMAL(8, 2),
    FOREIGN KEY (idPersonne) REFERENCES Personne(idPersonne),
    FOREIGN KEY (idSpectacle) REFERENCES Spectacle(idSpectacle)
);
-- 3- Créer une requête qui compte le nombre de billet par catégorie d’un spectacle (1.5pt)
select categorie, count(*) as nombre de billet from billet where  idSpectacle=idSpectacle GROUP BY categorie
-- 4- Créer une vue qui affiche le nombre de personne par Spectacle (1.5pt)
CREATE VIEW Vue_PersonnesParSpectacle AS
SELECT S.idSpectacle, COUNT(P.idPersonne) AS nombre_de_personnes
FROM Spectacle S
LEFT JOIN Billet B ON S.idSpectacle = B.idSpectacle
LEFT JOIN Personne P ON B.idPersonne = P.idPersonne
GROUP BY S.idSpectacle;
-- Partie II – Programmation
-- 1- Créer une fonction qui renvoi la recette d’un spectacle donnée en paramètre
create function CalculerRecette(idSpectacle) RETURNS DECIMAL(8,2)
BEGIN
DECLARE recette decimal(8,2);
select sum(prix) into recette from billet
where idSpectacle=idSpectacle
RETURN recette 
END;
-- 2- Créer une fonction qui renvoi le nombre de billet vendus pour une catégorie et un spectacle donné
create function CalculerNombreBilletsVendus(idSpectacle int,categorie varchar(255)) RETURNS VARCHAR(255)
BEGIN
DECLARE nombreBilletsVendus INT;
select coun(*) into nombreBilletsVendus from billet where  idSpectacle=idSpectacle and categorie=categorie 
RETURN nombreBilletsVendus;
END;
-- 3- Créer une procédure qui affiche un spectacle donnée le nombre des billets vendus pour chaque catégorie
CREATE PROCEDURE afficheSpectacle(idspectacle int)
BEGIN
    select s.nom as nom_spectacle,B.categorie,count(*) AS nombre_billets_vendus
    from billet 
    join billet b on s.idSpectacle=b.idSpectacle
    where s.idSpectacle=b.idSpectacle
    GROUP BY s.nom , b.categorie
END;
-- 4- Créer une procédure qui affiche le total des recettes pour l’année encours
CREATE PROCEDURE  AfficherTotalRecettesAnneeEnCours()
BEGIN
    DECLARE annee int;
    set annee=YEAR(CURDATE());
    select sum(prix) as total_recettes
    from billet 
    join spectacle on billet.idSpectacle=spectacle.idSpectacle
    where YEAR(Spectacle.dateSpectacle) = annee;
END;
-- 5- Créer une procédure qui affiche pour un artiste donné en paramètre liste des spectacles animés ainsi que le montant de participation (25% des recette de spectacle) Utiliser un curseur pour afficher le résultat comme suite : Id Spectacle Date Recette Spectacle Montant
DELIMITER //

CREATE PROCEDURE AfficherSpectaclesArtisteAvecMontant(idArtiste INT)
BEGIN
    DECLARE idSpectacle INT;
    DECLARE dateSpectacle DATE;
    DECLARE recetteSpectacle DECIMAL(8, 2);
    DECLARE montantParticipation DECIMAL(8, 2);

    DECLARE cur CURSOR FOR
    SELECT S.idSpectacle, S.dateSpectacle, SUM(B.prix) AS recette
    FROM Spectacle S
    JOIN Billet B ON S.idSpectacle = B.idSpectacle
    WHERE S.idArtiste = idArtiste
    GROUP BY S.idSpectacle, S.dateSpectacle;

    OPEN cur;
    FETCH cur INTO idSpectacle, dateSpectacle, recetteSpectacle;

    WHILE (FOUND_ROWS() > 0) DO
        SET montantParticipation = recetteSpectacle * 0.25;
        SELECT idSpectacle, dateSpectacle, recetteSpectacle, montantParticipation;
        FETCH cur INTO idSpectacle, dateSpectacle, recetteSpectacle;
    END WHILE;

    CLOSE cur;
END //

DELIMITER ;

-- 6- Créer un déclencheur qui permet d’incrémenter le champ nbBilletsVendus à chaque vente de billet
create trigger IncrementerNbBilletsVendus 
after insert on Billet 
FOR EACH ROW
BEGIN
UPDATE  spectacle
SET nbBilletsVendus =nbBilletsVendus +1
WHERE idSpectacle=new.idSpectacle
END;
-- 7- Créer un déclencheur qui empêche les ventes de billets une fois le nombre de place de la salle est occupé.
create trigger VerifierNombrePlacesAvantVente 
BEFORE insert on Billet 
FOR EACH ROW
BEGIN
    DECLARE nbPlacesOccupes INT;
    select count(*) INTO nbPlacesOccupes
    from Billet
    where id.spectacle=new.idspectacle

    DECLARE capacitySalle INT;
    select nbPlaces into capacitySalle
    from salle
    join spectacle on spectacle.idsalle=Salle.idsalle

    if nbPlacesOccupes >= capacitySalle THEN
    signal SQLSTATE '45000' set MESSAGE_TEXT='La vente de billets est terminée. La salle est complète.';
    END IF;

END;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
-- Compte (NumCompte, solde, TypeCompte, #NumCl) 
-- Client (CIN, nom, prenom, adresse, tel)
-- Operation ( NumOP, TypeOp, MontantOp, #NumCpt, DateOp) 
-- Versement (NunVer, dateVer, NumCompteDebiteur, NumCompteCrediteur, montant)
-- Exercice 1 : Les procédures stockées
-- 1- Créer une procédure qui affiche la liste des opérations effectué par un client l’année 
-- encours
-- 2- Créer une fonction qui renvoie la somme des opérations par compte pour un client donnée 
-- en paramètre
-- Exercice 2 : Les triggers
-- 1- Créer un trigger TR_MAJ_Solde qui permet de mettre à jour le solde lors d’une opération
-- 2- Créer un trigger TR_MAJ_SOLDE_Ver qui permet de mettre à jour le solde des comptes lors 
-- de l’opération de versement.
-- 3- Créer un déclencheur TR_AJOUT_COMPTE qui, à la création d'un nouveau compte de type
-- CC, vérifie si le solde est >1500.00DH.
-- 4- Créer un déclencheur qui empêche la création d'un nouveau compte de type CC pour un
-- client qui en a déjà un.
-- 5- Créer un déclencheur qui empêche la suppression d’un compte dont le solde n’est pas 0
-- 6- Créer un déclencheur TR_UPDATE_COMPTE qui interdit la modification du type de compte
-- des comptes auxquels sont associées des opérations,
------------------------------------------------------------------------------------------------------------------------------------
-- Exercice 1 : Les procédures stockées
-- 1- Créer une procédure qui affiche la liste des opérations effectué par un client l’année encours
create procedure ListeOperationsParClientAnneeEnCours(in NumCl)
BEGIN
DECLARE anneeEnCour int;
set anneeEnCour = YEAR(GETDATE())

select o.numOP,o.typeOp,o.montantop,o.dateOp
from Operation o 
join compte c on o.NumCpt = c.NumCompte
where c.numC1=numC1 and YEAR(o.dateOp) = anneeEnCours;
END;
-- 2- Créer une fonction qui renvoie la somme des opérations par compte pour un client donnée en paramètre
create function SommeOperationsParComptePourClient(NumC1 int) RETURNS table
BEGIN
RETURN(
    select c.NumCompte , sum(o.montant) as SommeOperationsParComptePourClient
    from compte c
    join Operation o on c.NumCompte = o.NumCompte
    where c.numC1 =NumC1
    GROUP BY
        c.NumCompte
)
END;
-- Exercice 2 : Les triggers
-- 1- Créer un trigger TR_MAJ_Solde qui permet de mettre à jour le solde lors d’une opération
create trigger TR_MAJ_Solde after insert on Operation
FOR EACH ROW
BEGIN
if new.TypeOp='Debit' then
UPDATE compte SET solde = solde - new.montantOp where NumCompte =new.NumCompte;
ELSE
UPDATE compte SET solde = solde + new.montantOp where NumCompte =new.NumCompte;
endIf;
WHERE condition
END;
-- 2- Créer un trigger TR_MAJ_SOLDE_Ver qui permet de mettre à jour le solde des comptes lors de l’opération de versement.
create trigger TR_MAJ_SOLDE_Ver after insert on versement
for each row
BEGIN
UPDATE complets SET solde=solde-new.montant where NumCompte=new.NumCompteDebiteur
UPDATE complets SET solde=solde+new.montant where NumCompte=new.NumCompteCrediteur
END;
-- 3- Créer un déclencheur TR_AJOUT_COMPTE qui, à la création d'un nouveau compte de type CC, vérifie si le solde est >1500.00DH.
create trigger TR_AJOUT_COMPTE BEFORE insert on Compte
for each row
BEGIN
if new.TypeCompte='cc' and new.solde <=1500.00 THEN
signal SQLSTATE '45000' set MESSAGE_TEXT="Le solde initial d'un compte CC doit être supérieur à 1500.00DH";
    END IF;
END;
-- 4- Créer un déclencheur qui empêche la création d'un nouveau compte de type CC pour un client qui en a déjà un.
create trigger TR_EMPECHE_CREATION_CC BEFORE INSERT on Compte
for each row
BEGIN
if new.TypeCompte='cc' and existe(select 1 from Compte where numC1=new.NumC1 and TypeCompte='cc') THEN
signal SQLSTATE '45000' set MESSAGE_TEXT="Un client ne peut avoir qu'un seul compte courant (CC)";
endIf
END;
-- 5- Créer un déclencheur qui empêche la suppression d’un compte dont le solde n’est pas 0
create trigger TR_EMPECHE_SUPPRESSION_COMPTE BEFORE DELETE ON compte
for each row
BEGIN
IF old.solde <> 0 THEN
signal SQLSTATE '45000' set MESSAGE_TEXT='Impossible de supprimer un compte dont le solde n\'est pas 0';
    END IF;
END;
-- 6- Créer un déclencheur TR_UPDATE_COMPTE qui interdit la modification du type de compte des comptes auxquels sont associées des opérations,
create TR_UPDATE_COMPTE BEFORE UPDATE on complets
FOR EACH ROW
BEGIN
 IF EXISTS (SELECT 1 FROM Operation WHERE NumCpt = OLD.NumCompte) THEN
        IF OLD.TypeCompte <> NEW.TypeCompte THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Impossible de modifier le type de compte associé à des opérations';
        END IF;
    END IF;
END;
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
-- Partie 01 : Gestion de collection (1.75pt)
-- 1- Créer la base de données « DBLP » (0.25pt)
use DBLP
-- 2- Créer la collection « publis » (0.25pt)
db.creatCollection("publis")
-- 3- Créer une variable « pub » contenant le document suivant : (0.25pt)
-- {
--  "type": "Book",
--  "title": "Modern Database Systems: The Object Model, Interoperability, and 
-- Beyond.",
--  "year": 1995,
--  "publisher": "ACM Press and Addison-Wesley",
--  "authors": ["Won Kim"],
--  "source": "DBLP"
-- }
var pub={
 "type": "Book",
 "title": "Modern Database Systems: The Object Model, Interoperability, and 
Beyond.",
 "year": 1995,
 "publisher": "ACM Press and Addison-Wesley",
 "authors": ["Won Kim"],
 "source": "DBLP"
}

-- 4- Insérer le document ci-dessus. (0.25pt)
db.publis.insertOne(pub)
-- 5- Importer les documents dans la collection « publis » à partir de fichier json « dblp.json » (0.25pt)
mongoimport -d DBLP
-c publis
dblp.json
-- 6- Renommer la collection « publis » par « publications ». (0.25pts)
db.publis.renameCollection('publications')
-- 7- Créer un index sur les champs : title (en ordre croissant), year (en ordre décroissant) et type. (0.25pt)
db.publications.createIndex({title:1, year:-1, type:1})
---------------------------------------------------------------
-- 1. Liste de tous les livres (type « Book ») ; (0.25pt)
db.publications.find({type:"book"})
-- 2. Liste des publications depuis 2011 ; (0.25pt)
db.publications.find({year:{$glt:2011}})
-- 3. Liste des livres depuis 2014 ; (0.25pt)
db.publications.find({type:"book",year:{$glt:2014}})
-- 4. Liste des publications de l’auteur « Toru Ishida » ; (0.25pt)
db.publications.find({authors:"Toru Ishida"})
-- 5. Liste de tous les éditeurs (type « publisher »), distincts ; (0.5pt)
db.publications.distincts("publisher",{type:"publisher"});
-- 6. Liste de tous les auteurs distincts ; (0.5pt)
db.publications.distincts("authors");
-- 7. Trier les publications de « Toru Ishida » par titre de livre et par page de début ; (0.5pt)
db.publications.find({auteurs:"Toru Ishida"},sort({title:1,startPage:1}))
-- 8. Projeter le résultat sur le titre de la publication, et les pages ; (0.5pt)
db.publications.find({auteurs:"Toru Ishida"},{title:1,startPage:1})
-- 9. Compter le nombre de ses publications ; (1pt)
db.publications.find().count()
-- 10. Compter le nombre de publications depuis 2011 et par type ; (1pt)
db.publications.aggregate([
  { $match: { year: { $gte: 2011 } } },
  { $group: { _id: "$type", count: { $sum: 1 } } }
]);
-- 11. Compter le nombre de publications par auteur et trier le résultat par ordre croissant. (1pt)
db.publications.aggregate([
  { $unwind: "$authors" },
  { $group: { _id: "$authors", count: { $sum: 1 } } },
  { $sort: { count: 1 } }
])
---------------------------------------------------------------
-- 1. Mettre à jour tous les livres contenant « database » en ajoutant l’attribut « Genre » : « Database ». (0.25pt)
db.publications.updateMany([
    {type:'book', title: { $regex: "database", $options: "i" } },{ $set: { Genre: "Database" } }
])
-- 2. Supprimer le champ « number » de tous articles. (1pt)
db.publications.updateMany(
  { type: "article" },
  { $unset: { number: "" } }
)
-- 3. Supprimer tous les articles n’ayant aucun auteur. (1pt)
db.publications.deleteMany(
  { type: "article", authors: { $exists: false } }
)
-- 4. Modifier toutes les publications ayant des pages pour ajouter le champ « pp » avec pour valeur le motif suivant : pages.start--pages.end. (1pt)
db.publications.updateMany(
  { pages: { $exists: true } },
  { $set: { pp: { $concat: [ "$pages.start", "--", "$pages.end" ] } } }
)
---------------------------------------------------------------
-- 1- Créer les utilisateurs suivants : (1.25pt)
use admin

db.createUser({
  user: "Alami",
  pwd: "@lam!",
  roles: [
    { role: "readWrite", db: "userDatabase" },
    { role: "dbOwner", db: "userDatabase" }
  ]
})

db.createUser({
  user: "Rami",
  pwd: "r@m!",
  roles: [
    { role: "read", db: "userDatabase" },
    { role: "dbAdmin", db: "userDatabase" }
  ]
})

db.createUser({
  user: "Kabiri",
  pwd: "k@bir!",
  roles: [
    { role: "readWrite", db: "userDatabase" }
  ]
})

-- 2- Ecrire le Script MongoDB qui permet de changer le mot de passe de l’utilisateur Alami. (0.5pt)
db.changeUserPassword("Alami", "@lam!NewPassword")
-- 3- Ecrire le Script MongoDB qui permet d’authentifier au serveur entant que l’utilisateur Rami. (0.25pt)
db.auth("Rami", "r@m!")
-- 4- Ecrire le Script MongoDB qui permet de supprimer l’utilisateur Kabiri. (0.25pt
db.dropUser("Kabiri")
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
-- 1- Créer la base de données « ScholarVox » dans mongoDB (1pt)
-- 2- Créer la collection « books » en respectant le format ci-dessus. (1pt)
-- 3- Ecrire la requête qui permet d’insérer un document. (2pts)
-- 4- Ecrire la requête qui permet d’afficher les informations de livre dont le numéro ISBN 
-- est : 2154889589 (2pts)
-- 5- Ecrire une requête qui compte le nombre des ventes pour chaque livre. (2pts)
-- 6- Ecrire une requête qui calcul le montant total des ventes de l’année encours. (2pts)
-- 7- Ecrire une requête qui calcul la somme des ventes de livre numéro ; 2154889589 (2pts)
-- 8- Ecrire une requête qui permet de mettre à jour le champ recette de chaque Auteur.
-- (2pts)
-- 9- Ecrire une requête qui affiche les livres jamais vendus. (2pts)
----------------------------------------------------------------------------------------------------------------
{ 
"id" :9, 
"nom" :"ALAMI",
"prénom":"Ahmed", 
"recette":0,
"livre" : 
[ 
{ "isbn" :2154889589 ,
"titre" :"NoSQL", 
"prixachat":250,
"vente": 
[ 
{ "id_vente":12, 
"date" :02/06/2017,
"prixvente":300
},
{ 
"id_vente":20, 
"date" :12/09/2017,
"prixvente":350
} 
] 
} 
] 
}
-- 1- Créer la base de données « ScholarVox » dans mongoDB (1pt)
use ScholarVox
-- 2- Créer la collection « books » en respectant le format ci-dessus. (1pt)
db.createCollection("books")
-- 3- Ecrire la requête qui permet d’insérer un document. (2pts)
db.books.insertOne({
  "isbn": 2154889589,
  "titre": "NoSQL",
  "prixachat": 250,
  "vente": [
    {
      "id_vente": 12,
      "date": "02/06/2017",
      "prixvente": 300
    },
    {
      "id_vente": 20,
      "date": "12/09/2017",
      "prixvente": 350
    }
  ]
})

-- 4- Ecrire la requête qui permet d’afficher les informations de livre dont le numéro ISBN est : 2154889589 (2pts)
db.books.find("isbn":2154889589)
-- 5- Ecrire une requête qui compte le nombre des ventes pour chaque livre. (2pts)
db.books.aggregate([
  {
    $project: {
      _id: 0,
      isbn: 1,
      numberOfSales: { $size: "$vente" }
    }
  }
])
-- 6- Ecrire une requête qui calcul le montant total des ventes de l’année encours. (2pts)
db.books.aggregate([
  {
    $project: {
      _id: 0,
      isbn: 1,
      totalSalesAmount: {
        $reduce: {
          input: "$vente",
          initialValue: 0,
          in: { $sum: ["$$value", "$$this.prixvente"] }
        }
      }
    }
  }
])

-- 7- Ecrire une requête qui calcul la somme des ventes de livre numéro ; 2154889589 (2pts)
db.books.aggregate([
  {
    $match: {
      "isbn": 2154889589
    }
  },
  {
    $project: {
      _id: 0,
      isbn: 1,
      totalSalesAmount: {
        $sum: "$vente.prixvente"
      }
    }
  }
])

-- 8- Ecrire une requête qui permet de mettre à jour le champ recette de chaque Auteur.(2pts)
db.books.updateMany({},{$set{"recette":100}})
-- 9- Ecrire une requête qui affiche les livres jamais vendus. (2pts
db.books.find({"vente": { $size: 0 }})
DELIMITER //
CREATE PROCEDURE AfficherLivresParEditeur(IN editeurId INT)
BEGIN
    SELECT *
    FROM Livre
    WHERE editeurId = editeurId;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AfficherLivresNonVendus()
BEGIN
    SELECT *
    FROM Livre
    WHERE id NOT IN (SELECT DISTINCT livreId FROM Vente);
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION CalculerChiffreAffaires(produitId INT)
RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(prixVente) INTO total
    FROM Vente
    WHERE livreId = produitId
        AND YEAR(dateVente) = YEAR(CURRENT_DATE);
    RETURN total;
END //
DELIMITER ;

create trigger MiseAJourRecette after insert on vente
for EACH ROW
BEGIN
UPDATE auteur
SET recette = recette + NEW.prixVente
    WHERE id = (SELECT auteurId FROM Livre WHERE id = NEW.livreId);
END;

-------control 202 ftir-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
-- Soit la base de données FACTURATION qui contient les tables suivantes :
-- CAISSE (NumCaisse, Heuredeb, Heurefin, Caissière, SomInitiale, SomFinale)
-- FACTURE (NumFac, NumCaisse*, DateFac, TypePaie)
-- LIGNEFAC (NumFac*, Article, Prix Unitaire, Qté)
-- 1) Lister via une procédure stockée les caisses dans les quelles le type du paiement est " espèce" (3 Pts)
CREATE PROCEDURE ListeCaissesEspece()
BEGIN
    select * from caisse where NumCaisse in (select TypePaie from factures where TypePaie="espèce")
END;
-- 2) Ecrire une fonction qui retourne le total de monnaie enregistrée sur une caisse donnée au cours d'une date donnée. (3 Pts)
CREATE FUNCTION TotalMonnaieCaisse(NumCaisseParam INT, DateParam DATE) RETURNS DECIMAL(10,2)
BEGIN
DECLARE totale DECIMAL(10,2);
select sum(SomInitiale) into totale 
from caisse where NumCaisse=NumCaisseParam  AND DATE(Heuredeb) = DateParam;
    RETURN Total;
END;
-- 3) Ecrire une procédure stockée qui liste les caissières qui ont passé des articles dont le prix unitaire est supérieur à 300. (3 Pts)

CREATE PROCEDURE ListeCaissièresPrixSupérieur300()
BEGIN
    SELECT DISTINCT Caissière
    FROM LIGNEFAC
    WHERE PrixUnitaire > 300;
END
-- 4) Supprimer à travers une procédure stockée les caisses qui n'ont reçu aucun règlement de factures. (3 Pts)
CREATE PROCEDURE supprimecaissesaucunréglement()
BEGIN
    delete from CAISSE where NumCaisse not in (
        select NumCaisse from FACTURE
    );
END

-- 5) Créer une fonction qui calcule et renvoie la somme et la moyenne des règlements effectués par chèque dans une période donnée pour une caissière donnée. (3 Pts)
CREATE FUNCTION SommeMoyenneReglements(NumCaisseParam INT, DateDebutParam DATE, DateFinParam DATE)
RETURNS TABLE (Somme DECIMAL(10,2), Moyenne DECIMAL(10,2))
BEGIN
    DECLARE Total DECIMAL(10,2);
    DECLARE Count INT;
    SELECT SUM(SomInitiale), COUNT(*) INTO Total, Count
    FROM CAISSE
    WHERE NumCaisse = NumCaisseParam
        AND TypePaie = 'cheque'
        AND DATE(DateFac) BETWEEN DateDebutParam AND DateFinParam;
    
    RETURN TABLE (Total, Total / Count);
END
-- 6) Lister via une fonction les numéros de caisse auxquelles une caissière donnée est affectée une seule fois. Appeler la fonction. (3 Pts)
CREATE FUNCTION ListeCaissesUnique(CaissièreParam VARCHAR(100))
RETURNS TABLE (NumCaisse INT)
BEGIN
    DECLARE Count INT;
    SELECT COUNT(*) INTO Count
    FROM CAISSE
    WHERE Caissière = CaissièreParam;
    
    IF Count = 1 THEN
        INSERT INTO ListeCaissesUnique
        SELECT NumCaisse
        FROM CAISSE
        WHERE Caissière = CaissièreParam;
    END IF;
    
    RETURN;
END

-- 7) Programmer les triggers qui conviennent pour respecter les règles de gestion suivantes :
-- La somme SomInitiale doit être inférieure ou égale à la somme SomFinale (2 Pts)
create trigger VerifSommeInitFin 
befor insert on caisse 
for EACH ROW
BEGIN
IF NEW.SomInitiale > NEW.SomFinale THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La somme initiale doit être inférieure ou égale à la somme finale.';
    END IF;
END;
-- Dans la table FACTURE le type de paiement doit être parmi l'une des valeurs suivantes : 'espèce', 'CB', 'cheque' et 'bon achat. (2 Pts)
create trigger VerifTypePaiement BEFORE insert on FACTURE
for EACH ROW
BEGIN
IF NEW.TypePaie NOT IN ('espèce', 'CB', 'cheque', 'bon achat') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Le type de paiement doit être parmi les valeurs : espèce, CB, cheque, bon achat.';
    END IF;
END;

-- 8) Eviter la diminution des valeurs du champ Prix Unit par un trigger en modification sur la table LIGNEFAC. (2 Pts)
create trigger BloquerDiminutionPrixUnit
BEFORE UPDATE on LIGNEFAC 
for EACH row
BEGIN
IF NEW.PrixUnitaire < OLD.PrixUnitaire THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La diminution des valeurs du champ PrixUnit est interdite.';
    END IF;
END;
Partic 2 (NoSQL/MongoDB) (16 points)

-- Ci-dessous un échantillon de données déjà importées dans une collection appelée Books:
 [ {"_id": "Book001","type": "Roman", "titre": "Sans Famille", "pages": 417, "date": 2000, "auteurs": ["Hector Malot"]}.
{"_id": "Book002","type": "Digital", "titre": "Querying MySQL", "pages": 672, "date": 2022, "auteurs": ["Adam Aspin"]}
-- Réaliser les requêtes MongoDB permettant de :
-- 1) Afficher les ouvrages dont le titre est 'Sans Famille' (4 Pts)
db.Books.find({ "titre": "Sans Famille" })

-- 2) Afficher uniquement le titre et les auteurs des ouvrages dont le nombre de pages est inférieur ou égal à 450 (4 Pts)
db.Books.find({ "pages": { "$lte": 450 } }, { "titre": 1, "auteurs": 1 })
-- 3) Afficher uniquement le titre et les auteurs des ouvrages de type 'Roman' triés par nombre de pages (ordre croissant) (4 Pts)
db.Books.find({ "type": "Roman" }, { "titre": 1, "auteurs": 1 }.sort({ "pages": 1 }))
-- 4) Afficher les ouvrages n'ayant pas le nombre de pages (4 Pts)
db.Books.find({ "pages": { "$exists": false } })
